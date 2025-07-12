module DTB;
    reg Clock;
    reg Reset;
    reg Start;
    wire Done;

    D datapath (
        .Clock(Clock),
        .Reset(Reset),
        .Start(Start),
        .Done(Done)
    );

    initial begin
        Clock = 0;
        forever #5 Clock = ~Clock;
    end

    initial begin
        $display("=== Datapath Testbench Started ===");
        
        // Initialize signals
        Start = 0;
        Reset = 1;
        #20;
        // Load test program into memory BEFORE releasing reset
        datapath.memory.mem[0] = 16'b000_00_01_10_0000000; // ADD R0, R1, R2
        datapath.memory.mem[1] = 16'b101_00_01_000000001;  // STORE R0, [R1+1]
        datapath.memory.mem[2] = 16'b100_11_01_000000001;  // LOAD R3, [R1+1]
        // Initialize registers
        datapath.register_file.regfile[1] = 16'd5;  // R1 = 5
        datapath.register_file.regfile[2] = 16'd7;  // R2 = 7
        datapath.register_file.regfile[0] = 16'd0;  // R0 = 0
        datapath.register_file.regfile[3] = 16'd0;  // R3 = 0
        Reset = 0;
        #10;

        // Test 1: Basic ADD operation
        $display("Test 1: ADD operation");
        // Load test program into memory
        

        Reset = 0; #10;
        // Pulse Start to allow FETCH/DECODE
        Start = 1; #20; Start = 0; #10;
        // Now pulse Start for EXEC/WB
        Start = 1; #50;
        Start = 0;
        if (datapath.register_file.regfile[0] !== 16'd12) begin
            $display("[FAIL] ADD result incorrect: got %d, expected 12", datapath.register_file.regfile[0]);
            $finish;
        end
        $display("[PASS] Test 1 completed successfully");

        // Now continue with STORE and LOAD as before
        Start = 1;
        #150; // Let STORE and LOAD execute
        Start = 0;
        if (datapath.memory.mem[6] !== 16'd12) begin
            $display("[FAIL] STORE result incorrect: got %d, expected 12", datapath.memory.mem[6]);
            $finish;
        end
        if (datapath.register_file.regfile[3] !== 16'd12) begin
            $display("[FAIL] LOAD result incorrect: got %d, expected 12", datapath.register_file.regfile[3]);
            $finish;
        end
        $display("[PASS] STORE/LOAD completed successfully");

        // Test 2: SUB operation
        $display("Test 2: SUB operation");
        Reset = 1; #20;
        // Load test program into memory BEFORE releasing reset
        datapath.memory.mem[0] = 16'b001_00_01_10_0000000; // SUB R0, R1, R2
        datapath.register_file.regfile[1] = 16'd10; // R1 = 10
        datapath.register_file.regfile[2] = 16'd3;  // R2 = 3
        datapath.register_file.regfile[0] = 16'd0;  // R0 = 0
        Reset = 0; #10;
        Start = 1; #20; Start = 0; #10;
        Start = 1; #50;
        Start = 0;
        if (datapath.register_file.regfile[0] !== 16'd7) begin
            $display("[FAIL] SUB result incorrect: got %d, expected 7", datapath.register_file.regfile[0]);
            $finish;
        end
        $display("[PASS] Test 2 completed successfully");

        // Test 3: MUL operation
        $display("Test 3: MUL operation");
        Reset = 1; #20;
        // Load test program into memory BEFORE releasing reset
        datapath.memory.mem[0] = 16'b010_00_01_10_0000000; // MUL R0, R1, R2
        datapath.register_file.regfile[1] = 16'd6;  // R1 = 6
        datapath.register_file.regfile[2] = 16'd4;  // R2 = 4
        datapath.register_file.regfile[0] = 16'd0;  // R0 = 0
        Reset = 0; #10;
        Start = 1; #20; Start = 0; #10;
        Start = 1; #400;
        Start = 0;
        if (datapath.register_file.regfile[0] !== 16'd24) begin
            $display("[FAIL] MUL result incorrect: got %d, expected 24", datapath.register_file.regfile[0]);
            $finish;
        end
        $display("[PASS] Test 3 completed successfully");

        // Test 4: DIV operation
        $display("Test 4: DIV operation");
        Reset = 1; #20;
        // Load test program into memory BEFORE releasing reset
        datapath.memory.mem[0] = 16'b011_00_01_10_0000000; // DIV R0, R1, R2
        datapath.register_file.regfile[1] = 16'd15; // R1 = 15
        datapath.register_file.regfile[2] = 16'd3;  // R2 = 3
        datapath.register_file.regfile[0] = 16'd0;  // R0 = 0
        Reset = 0; #10;
        Start = 1; #20; Start = 0; #10;
        Start = 1; #250;
        Start = 0;
        if (datapath.register_file.regfile[0] !== 16'd5) begin
            $display("[FAIL] DIV result incorrect: got %d, expected 5", datapath.register_file.regfile[0]);
            $finish;
        end
        $display("[PASS] Test 4 completed successfully");

        $display("=== All Tests PASSED! ===");
        $finish;
    end

    initial begin
        $monitor("Time=%0t Reset=%b Start=%b Done=%b PC=%d", 
                 $time, Reset, Start, Done, datapath.control_unit.PC);
    end

endmodule 