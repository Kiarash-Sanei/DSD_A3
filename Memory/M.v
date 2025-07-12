module M (
    input Clock,
    input Reset,
    input Write_Enable,
    input [15:0] Write_Address,
    input [15:0] Write_Data,
    input [15:0] Read_Address,
    output [15:0] Read_Data
);
    reg [15:0] mem [0:65535];
    integer i;

    always @(posedge Clock or posedge Reset) begin
        if (Reset) begin
            for (i = 0; i < 65536; i = i + 1) begin
                mem[i] <= 16'b0;
            end
        end else if (Write_Enable) begin
            mem[Write_Address] <= Write_Data;
        end
    end

    assign Read_Data = mem[Read_Address];
endmodule 