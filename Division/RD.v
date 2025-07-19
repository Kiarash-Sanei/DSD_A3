module RD(
    input Clock,
    input Reset,
    input Start,
    input [15:0] Dividend,
    input [15:0] Divisor,
    output reg [15:0] Quotient,
    output reg [15:0] Remainder,
    output reg Done
);
    wire [4:0] Count_Q;
    reg  [4:0] Count_D;
    wire [15:0] Quotient_Q;
    reg  [15:0] Quotient_D;
    wire [16:0] Remainder_Q;
    reg  [16:0] Remainder_D;
    wire [15:0] Divisor_Q;
    reg  [15:0] Divisor_D;
    wire [1:0] State_Q;
    reg  [1:0] State_D;
    wire Done_Q;
    reg  Done_D;
    wire [15:0] Dividend_Q;
    reg  [15:0] Dividend_D;
    
    wire Sign_Quotient_Q;
    reg  Sign_Quotient_D;
    wire Sign_Remainder_Q;
    reg  Sign_Remainder_D;
    wire [15:0] Abs_Dividend_Q;
    reg  [15:0] Abs_Dividend_D;
    wire [15:0] Abs_Divisor_Q;
    reg  [15:0] Abs_Divisor_D;
    
    localparam IDLE = 2'b00, WORK = 2'b01, DONE = 2'b10;

    // DFF implementations as always blocks
    reg [4:0] Count_Q_reg;
    reg [15:0] Quotient_Q_reg;
    reg [16:0] Remainder_Q_reg;
    reg [15:0] Divisor_Q_reg;
    reg [15:0] Dividend_Q_reg;
    reg [1:0] State_Q_reg;
    reg Done_Q_reg;
    reg Sign_Quotient_Q_reg;
    reg Sign_Remainder_Q_reg;
    reg [15:0] Abs_Dividend_Q_reg;
    reg [15:0] Abs_Divisor_Q_reg;

    always @(posedge Clock or posedge Reset) begin
        if (Reset) begin
            Count_Q_reg <= 5'd0;
        end else begin
            Count_Q_reg <= Count_D;
        end
    end

    always @(posedge Clock or posedge Reset) begin
        if (Reset) begin
            Quotient_Q_reg <= 16'd0;
        end else begin
            Quotient_Q_reg <= Quotient_D;
        end
    end

    always @(posedge Clock or posedge Reset) begin
        if (Reset) begin
            Remainder_Q_reg <= 17'd0;
        end else begin
            Remainder_Q_reg <= Remainder_D;
        end
    end

    always @(posedge Clock or posedge Reset) begin
        if (Reset) begin
            Divisor_Q_reg <= 16'd0;
        end else begin
            Divisor_Q_reg <= Divisor_D;
        end
    end

    always @(posedge Clock or posedge Reset) begin
        if (Reset) begin
            Dividend_Q_reg <= 16'd0;
        end else begin
            Dividend_Q_reg <= Dividend_D;
        end
    end

    always @(posedge Clock or posedge Reset) begin
        if (Reset) begin
            State_Q_reg <= 2'b00;
        end else begin
            State_Q_reg <= State_D;
        end
    end

    always @(posedge Clock or posedge Reset) begin
        if (Reset) begin
            Done_Q_reg <= 1'b0;
        end else begin
            Done_Q_reg <= Done_D;
        end
    end

    always @(posedge Clock or posedge Reset) begin
        if (Reset) begin
            Sign_Quotient_Q_reg <= 1'b0;
        end else begin
            Sign_Quotient_Q_reg <= Sign_Quotient_D;
        end
    end

    always @(posedge Clock or posedge Reset) begin
        if (Reset) begin
            Sign_Remainder_Q_reg <= 1'b0;
        end else begin
            Sign_Remainder_Q_reg <= Sign_Remainder_D;
        end
    end

    always @(posedge Clock or posedge Reset) begin
        if (Reset) begin
            Abs_Dividend_Q_reg <= 16'd0;
        end else begin
            Abs_Dividend_Q_reg <= Abs_Dividend_D;
        end
    end

    always @(posedge Clock or posedge Reset) begin
        if (Reset) begin
            Abs_Divisor_Q_reg <= 16'd0;
        end else begin
            Abs_Divisor_Q_reg <= Abs_Divisor_D;
        end
    end

    // Assign wire outputs from registers
    assign Count_Q = Count_Q_reg;
    assign Quotient_Q = Quotient_Q_reg;
    assign Remainder_Q = Remainder_Q_reg;
    assign Divisor_Q = Divisor_Q_reg;
    assign Dividend_Q = Dividend_Q_reg;
    assign State_Q = State_Q_reg;
    assign Done_Q = Done_Q_reg;
    assign Sign_Quotient_Q = Sign_Quotient_Q_reg;
    assign Sign_Remainder_Q = Sign_Remainder_Q_reg;
    assign Abs_Dividend_Q = Abs_Dividend_Q_reg;
    assign Abs_Divisor_Q = Abs_Divisor_Q_reg;

    function [15:0] abs_value;
        input [15:0] value;
        begin
            abs_value = value[15] ? (~value + 1) : value;
        end
    endfunction

    always @(*) begin
        case (State_Q)
            IDLE: begin
                Done_D = 1'b0;
                if (Start) begin
                    Quotient_D = 16'd0;
                    Remainder_D = 17'd0;
                    Count_D = 5'd0;
                    State_D = WORK;

                    Abs_Dividend_D = abs_value(Dividend);
                    Abs_Divisor_D = abs_value(Divisor);
                    Dividend_D = Abs_Dividend_D;
                    Divisor_D = Abs_Divisor_D;

                    Sign_Quotient_D = Dividend[15] ^ Divisor[15];

                    Sign_Remainder_D = Dividend[15];
                end else begin
                    Dividend_D = Dividend_Q;
                    Divisor_D = Divisor_Q;
                    Abs_Dividend_D = Abs_Dividend_Q;
                    Abs_Divisor_D = Abs_Divisor_Q;
                    Sign_Quotient_D = Sign_Quotient_Q;
                    Sign_Remainder_D = Sign_Remainder_Q;
                end
            end
            WORK: begin
                Done_D = 1'b0;
                Remainder_D = {Remainder_Q[15:0], Dividend_Q[15]};
                Dividend_D = {Dividend_Q[14:0], 1'b0};
                
                Divisor_D = Divisor_Q;
                Abs_Dividend_D = Abs_Dividend_Q;
                Abs_Divisor_D = Abs_Divisor_Q;
                Sign_Quotient_D = Sign_Quotient_Q;
                Sign_Remainder_D = Sign_Remainder_Q;
                
                if (Count_Q < 5'd16) begin
                    Remainder_D = Remainder_D - {1'b0, Divisor_Q};
                    if (!Remainder_D[16]) begin
                        Quotient_D = {Quotient_Q[14:0], 1'b1};
                    end else begin
                        Remainder_D = Remainder_D + {1'b0, Divisor_Q};
                        Quotient_D = {Quotient_Q[14:0], 1'b0};
                    end
                    Count_D = Count_Q + 1;
                    State_D = WORK;
                end else begin
                    State_D = DONE;
                    Done_D = 1'b1;
                    Count_D = Count_Q;
                end
            end
            DONE: begin
                Done_D = 1'b1;
                if (!Start) State_D = IDLE;
                
                Dividend_D = Dividend_Q;
                Divisor_D = Divisor_Q;
                Abs_Dividend_D = Abs_Dividend_Q;
                Abs_Divisor_D = Abs_Divisor_Q;
                Sign_Quotient_D = Sign_Quotient_Q;
                Sign_Remainder_D = Sign_Remainder_Q;
                Quotient_D = Quotient_Q;
                Remainder_D = Remainder_Q;
                Count_D = Count_Q;
            end
            default: begin
                State_D = IDLE;
                Done_D = 1'b0;
                Dividend_D = Dividend_Q;
                Divisor_D = Divisor_Q;
                Abs_Dividend_D = Abs_Dividend_Q;
                Abs_Divisor_D = Abs_Divisor_Q;
                Sign_Quotient_D = Sign_Quotient_Q;
                Sign_Remainder_D = Sign_Remainder_Q;
                Quotient_D = Quotient_Q;
                Remainder_D = Remainder_Q;
                Count_D = Count_Q;
            end
        endcase
    end
    
    always @(*) begin
        if (Sign_Quotient_Q && |Quotient_Q) begin
            Quotient = ~Quotient_Q + 1;
        end else begin
            Quotient = Quotient_Q;
        end
        
        if (Sign_Remainder_Q && |Remainder_Q[15:0]) begin
            Remainder = ~Remainder_Q[15:0] + 1;
        end else begin
            Remainder = Remainder_Q[15:0];
        end
        
        Done = Done_Q;
    end
endmodule