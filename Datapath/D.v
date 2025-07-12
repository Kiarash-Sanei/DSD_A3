module D (
    input Clock,
    input Reset,
    input Start,
    output Done
);
    wire [15:0] Mem_Address, Mem_Write_Data, Mem_Read_Data;
    wire Mem_Write_Enable;
    wire RF_Write_Enable;
    wire [1:0] RF_Write_Address, RF_Read_Address1, RF_Read_Address2;
    wire [15:0] RF_Write_Data, RF_Read_Data1, RF_Read_Data2;
    wire [1:0] ALUOP;
    wire [15:0] ALU_A, ALU_B, ALU_Result;
    wire ALU_Start, ALU_Done;

    CU control_unit (
        .Clock(Clock),
        .Reset(Reset),
        .Mem_Address(Mem_Address),
        .Mem_Write_Enable(Mem_Write_Enable),
        .Mem_Write_Data(Mem_Write_Data),
        .Mem_Read_Data(Mem_Read_Data),
        .RF_Write_Enable(RF_Write_Enable),
        .RF_Write_Address(RF_Write_Address),
        .RF_Write_Data(RF_Write_Data),
        .RF_Read_Address1(RF_Read_Address1),
        .RF_Read_Address2(RF_Read_Address2),
        .RF_Read_Data1(RF_Read_Data1),
        .RF_Read_Data2(RF_Read_Data2),
        .ALUOP(ALUOP),
        .ALU_A(ALU_A),
        .ALU_B(ALU_B),
        .ALU_Start(ALU_Start),
        .ALU_Result(ALU_Result),
        .ALU_Done(ALU_Done)
    );

    RF register_file (
        .Clock(Clock),
        .Reset(Reset),
        .Write_Enable(RF_Write_Enable),
        .Write_Address(RF_Write_Address),
        .Write_Data(RF_Write_Data),
        .Read_Address1(RF_Read_Address1),
        .Read_Address2(RF_Read_Address2),
        .Read_Data1(RF_Read_Data1),
        .Read_Data2(RF_Read_Data2)
    );

    M memory (
        .Clock(Clock),
        .Reset(Reset),
        .Write_Enable(Mem_Write_Enable),
        .Write_Address(Mem_Address),
        .Write_Data(Mem_Write_Data),
        .Read_Address(Mem_Address),
        .Read_Data(Mem_Read_Data)
    );

    ALU alu (
        .Clock(Clock),
        .Reset(Reset),
        .Start(ALU_Start),
        .ALUOP(ALUOP),
        .A(ALU_A),
        .B(ALU_B),
        .Result(ALU_Result),
        .Done(ALU_Done)
    );

    assign Done = Start && !Reset;

endmodule 