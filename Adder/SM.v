module SM_2to1 (input [3:0] A, input [3:0] B, input S,
                output [3:0] O);
    M_2to1 m_0(.A(A[0]), .B(B[0]), .S(S), .O(O[0]));
    M_2to1 m_1(.A(A[1]), .B(B[1]), .S(S), .O(O[1]));
    M_2to1 m_2(.A(A[2]), .B(B[2]), .S(S), .O(O[2]));
    M_2to1 m_3(.A(A[3]), .B(B[3]), .S(S), .O(O[3]));
endmodule