`timescale 1ns / 1ps

module Carry_Select_Adder_tb;

    // Inputs to the DUT (Device Under Test)
    reg  [15:0] A;

    // Outputs from the DUT
    wire [15:0] Sum;

    // --- FIX: Variables moved from task to module scope ---
    // These regs will be used by the checking task.
    reg [15:0] expected_sum;

    // Instantiate the Carry Select Adder module
    // Instantiate the Carry Select Adder module
    TC dut (
        .A(A),
        .B(Sum)
    );


    // Initial block to apply test vectors (this part is unchanged)
    initial begin
        // --- Test 1: Zero inputs ---
        A = 16'h0000;
        #10; // Wait for logic to settle
        check_and_display("Test 1: Zero Inputs");

        // --- Test 2: Simple addition, no carry out ---
        A = 16'h1234;
        #10;
        check_and_display("Test 2: Simple Addition");

        // --- Test 3: Test carry propagation within the first block ---
        A = 16'h000F;
        #10;
        check_and_display("Test 3: Carry within a block");

        // --- Test 4: Test carry propagation across multiple blocks ---
        A = 16'h0FFF;
        #10;
        check_and_display("Test 4: Carry across blocks");

        // --- Test 5: Maximum values, resulting in a carry out ---
        A = 16'hFFFF;
        #10;
        check_and_display("Test 5: Max value + 1");

        // --- Test 6: Both inputs are max values ---
        A = 16'hFFFF;
        #10;
        check_and_display("Test 6: Max value + Max value");
        
        $finish; // End simulation
    end

    // --- FIX: Task no longer contains local variable declarations ---
    task check_and_display (input [8*25:1] test_name);
    begin
        expected_sum = ~A + 1;

        $display("-------------------------------------------");
        $display("%s", test_name);
        $display("  Input:      A = %h", A);
        $display("  Output:  Sum = %h", Sum);
        $display("  Expected:    Sum = %h", expected_sum);

        if (Sum === expected_sum) begin
            $display("  Result: [PASS]");
        end else begin
            $display("  Result: [FAIL] <<<<<<<");
        end
        $display("-------------------------------------------");
    end
    endtask

endmodule