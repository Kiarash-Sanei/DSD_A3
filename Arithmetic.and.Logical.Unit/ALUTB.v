module ALUTB;
    reg Clock;
    reg Reset;
    reg Start;
    reg [1:0] ALUOP;
    reg [15:0] A, B;
    wire [15:0] Result;
    wire Done;

    reg [15:0] Expected_Result;

    ALU alu (
        .Clock(Clock),
        .Reset(Reset),
        .Start(Start),
        .ALUOP(ALUOP),
        .A(A),
        .B(B),
        .Result(Result),
        .Done(Done)
    );

    initial begin
        Clock = 0;
        forever #5 Clock = ~Clock;
    end

    initial begin
        Start = 0;
        Reset = 1; #20;
        Reset = 0; #10;

        ALUOP = 2'b00; A = 16'd100; B = 16'd23; Start = 1;
        Expected_Result = 100 + 23;
        @(posedge Clock); Start = 0;
        #1; check_result("ADD");

        ALUOP = 2'b01; A = 16'd100; B = 16'd23; Start = 1;
        Expected_Result = 100 - 23;
        @(posedge Clock); Start = 0;
        #1; check_result("SUB");


        ALUOP = 2'b10; A = 16'd12; B = 16'd10; Start = 1;
        Expected_Result = 12 * 10;
        wait(Done); @(posedge Clock); Start = 0;
        #1; check_result("MUL");


        ALUOP = 2'b11; A = 16'd100; B = 16'd3; Start = 1;
        Expected_Result = 100 / 3;
        wait(Done); @(posedge Clock); Start = 0;
        #161; check_result("DIV");

        ALUOP = 2'b00; A = -16'sd50; B = -16'sd30; Start = 1;
        Expected_Result = -50 + (-30);
        @(posedge Clock); Start = 0;
        #1; check_result("ADD-neg");

        ALUOP = 2'b01; A = 16'd23; B = 16'd100; Start = 1;
        Expected_Result = 23 - 100;
        @(posedge Clock); Start = 0;
        #1; check_result("SUB-neg");

        ALUOP = 2'b10; A = -16'sd12; B = 16'sd10; Start = 1;
        Expected_Result = -12 * 10;
        wait(Done); @(posedge Clock); Start = 0;
        #1; check_result("MUL-neg");

        ALUOP = 2'b11; A = -16'sd100; B = 16'sd3; Start = 1;
        Expected_Result = -100 / 3;
        wait(Done); @(posedge Clock); Start = 0;
        #161; check_result("DIV-neg");

        ALUOP = 2'b00; A = 16'd0; B = 16'd0; Start = 1;
        Expected_Result = 0 + 0;
        @(posedge Clock); Start = 0;
        #1; check_result("ADD-zero");

        ALUOP = 2'b01; A = 16'd0; B = 16'd0; Start = 1;
        Expected_Result = 0 - 0;
        @(posedge Clock); Start = 0;
        #1; check_result("SUB-zero");

        ALUOP = 2'b10; A = 16'd0; B = 16'd15; Start = 1;
        Expected_Result = 0 * 15;
        wait(Done); @(posedge Clock); Start = 0;
        #1; check_result("MUL-zero");

        ALUOP = 2'b11; A = 16'd0; B = 16'd5; Start = 1;
        Expected_Result = 0 / 5;
        wait(Done); @(posedge Clock); Start = 0;
        #161; check_result("DIV-zero");

        ALUOP = 2'b00; A = 16'd32767; B = 16'd1; Start = 1;
        Expected_Result = 32767 + 1;
        @(posedge Clock); Start = 0;
        #1; check_result("ADD-max");

        ALUOP = 2'b10; A = 16'd255; B = 16'd255; Start = 1;
        Expected_Result = 255 * 255;
        wait(Done); @(posedge Clock); Start = 0;
        #1; check_result("MUL-large");

        ALUOP = 2'b11; A = 16'd32767; B = 16'd1; Start = 1;
        Expected_Result = 32767 / 1;
        wait(Done); @(posedge Clock); Start = 0;
        #161; check_result("DIV-by-one");

        ALUOP = 2'b00; A = 16'd123; B = -16'sd456; Start = 1;
        Expected_Result = 123 + (-456);
        @(posedge Clock); Start = 0;
        #1; check_result("ADD-mixed");

        ALUOP = 2'b01; A = -16'sd789; B = -16'sd123; Start = 1;
        Expected_Result = -789 - (-123);
        @(posedge Clock); Start = 0;
        #1; check_result("SUB-mixed");

        ALUOP = 2'b10; A = -16'sd25; B = -16'sd4; Start = 1;
        Expected_Result = -25 * (-4);
        wait(Done); @(posedge Clock); Start = 0;
        #1; check_result("MUL-both-neg");

        ALUOP = 2'b11; A = 16'd1000; B = -16'sd5; Start = 1;
        Expected_Result = 1000 / (-5);
        wait(Done); @(posedge Clock); Start = 0;
        #161; check_result("DIV-neg-divisor");

        ALUOP = 2'b00; A = 16'd1; B = 16'd1; Start = 1;
        Expected_Result = 1 + 1;
        @(posedge Clock); Start = 0;
        #1; check_result("ADD-small");

        ALUOP = 2'b01; A = 16'd1; B = 16'd1; Start = 1;
        Expected_Result = 1 - 1;
        @(posedge Clock); Start = 0;
        #1; check_result("SUB-small");

        ALUOP = 2'b10; A = 16'd1; B = 16'd1; Start = 1;
        Expected_Result = 1 * 1;
        wait(Done); @(posedge Clock); Start = 0;
        #1; check_result("MUL-small");

        ALUOP = 2'b11; A = 16'd1; B = 16'd1; Start = 1;
        Expected_Result = 1 / 1;
        wait(Done); @(posedge Clock); Start = 0;
        #161; check_result("DIV-small");

        $display("All PASS!");
        $finish;
    end

    task check_result;
        input [127:0] op_name;
        begin
            $display("-------------------------------------------");
            $display("%s: A = %d, B = %d", op_name, $signed(A), $signed(B));
            $display("Output: Result = %d", $signed(Result));
            $display("Expected: Result = %d", $signed(Expected_Result));
            if (Result === Expected_Result) begin
                $display("\tResult: [PASS]");
            end else begin
                $display("\tResult: [FAIL]");
                $finish;
            end
            $display("-------------------------------------------");
        end
    endtask
endmodule 