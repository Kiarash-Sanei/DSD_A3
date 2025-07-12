module FA (input A, B, C_in,
            output C_out, S);
    wire C_0, C_1, S_0;
    HA ha_0(.A(A), .B(B), .C(C_0), .S(S_0));
    HA ha_1(.A(C_in), .B(S_0), .C(C_1), .S(S));
    or o(C_out, C_0, C_1);
endmodule