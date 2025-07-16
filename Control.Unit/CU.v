module CU (
    input Clock,
    input Reset,
    // Memory interface
    output reg [15:0] Mem_Address,
    output reg Mem_Write_Enable,
    output reg [15:0] Mem_Write_Data,
    input [15:0] Mem_Read_Data,
    // Register File interface
    output reg RF_Write_Enable,
    output reg [1:0] RF_Write_Address,
    output reg [15:0] RF_Write_Data,
    output reg [1:0] RF_Read_Address1,
    output reg [1:0] RF_Read_Address2,
    input [15:0] RF_Read_Data1,
    input [15:0] RF_Read_Data2,
    // ALU interface
    output reg [1:0] ALUOP,
    output reg [15:0] ALU_A,
    output reg [15:0] ALU_B,
    output reg ALU_Start,
    input [15:0] ALU_Result,
    input ALU_Done
);
    // State encoding
    localparam FETCH = 3'd0, DECODE = 3'd1, EXEC = 3'd2, MEM = 3'd3, WB = 3'd4, HALT = 3'd5;
    reg [2:0] state, next_state;

    reg [15:0] PC, next_PC;
    reg [15:0] IR, next_IR; // Instruction Register
    reg [2:0] opcode;
    reg [1:0] rd, rs1, rs2, base;
    reg [8:0] address;
    reg [15:0] alu_result_buf, next_alu_result_buf;
    reg [15:0] mem_data_buf, next_mem_data_buf;
    reg [15:0] sign_ext_addr;
    reg is_rtype, is_mtype;

    // Control signals for sequential assignments
    reg load_IR, load_PC, load_alu_result, load_mem_data;
    reg inc_PC;

    // Pipeline registers for base and offset
    reg [15:0] base_val, next_base_val;
    reg [15:0] offset_val, next_offset_val;

    // Instruction decode
    always @(*) begin
        opcode = IR[15:13];
        rd = IR[12:11];
        rs1 = IR[10:9];
        rs2 = IR[8:7];
        // Fix for M-type
        base = IR[10:9];
        address = IR[8:0];
        is_rtype = (opcode <= 3'b011);
        is_mtype = (opcode >= 3'b100);
        sign_ext_addr = {{7{address[8]}}, address};
    end

    // Combinational control logic
    always @(*) begin
        // Default values
        Mem_Write_Enable = 0;
        RF_Write_Enable = 0;
        ALU_Start = 0;
        Mem_Address = 0;
        Mem_Write_Data = 0;
        RF_Write_Address = 0;
        RF_Write_Data = 0;
        RF_Read_Address1 = 0;
        RF_Read_Address2 = 0;
        ALUOP = 0;
        ALU_A = 0;
        ALU_B = 0;
        next_state = state;
        load_IR = 0;
        load_PC = 0;
        load_alu_result = 0;
        load_mem_data = 0;
        inc_PC = 0;
        next_base_val = base_val;
        next_offset_val = offset_val;
        case (state)
            FETCH: begin
                Mem_Address = PC;
                next_state = DECODE;
                load_IR = 1;
            end
            DECODE: begin
                next_state = EXEC;
            end
            EXEC: begin
                if (is_rtype) begin
                    // R-Type: ADD, SUB, MUL, DIV
                    RF_Read_Address1 = rs1;
                    RF_Read_Address2 = rs2;
                    ALU_A = RF_Read_Data1;
                    ALU_B = RF_Read_Data2;
                    ALUOP = opcode[1:0];
                    ALU_Start = 1;
                    if (ALU_Done) begin
                        load_alu_result = 1;
                        next_state = WB;
                    end else begin
                        next_state = EXEC;
                    end
                end else if (is_mtype) begin
                    // M-Type: LOAD, STORE
                    RF_Read_Address1 = base;
                    if (opcode == 3'b100) begin // LOAD
                        next_base_val = RF_Read_Data1;
                        next_offset_val = sign_ext_addr;
                        next_state = MEM;
                    end else if (opcode == 3'b101) begin // STORE
                        RF_Read_Address2 = rd; // reg to store
                        next_base_val = RF_Read_Data1;
                        next_offset_val = sign_ext_addr;
                        next_state = MEM;
                    end
                end
            end
            MEM: begin
                if (opcode == 3'b100) begin // LOAD
                    Mem_Address = base_val + offset_val;
                    load_mem_data = 1;
                    next_state = WB;
                end else if (opcode == 3'b101) begin // STORE
                    Mem_Address = base_val + offset_val;
                    Mem_Write_Data = RF_Read_Data2;
                    Mem_Write_Enable = 1;
                    inc_PC = 1;
                    next_state = FETCH;
                end
            end
            WB: begin
                if (is_rtype) begin
                    RF_Write_Enable = 1;
                    RF_Write_Address = rd;
                    RF_Write_Data = alu_result_buf;
                end else if (opcode == 3'b100) begin // LOAD
                    RF_Write_Enable = 1;
                    RF_Write_Address = rd;
                    RF_Write_Data = mem_data_buf;
                end
                inc_PC = 1;
                next_state = FETCH;
            end
            default: next_state = FETCH;
        endcase
    end

    // Sequential logic
    always @(posedge Clock or posedge Reset) begin
        if (Reset) begin
            state <= FETCH;
            PC <= 0;
            IR <= 0;
            alu_result_buf <= 0;
            mem_data_buf <= 0;
            base_val <= 0;
            offset_val <= 0;
        end else begin
            state <= next_state;
            if (load_IR) IR <= Mem_Read_Data;
            if (load_alu_result) alu_result_buf <= ALU_Result;
            if (load_mem_data) mem_data_buf <= Mem_Read_Data;
            if (inc_PC) PC <= PC + 1;
            base_val <= next_base_val;
            offset_val <= next_offset_val;
        end
    end
endmodule 