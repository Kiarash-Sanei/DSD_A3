module M_2to1 (input A, B, S,
               output O);
    wire S_not, I_0, I_1;
    not n(S_not, S);
    and a_0(I_0, A, S_not);
    and a_1(I_1, B, S);
    or o(O, I_0, I_1);
endmodule