module RF (
    input Clock,
    input Reset,
    input Write_Enable,
    input [1:0] Write_Address,
    input [15:0] Write_Data,
    input [1:0] Read_Address1,
    input [1:0] Read_Address2,
    output [15:0] Read_Data1,
    output [15:0] Read_Data2
);
    reg [15:0] regfile [3:0];
    integer i;

    always @(posedge Clock or posedge Reset) begin
        if (Reset) begin
            for (i = 0; i < 4; i = i + 1) begin
                regfile[i] <= 16'b0;
            end
        end else if (Write_Enable) begin
            regfile[Write_Address] <= Write_Data;
        end
    end

    assign Read_Data1 = regfile[Read_Address1];
    assign Read_Data2 = regfile[Read_Address2];
endmodule 