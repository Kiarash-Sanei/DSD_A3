module SAM #(parameter N = 8) (input Clock, Reset, Start, input [N-1:0] A, input [N-1:0] B,
    output reg [2*N-1:0] R, output reg Done);

    localparam UNKNOWN = 2'b00, START = 2'b01, RUN = 2'b10, DONE = 2'b11;
    reg [N-1:0] Multiplicand;
    reg [2*N-1:0] Multiplier;
    integer Count;
    reg State = UNKNOWN;

    always @(posedge Clock) begin
        if (Reset) begin
            R <= 0;
            Done <= 0;
            Multiplicand <= 0;
            Multiplier <= 0;
            Count <= 0;
            State <= IDLE;
        end else begin
            case (State)
                IDLE: begin
                    Done <= 0;
                    if (Start) begin
                        R <= 0;
                        Multiplicand <= A;
                        Multiplier <= { {N{1'b0}}, B };
                        Count <= N;
                        State <= RUN;
                    end
                end

                RUN: begin
                    if (Multiplier[0]) begin
                        R <= R + (Multiplicand << (N - Count));
                    end
                    Multiplier <= Multiplier >> 1;
                    Count <= Count - 1;

                    if (Count == 1) begin
                        Done <= 1;
                        State <= IDLE;
                    end
                end
            endcase
        end
    end

endmodule
