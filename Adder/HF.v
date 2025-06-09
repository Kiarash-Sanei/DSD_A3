module HA (input A, B,
            output C, S);
    and a(C, A, B);
    xor x(S, A, B);
endmodule