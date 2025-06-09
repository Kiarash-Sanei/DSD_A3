`timescale 1ns / 1ps

module Carry_Select_Adder_tb;

    // Inputs to the DUT (Device Under Test)
    reg  [15:0] A;
    reg  [15:0] B;

    // Outputs from the DUT
    wire [15:0] Sum;
    wire        Cout;

    // --- FIX: Variables moved from task to module scope ---
    // These regs will be used by the checking task.
    reg [15:0] expected_sum;
    reg        expected_cout;

    // Instantiate the Carry Select Adder module
    // Instantiate the Carry Select Adder module
    CSA_16bit dut (
        .A(A),
        .B(B),
        .S(Sum),
        .C_out(Cout)
    );


    // Initial block to apply test vectors (this part is unchanged)
    initial begin
        // --- Test 1: Zero inputs ---
        A = 16'h0000;
        B = 16'h0000;
        #10; // Wait for logic to settle
        check_and_display("Test 1: Zero Inputs");

        // --- Test 2: Simple addition, no carry out ---
        A = 16'h1234;
        B = 16'h2345;
        #10;
        check_and_display("Test 2: Simple Addition");

        // --- Test 3: Test carry propagation within the first block ---
        A = 16'h000F;
        B = 16'h0001;
        #10;
        check_and_display("Test 3: Carry within a block");

        // --- Test 4: Test carry propagation across multiple blocks ---
        A = 16'h0FFF;
        B = 16'h0001;
        #10;
        check_and_display("Test 4: Carry across blocks");

        // --- Test 5: Maximum values, resulting in a carry out ---
        A = 16'hFFFF;
        B = 16'h0001;
        #10;
        check_and_display("Test 5: Max value + 1");

        // --- Test 6: Both inputs are max values ---
        A = 16'hFFFF;
        B = 16'hFFFF;
        #10;
        check_and_display("Test 6: Max value + Max value");
        
        $finish; // End simulation
    end

    // --- FIX: Task no longer contains local variable declarations ---
    task check_and_display (input [8*25:1] test_name);
    begin
        // The 'reg' declarations were removed from here.

        // Golden Model: Use Verilog's built-in addition to get the expected result
        // It now assigns to the module-level variables.
        {expected_cout, expected_sum} = A + B;

        $display("-------------------------------------------");
        $display("%s", test_name);
        $display("  Inputs:      A = %h, B = %h", A, B);
        $display("  DUT Output:  Sum = %h, Cout = %b", Sum, Cout);
        $display("  Expected:    Sum = %h, Cout = %b", expected_sum, expected_cout);

        if (Sum === expected_sum && Cout === expected_cout) begin
            $display("  Result: [PASS]");
        end else begin
            $display("  Result: [FAIL] <<<<<<<");
        end
        $display("-------------------------------------------");
    end
    endtask

endmodule