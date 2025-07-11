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

    DFF #(.N(2)) state_dff(
        .Clock(Clock),
        .Reset(Reset),
        .Enable(1'b1),
        .D(State_D),
        .Q(State_Q)
    );
    DFF #(.N(4)) count_dff(
        .Clock(Clock),
        .Reset(Reset),
        .Enable(1'b1),
        .D(Count_D),
        .Q(Count_Q)
    );
    DFF #(.N(16)) product_dff(
        .Clock(Clock),
        .Reset(Reset),
        .Enable(1'b1),
        .D(Product_D),
        .Q(Product_Q)
    );
    DFF #(.N(16)) multiplicand_dff(
        .Clock(Clock),
        .Reset(Reset),
        .Enable(1'b1),
        .D(Multiplicand_D),
        .Q(Multiplicand_Q)
    );
    DFF #(.N(16)) multiplier_dff(
        .Clock(Clock),
        .Reset(Reset),
        .Enable(1'b1),
        .D(Multiplier_D),
        .Q(Multiplier_Q)
    );
    DFF #(.N(1)) done_dff(
        .Clock(Clock),
        .Reset(Reset),
        .Enable(1'b1),
        .D(Done_D),
        .Q(Done_Q)
    );

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