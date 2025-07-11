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
    reg [4:0] count_reg, count_next;
    reg [15:0] quotient_reg, quotient_next;
    reg [16:0] remainder_reg, remainder_next;
    reg [15:0] divisor_reg, divisor_next;
    reg [1:0] state_reg, state_next;
    reg done_reg, done_next;
    localparam IDLE = 2'b00, WORK = 2'b01, DONE = 2'b10;
    always @(posedge Clock or posedge Reset) begin
        if (Reset) begin
            state_reg <= IDLE;
            count_reg <= 5'd0;
            quotient_reg <= 16'd0;
            remainder_reg <= 17'd0;
            divisor_reg <= 16'd0;
            done_reg <= 1'b0;
        end else begin
            state_reg <= state_next;
            count_reg <= count_next;
            quotient_reg <= quotient_next;
            remainder_reg <= remainder_next;
            divisor_reg <= divisor_next;
            done_reg <= done_next;
        end
    end
    always @(*) begin
        state_next = state_reg;
        count_next = count_reg;
        quotient_next = quotient_reg;
        remainder_next = remainder_reg;
        divisor_next = divisor_reg;
        done_next = done_reg;
        case (state_reg)
            IDLE: begin
                done_next = 1'b0;
                if (Start) begin
                    quotient_next = 16'd0;
                    remainder_next = {1'b0, Dividend};
                    divisor_next = Divisor;
                    count_next = 5'd0;
                    state_next = WORK;
                end
            end
            WORK: begin
                done_next = 1'b0;
                if (count_reg < 5'd16) begin
                    remainder_next = {remainder_reg[15:0], 1'b0};
                    remainder_next = remainder_next - {1'b0, divisor_reg};
                    if (!remainder_next[16]) begin
                        quotient_next = {quotient_reg[14:0], 1'b1};
                    end else begin
                        remainder_next = remainder_next + {1'b0, divisor_reg};
                        quotient_next = {quotient_reg[14:0], 1'b0};
                    end
                    count_next = count_reg + 1;
                end else begin
                    state_next = DONE;
                    done_next = 1'b1;
                end
            end
            DONE: begin
                done_next = 1'b1;
                if (!Start) state_next = IDLE;
            end
            default: begin
                state_next = IDLE;
                done_next = 1'b0;
            end
        endcase
    end
    always @(*) begin
        Quotient = quotient_reg;
        Remainder = remainder_reg[15:0];
        Done = done_reg;
    end
endmodule 