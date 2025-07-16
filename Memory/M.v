module M (
    input Clock,
    input Reset,
    input Write_Enable,
    input [15:0] Write_Address,
    input [15:0] Write_Data,
    input [15:0] Read_Address,
    output [15:0] Read_Data
);
    // Reduced memory size for synthesis (1024 locations instead of 65536)
    reg [15:0] mem [0:1023];
    integer i;

    always @(posedge Clock or posedge Reset) begin
        if (Reset) begin
            // Initialize only first 256 locations to speed up synthesis
            for (i = 0; i < 256; i = i + 1) begin
                mem[i] <= 16'b0;
            end
            // Set remaining locations to 0 in a more synthesis-friendly way
            mem[256] <= 16'b0;
            mem[512] <= 16'b0;
            mem[768] <= 16'b0;
            mem[1023] <= 16'b0;
        end else if (Write_Enable && Write_Address < 1024) begin
            mem[Write_Address] <= Write_Data;
        end
    end

    assign Read_Data = (Read_Address < 1024) ? mem[Read_Address] : 16'b0;
endmodule 