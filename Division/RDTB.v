module RDTB;
    reg Clock;
    reg Reset;
    reg Start;
    reg [15:0] Dividend;
    reg [15:0] Divisor;
    wire [15:0] Quotient;
    wire [15:0] Remainder;
    wire Done;
    reg [15:0] Expected_Quotient;
    reg [15:0] Expected_Remainder;
    RD dut (
        .Clock(Clock),
        .Reset(Reset),
        .Start(Start),
        .Dividend(Dividend),
        .Divisor(Divisor),
        .Quotient(Quotient),
        .Remainder(Remainder),
        .Done(Done)
    );
    initial begin
        Clock = 0;
        forever #5 Clock = ~Clock;
    end
    initial begin
        Dividend = 16'd0;
        Divisor = 16'd1;
        Start = 1'b0;
        Reset = 1'b1; #20;
        Reset = 1'b0; #10;
        Dividend = 16'd100;
        Divisor = 16'd3;
        Start = 1'b1;
        @(posedge Clock);
        Start = 1'b0;
        @(posedge Done); #100;
        CD();
        
        Dividend = 16'd255;
        Divisor = 16'd10;
        Start = 1'b1;
        @(posedge Clock);
        Start = 1'b0;
        @(posedge Done); #100;
        CD();
        
        Dividend = 16'd65535;
        Divisor = 16'd255;
        Start = 1'b1;
        @(posedge Clock);
        Start = 1'b0;
        @(posedge Done); #100;
        CD();
        
        Dividend = 16'd12345;
        Divisor = 16'd123;
        Start = 1'b1;
        @(posedge Clock);
        Start = 1'b0;
        @(posedge Done); #100;
        CD();
        
        Dividend = 16'd32768;
        Divisor = 16'd256;
        Start = 1'b1;
        @(posedge Clock);
        Start = 1'b0;
        @(posedge Done); #100;
        CD();

        $display("All PASS!");
        $finish;
    end
    task CD ();
    begin
        Expected_Quotient = Dividend / Divisor;
        Expected_Remainder = Dividend % Divisor;
        $display("-------------------------------------------");
        $display("Inputs: Dividend = %d, Divisor = %d", Dividend, Divisor);
        $display("Output: Quotient = %d, Remainder = %d", Quotient, Remainder);
        $display("Expected: Quotient = %d, Remainder = %d", Expected_Quotient, Expected_Remainder);
        if (Quotient === Expected_Quotient && Remainder === Expected_Remainder) begin
            $display("\tResult: [PASS]");
        end else begin
            $display("\tResult: [FAIL]");
            $finish;
        end
        $display("-------------------------------------------");
    end
    endtask
endmodule 