module DFF #(parameter N = 8) (input Clock, Reset, Enable, input [N-1:0] D,
            output reg [N-1:0] Q);
    always @(posedge Clock or posedge Reset) begin
        if (Reset) begin
            Q <= {N{1'b0}}; 
        end else if (Enable) begin
            Q <= D;
        end
    end
endmodule