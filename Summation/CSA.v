module CSA_16bit (input [15:0] A, input [15:0] B, input C_in,
                  output C_out, output [15:0] S);
    wire C_0, C_1, C_2;
    wire C_1_0, C_1_1, C_2_0, C_2_1, C_3_0, C_3_1;
    wire [3:0] S_1_0, S_1_1, S_2_0, S_2_1, S_3_0, S_3_1;

    parameter N = 4;

    A A_0(.A(A[3:0]), .B(B[3:0]), .C_in(C_in), .C_out(C_0), .S(S[3:0]));
    A A_1_0(.A(A[7:4]), .B(B[7:4]), .C_in(1'b0), .C_out(C_1_0), .S(S_1_0));
    A A_1_1(.A(A[7:4]), .B(B[7:4]), .C_in(1'b1), .C_out(C_1_1), .S(S_1_1));
    A A_2_0(.A(A[11:8]), .B(B[11:8]), .C_in(1'b0), .C_out(C_2_0), .S(S_2_0));
    A A_2_1(.A(A[11:8]), .B(B[11:8]), .C_in(1'b1), .C_out(C_2_1), .S(S_2_1));
    A A_3_0(.A(A[15:12]), .B(B[15:12]), .C_in(1'b0), .C_out(C_3_0), .S(S_3_0));
    A A_3_1(.A(A[15:12]), .B(B[15:12]), .C_in(1'b1), .C_out(C_3_1), .S(S_3_1));

    M_2to1 m_0(C_1_0, C_1_1, C_0, C_1);
    M_2to1 m_1(C_2_0, C_2_1, C_1, C_2);
    M_2to1 m_2(C_3_0, C_3_1, C_2, C_out);

    SM_2to1 sm_0(S_1_0, S_1_1, C_0, S[7:4]);
    SM_2to1 sm_1(S_2_0, S_2_1, C_1, S[11:8]);
    SM_2to1 sm_2(S_3_0, S_3_1, C_2, S[15:12]);
endmodule