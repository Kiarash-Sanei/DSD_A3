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

    DFF #(.N(5)) count_dff(
        .Clock(Clock), 
        .Reset(Reset), 
        .Enable(1'b1), 
        .D(Count_D), 
        .Q(Count_Q)
    );
    DFF #(.N(16)) quotient_dff(
        .Clock(Clock), 
        .Reset(Reset), 
        .Enable(1'b1), 
        .D(Quotient_D), 
        .Q(Quotient_Q)
    );
    DFF #(.N(17)) remainder_dff(
        .Clock(Clock),
        .Reset(Reset),
        .Enable(1'b1),
        .D(Remainder_D),
        .Q(Remainder_Q)
    );
    DFF #(.N(16)) divisor_dff(
        .Clock(Clock),
        .Reset(Reset),
        .Enable(1'b1),
        .D(Divisor_D),
        .Q(Divisor_Q)
    );
    DFF #(.N(16)) dividend_dff(
        .Clock(Clock),
        .Reset(Reset),
        .Enable(1'b1),
        .D(Dividend_D),
        .Q(Dividend_Q)
    );
    DFF #(.N(2)) state_dff(
        .Clock(Clock), 
        .Reset(Reset), 
        .Enable(1'b1), 
        .D(State_D), 
        .Q(State_Q)
    );
    DFF #(.N(1)) done_dff(
        .Clock(Clock), 
        .Reset(Reset), 
        .Enable(1'b1), 
        .D(Done_D), 
        .Q(Done_Q)
    );
    DFF #(.N(1)) sign_quotient_dff(
        .Clock(Clock), 
        .Reset(Reset), 
        .Enable(1'b1), 
        .D(Sign_Quotient_D), 
        .Q(Sign_Quotient_Q)
    );
    DFF #(.N(1)) sign_remainder_dff(
        .Clock(Clock), 
        .Reset(Reset), 
        .Enable(1'b1), 
        .D(Sign_Remainder_D), 
        .Q(Sign_Remainder_Q)
    );
    DFF #(.N(16)) abs_dividend_dff(
        .Clock(Clock),
        .Reset(Reset),
        .Enable(1'b1),
        .D(Abs_Dividend_D),
        .Q(Abs_Dividend_Q)
    );
    DFF #(.N(16)) abs_divisor_dff(
        .Clock(Clock),
        .Reset(Reset),
        .Enable(1'b1),
        .D(Abs_Divisor_D),
        .Q(Abs_Divisor_Q)
    );

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