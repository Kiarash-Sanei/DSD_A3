module TC (input [15:0] A, 
            output [15:0] B);
    parameter N = 16;
    wire [15:0] C;

    N #(.N(N)) n(.A(A), .B(C));
    CSA_16bit csa(.A(C), .B(16'h0001), .S(B));
endmodule