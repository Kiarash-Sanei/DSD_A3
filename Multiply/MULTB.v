//-----------------------------------------------------------------------------
// Module: tb_shift_add_multiplier
// Description: Testbench for the 8x8 shift-and-add multiplier.
//-----------------------------------------------------------------------------
`timescale 1ns/1ps

module tb_shift_add_multiplier;

reg          clk;
reg          rst_n;
reg          start;
reg   [7:0]  multiplicand;
reg   [7:0]  multiplier;

// DUT Outputs
wire  [15:0] product;
wire         done;

localparam UNKNOWN = 2'b00;
localparam START = 2'b01;
localparam RUN = 2'b10;
localparam DONE = 2'b11;

SAM #(8) uut (
    .Clock(clk),
    .Reset(~rst_n),
    .Start(start),
    .A(multiplicand),
    .B(multiplier),
    .R(product),
    .Done(done)
);


// Clock generator
initial begin
    clk = 0;
    forever #5 clk = ~clk; // 100 MHz clock
end

// Test sequence
initial begin
    // 1. Initialize and Reset
    $display("Starting simulation...");
    multiplicand = 8'd0;
    multiplier   = 8'd0;
    start        = 1'b0;
    rst_n        = 1'b0;
    #20;
    rst_n        = 1'b1;
    #10;

    // 2. Test Case 1: 12 * 10
    $display("Test Case 1: 12 * 10");
    multiplicand = 8'd12;
    multiplier   = 8'd10;
    start        = 1'b1;
    @(posedge clk);
    start        = 1'b0;
    @(done); // Wait for the done signal
    $display("Multiplicand = %d, Multiplier = %d", multiplicand, multiplier);
    $display("Product = %d (Expected = 120)", product);
    if (product == 120) $display("Test Case 1 PASSED!");
    else $display("Test Case 1 FAILED!");
    #20;

    // 3. Test Case 2: 150 * 0
    $display("\nTest Case 2: 150 * 0");
    multiplicand = 8'd150;
    multiplier   = 8'd0;
    start        = 1'b1;
    @(posedge clk);
    start        = 1'b0;

    @(posedge done);
    $display("Multiplicand = %d, Multiplier = %d", multiplicand, multiplier);
    $display("Product = %d (Expected = 0)", product);
     if (product == 0) $display("Test Case 2 PASSED!");
    else $display("Test Case 2 FAILED!");
    #20;

    // 4. Test Case 3: 255 * 250
    $display("\nTest Case 3: 255 * 250");
    multiplicand = 8'd255;
    multiplier   = 8'd250;
    start        = 1'b1;
    @(posedge clk);
    start        = 1'b0;

    @(posedge done);
    $display("Multiplicand = %d, Multiplier = %d", multiplicand, multiplier);
    $display("Product = %d (Expected = 63750)", product);
    if (product == 63750) $display("Test Case 3 PASSED!");
    else $display("Test Case 3 FAILED!");
    #20;

    // End simulation
    $display("\nSimulation finished.");
    $finish;
end

endmodule