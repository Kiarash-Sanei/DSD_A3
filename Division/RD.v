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

    always @(*) begin
        case (State_Q)
            IDLE: begin
                Done_D = 1'b0;
                if (Start) begin
                    Quotient_D = 16'd0;
                    Remainder_D = 17'd0;
                    Divisor_D = Divisor;
                    Count_D = 5'd0;
                    State_D = WORK;
                    Dividend_D = Dividend;
                end else begin
                    Dividend_D = Dividend_Q;
                end
            end
            WORK: begin
                Done_D = 1'b0;
                // Shift in the next bit of Dividend_Q into Remainder
                Remainder_D = {Remainder_Q[15:0], Dividend_Q[15]};
                Dividend_D = {Dividend_Q[14:0], 1'b0};
                if (Count_Q < 5'd16) begin
                    Remainder_D = Remainder_D - {1'b0, Divisor_Q};
                    if (!Remainder_D[16]) begin
                        Quotient_D = {Quotient_Q[14:0], 1'b1};
                    end else begin
                        Remainder_D = Remainder_D + {1'b0, Divisor_Q};
                        Quotient_D = {Quotient_Q[14:0], 1'b0};
                    end
                    Count_D = Count_Q + 1;
                end else begin
                    State_D = DONE;
                    Done_D = 1'b1;
                end
            end
            DONE: begin
                Done_D = 1'b1;
                if (!Start) State_D = IDLE;
                Dividend_D = Dividend_Q;
            end
            default: begin
                State_D = IDLE;
                Done_D = 1'b0;
                Dividend_D = Dividend_Q;
            end
        endcase
    end
    always @(*) begin
        Quotient = Quotient_Q;
        Remainder = Remainder_Q[15:0];
        Done = Done_Q;
    end
endmodule 