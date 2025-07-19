module SAM (
    input Clock, 
    input Reset, 
    input Start, 
    input [7:0] Multiplicand, 
    input [7:0] Multiplier,
    output reg [15:0] Product, 
    output reg Done
);
    localparam IDLE = 2'b00, WORK = 2'b01, DONE = 2'b10;

    wire [1:0] State_Q;
    reg  [1:0] State_D;
    wire [3:0] Count_Q;
    reg  [3:0] Count_D;
    wire [15:0] Product_Q;
    reg  [15:0] Product_D;
    wire [15:0] Multiplicand_Q;
    reg  [15:0] Multiplicand_D;
    wire [15:0] Multiplier_Q;
    reg  [15:0] Multiplier_D;
    wire Done_Q;
    reg  Done_D;

    // DFF implementations as always blocks
    reg [1:0] State_Q_reg;
    reg [3:0] Count_Q_reg;
    reg [15:0] Product_Q_reg;
    reg [15:0] Multiplicand_Q_reg;
    reg [15:0] Multiplier_Q_reg;
    reg Done_Q_reg;

    always @(posedge Clock or posedge Reset) begin
        if (Reset) begin
            State_Q_reg <= 2'b00;
        end else begin
            State_Q_reg <= State_D;
        end
    end

    always @(posedge Clock or posedge Reset) begin
        if (Reset) begin
            Count_Q_reg <= 4'd0;
        end else begin
            Count_Q_reg <= Count_D;
        end
    end

    always @(posedge Clock or posedge Reset) begin
        if (Reset) begin
            Product_Q_reg <= 16'd0;
        end else begin
            Product_Q_reg <= Product_D;
        end
    end

    always @(posedge Clock or posedge Reset) begin
        if (Reset) begin
            Multiplicand_Q_reg <= 16'd0;
        end else begin
            Multiplicand_Q_reg <= Multiplicand_D;
        end
    end

    always @(posedge Clock or posedge Reset) begin
        if (Reset) begin
            Multiplier_Q_reg <= 16'd0;
        end else begin
            Multiplier_Q_reg <= Multiplier_D;
        end
    end

    always @(posedge Clock or posedge Reset) begin
        if (Reset) begin
            Done_Q_reg <= 1'b0;
        end else begin
            Done_Q_reg <= Done_D;
        end
    end

    // Assign wire outputs from registers
    assign State_Q = State_Q_reg;
    assign Count_Q = Count_Q_reg;
    assign Product_Q = Product_Q_reg;
    assign Multiplicand_Q = Multiplicand_Q_reg;
    assign Multiplier_Q = Multiplier_Q_reg;
    assign Done_Q = Done_Q_reg;

    always @(*) begin
        case (State_Q)
            IDLE: begin
                Done_D = 1'b0;
                if (Start) begin
                    Product_D = 16'd0;
                    Count_D = 4'd0;
                    Multiplicand_D = {8'b0, Multiplicand};
                    Multiplier_D = {8'b0, Multiplier};
                    State_D = WORK;
                end
            end

            WORK: begin
                Done_D = 1'b0;
                if (Count_Q < 4'd8) begin
                    if (Multiplier_Q[0]) begin
                        Product_D = Product_Q + Multiplicand_Q;
                    end else begin
                        Product_D = Product_Q;
                    end
                    Multiplicand_D = Multiplicand_Q << 1;
                    Multiplier_D = Multiplier_Q >> 1;
                    Count_D = Count_Q + 1;
                end else begin
                    State_D = DONE;
                    Done_D = 1'b1;
                end
            end

            DONE: begin
                Done_D = 1'b1;
                if (!Start) begin
                    State_D = IDLE;
                end
            end

            default: begin
                State_D = IDLE;
                Done_D = 1'b0;
            end
        endcase
    end

    always @(*) begin
        Product = Product_Q;
        Done = Done_Q;
    end
endmodule