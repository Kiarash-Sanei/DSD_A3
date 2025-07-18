module A (input [3:0] A, input [3:0] B, input C_in,
            output C_out, output [3:0] S);
    wire [4:0] C;
    assign C[0] = C_in;
    assign C_out = C[4];

    FA fa_0(.A(A[0]), .B(B[0]), .C_in(C[0]), .C_out(C[1]), .S(S[0]));
    FA fa_1(.A(A[1]), .B(B[1]), .C_in(C[1]), .C_out(C[2]), .S(S[1]));
    FA fa_2(.A(A[2]), .B(B[2]), .C_in(C[2]), .C_out(C[3]), .S(S[2]));
    FA fa_3(.A(A[3]), .B(B[3]), .C_in(C[3]), .C_out(C[4]), .S(S[3]));
endmodule