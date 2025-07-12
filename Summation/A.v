module A #(parameter N = 4) (input [N-1:0] A, input [N-1:0] B, input C_in,
            output C_out, output [N-1:0] S);
    wire [N:0] C;
    assign C[0] = C_in;
    assign C_out = C[N];

    genvar i;
    generate
        for (i = 0; i < N; i = i + 1) begin
            FA fa (.A(A[i]), .B(B[i]), .C_in(C[i]), .C_out(C[i+1]), .S(S[i]));
        end
    endgenerate
endmodule