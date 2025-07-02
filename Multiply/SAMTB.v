module SAMTB;
    reg Clock;
    reg Reset;
    reg Start;
    reg [7:0] Multiplicand;
    reg [7:0] Multiplier;
    wire [15:0] Product;
    wire Done;

    reg [15:0] Expected_Product;

    SAM sam (
        .Clock(Clock),
        .Reset(Reset),
        .Start(Start),
        .Multiplicand(Multiplicand),
        .Multiplier(Multiplier),
        .Product(Product),
        .Done(Done)
    );

    initial 
    begin
        Clock = 0;
        forever #5 Clock = ~Clock;
    end

    initial begin
        Multiplicand = 8'd0;
        Multiplier = 8'd0;
        Start = 1'b0;
        Reset = 1'b1; #20;
        Reset = 1'b0; #10;

        Multiplicand = 8'd12;
        Multiplier = 8'd10;
        Start = 1'b1;
        @(posedge Clock);
        Start = 1'b0;
        @(posedge Done); #100;
        CD();

        Multiplicand = 8'd150;
        Multiplier = 8'd0;
        Start = 1'b1;
        @(posedge Clock);
        Start = 1'b0;
        @(posedge Done); #100;
        CD();

        Multiplicand = 8'd150;
        Multiplier = 8'd2;
        Start = 1'b1;
        @(posedge Clock);
        Start = 1'b0;
        @(posedge Done); #100;
        CD();

        Multiplicand = 8'd255;
        Multiplier = 8'd250;
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
        Expected_Product = $signed(Multiplicand) * $signed(Multiplier);

        $display("-------------------------------------------");
        $display("Inputs: Multiplicand = %d, Multiplier = %d", $signed(Multiplicand), $signed(Multiplier));
        $display("Output: Product = %d", $signed(Product));
        $display("Expected: Product = %d", $signed(Expected_Product));

        if (Product === Expected_Product) begin
            $display("\tResult: [PASS]");
        end else begin
            $display("\tResult: [FAIL]");
            $finish;
        end
        $display("-------------------------------------------");
    end
    endtask
endmodule