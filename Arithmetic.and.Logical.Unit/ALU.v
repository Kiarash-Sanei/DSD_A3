module ALU (
    input Clock,
    input Reset,
    input Start,
    input [1:0] ALUOP, // 00: ADD, 01: SUB, 10: MUL, 11: DIV
    input [15:0] A,
    input [15:0] B,
    output reg [15:0] Result,
    output reg Done
);
    wire [15:0] add_sum, sub_sum;
    wire add_cout, sub_cout;
    wire [31:0] mul_product;
    wire [15:0] div_quotient;
    wire [15:0] div_remainder;
    wire add_done, sub_done, mul_done, div_done;

    CSA_16bit adder (
        .A(A), .B(B), .C_in(1'b0), .C_out(add_cout), .S(add_sum)
    );
    assign add_done = Start;

    CSA_16bit subtractor (
        .A(A), .B(~B), .C_in(1'b1), .C_out(sub_cout), .S(sub_sum)
    );
    assign sub_done = Start;

    wire mul_start = (ALUOP == 2'b10) && Start;
    wire mul_done_wire;
    K multiplier (
        .Clock(Clock), .Reset(Reset), .Start(mul_start),
        .Multiplicand(A), .Multiplier(B),
        .Product(mul_product), .Done(mul_done_wire)
    );

    wire div_start = (ALUOP == 2'b11) && Start;
    wire div_done_wire;
    RD divider (
        .Clock(Clock), .Reset(Reset), .Start(div_start),
        .Dividend(A), .Divisor(B),
        .Quotient(div_quotient), .Remainder(div_remainder), .Done(div_done_wire)
    );

    reg [1:0] state;
    localparam S_IDLE = 2'b00, S_WAIT = 2'b01, S_DONE = 2'b10;

    always @(posedge Clock or posedge Reset) begin
        if (Reset) begin
            state <= S_IDLE;
            Done <= 1'b0;
        end else begin
            case (state)
                S_IDLE: begin
                    Done <= 1'b0;
                    if (Start) begin
                        if (ALUOP == 2'b10 || ALUOP == 2'b11)
                            state <= S_WAIT;
                        else
                            state <= S_DONE;
                    end
                end
                S_WAIT: begin
                    if ((ALUOP == 2'b10 && mul_done_wire) || (ALUOP == 2'b11 && div_done_wire))
                        state <= S_DONE;
                end
                S_DONE: begin
                    Done <= 1'b1;
                    if (!Start) state <= S_IDLE;
                end
            endcase
        end
    end

    always @(*) begin
        case (ALUOP)
            2'b00: Result = {16'b0, add_sum}; // ADD
            2'b01: Result = {16'b0, sub_sum}; // SUB
            2'b10: Result = mul_product;      // MUL
            2'b11: Result = {16'b0, div_quotient}; // DIV (remainder ignored)
            default: Result = 32'b0;
        endcase
    end
endmodule 