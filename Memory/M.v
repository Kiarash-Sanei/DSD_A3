module M (
    input Clock,
    input Reset,
    input Write_Enable,
    input [15:0] Write_Address,
    input [15:0] Write_Data,
    input [15:0] Read_Address,
    output [15:0] Read_Data
);
    // Reduced memory size for synthesis (16 locations instead of 65536)
    reg [15:0] mem [0:15];
    integer i;

    always @(posedge Clock or posedge Reset) begin
        if (Reset) begin
            mem[0] = 16'b0;
            mem[1] = 16'b0;
            mem[2] = 16'b0;
            mem[3] = 16'b0;
            mem[4] = 16'b0;
            mem[5] = 16'b0;
            mem[6] = 16'b0;
            mem[7] = 16'b0;
            mem[8] = 16'b0;
            mem[9] = 16'b0;
            mem[10] = 16'b0;
            mem[11] = 16'b0;
            mem[12] = 16'b0;
            mem[13] = 16'b0;
            mem[14] = 16'b0;
            mem[15] = 16'b0;
        end else if (Write_Enable && Write_Address < 15) begin
            mem[Write_Address] <= Write_Data;
        end
    end

    assign Read_Data = (Read_Address < 15) ? mem[Read_Address] : 16'b0;
endmodule 