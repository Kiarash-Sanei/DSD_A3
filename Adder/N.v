module N #(parameter N = 16) (input [N-1:0] A,
            output [N-1:0] B);
    genvar i;
    generate
        for (i = 0; i < N; i = i + 1) begin
            not n(B[i], A[i]);
        end
    endgenerate
endmodule