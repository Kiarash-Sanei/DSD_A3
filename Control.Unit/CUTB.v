module CUTB;
    reg Clock;
    reg Reset;

    wire [15:0] Mem_Address, Mem_Write_Data, Mem_Read_Data;
    wire Mem_Write_Enable;
    wire RF_Write_Enable;
    wire [1:0] RF_Write_Address, RF_Read_Address1, RF_Read_Address2;
    wire [15:0] RF_Write_Data, RF_Read_Data1, RF_Read_Data2;
    wire [1:0] ALUOP;
    wire [15:0] ALU_A, ALU_B, ALU_Result;
    wire ALU_Start, ALU_Done;

    CU dut (
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

    reg [15:0] memory [0:255];
    assign Mem_Read_Data = memory[Mem_Address];
    always @(posedge Clock) begin
        if (Mem_Write_Enable) begin
            memory[Mem_Address] <= Mem_Write_Data;
            $display("Memory write: addr=%d, data=%d", Mem_Address, Mem_Write_Data);
        end
    end

    reg [15:0] regfile [0:3];
    assign RF_Read_Data1 = regfile[RF_Read_Address1];
    assign RF_Read_Data2 = regfile[RF_Read_Address2];
    always @(posedge Clock) begin
        if (RF_Write_Enable) begin
            regfile[RF_Write_Address] <= RF_Write_Data;
            $display("Register write: addr=%d, data=%d", RF_Write_Address, RF_Write_Data);
        end
        $display("Register read1: addr=%d, data=%d", RF_Read_Address1, RF_Read_Data1);
        $display("Register read2: addr=%d, data=%d", RF_Read_Address2, RF_Read_Data2);
    end

    reg [15:0] alu_result;
    reg alu_done;
    assign ALU_Result = alu_result;
    assign ALU_Done = alu_done;
    always @(posedge Clock) begin
        if (ALU_Start) begin
            case (ALUOP)
                2'b00: alu_result <= ALU_A + ALU_B;
                2'b01: alu_result <= ALU_A - ALU_B;
                2'b10: alu_result <= ALU_A * ALU_B;
                2'b11: alu_result <= (ALU_B != 0) ? (ALU_A / ALU_B) : 16'b0;
            endcase
            alu_done <= 1;
        end else begin
            alu_done <= 0;
        end
    end

    initial begin
        memory[0] = 16'b000_00_01_10_0000000;
        memory[1] = 16'b101_00_01_000000001;
        memory[2] = 16'b100_11_01_000000001;
        regfile[1] = 16'd5;
        regfile[2] = 16'd7;
        regfile[0] = 0;
        regfile[3] = 0;
    end

    initial begin
        Clock = 0;
        forever #5 Clock = ~Clock;
    end

    integer i;
    initial begin
        Reset = 1; #20;
        Reset = 0; #10;
        #200;
        if (regfile[0] !== 16'd12) begin
            $display("[FAIL] ADD result incorrect: got %d, expected 12", regfile[0]);
            $finish;
        end
        if (memory[regfile[1]+1] !== 16'd12) begin
            $display("[FAIL] STORE result incorrect: got %d, expected 12", memory[regfile[1]+1]);
            $finish;
        end
        if (regfile[3] !== 16'd12) begin
            $display("[FAIL] LOAD result incorrect: got %d, expected 12", regfile[3]);
            $finish;
        end
        $display("All PASS!");
        $finish;
    end
endmodule 