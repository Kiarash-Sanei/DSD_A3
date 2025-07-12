module CSATB;
    reg [15:0] A;
    reg [15:0] B;
    reg C_in;
    wire [15:0] S;
    wire C_out;
    reg [15:0] Expected_Sum;
    reg Expected_Cout;

    CSA_16bit dut (.A(A), .B(B), .C_in(C_in), .S(S), .C_out(C_out));

    initial 
    begin
        C_in = 0;

        A = 16'h0000;
        B = 16'h0000;
        #100;
        CD();

        A = 16'h1234;
        B = 16'h2345;
        #100;
        CD();

        A = 16'h000F;
        B = 16'h0001;
        #100;
        CD();

        A = 16'h0FFF;
        B = 16'h0001;
        #100;
        CD();

        A = 16'hFFFF;
        B = 16'h0001;
        #100;
        CD();

        A = 16'hFFFF;
        B = 16'hFFFF;
        #100;
        CD();

        C_in = 1;

        A = 16'h0000;
        B = 16'h0000;
        #100;
        CD();

        A = 16'h1234;
        B = 16'h2345;
        #100;
        CD();

        A = 16'h000F;
        B = 16'h0001;
        #100;
        CD();

        A = 16'h0FFF;
        B = 16'h0001;
        #100;
        CD();

        A = 16'hFFFF;
        B = 16'h0001;
        #100;
        CD();

        A = 16'hFFFF;
        B = 16'hFFFF;
        #100;
        CD();

        $display("All PASS!");
        $finish;
    end

    task CD ();
    begin
        {Expected_Cout, Expected_Sum} = A + B + C_in;

        $display("-------------------------------------------");
        $display("\tInputs: A = %h, B = %h, C_in = %b", A, B, C_in);
        $display("\tOutput: Sum = %h, C_out = %b", S, C_out);
        $display("\tExpected: Sum = %h, C_out = %b", Expected_Sum, Expected_Cout);

        if (S === Expected_Sum && C_out === Expected_Cout) begin
            $display("\tResult: [PASS]");
        end else begin
            $display("\tResult: [FAIL]");
            $finish;
        end
        $display("-------------------------------------------");
    end
    endtask

endmodule