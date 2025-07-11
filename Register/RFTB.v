module RFTB;
    reg Clock;
    reg Reset;
    reg Write_Enable;
    reg [1:0] Write_Address;
    reg [15:0] Write_Data;
    reg [1:0] Read_Address1, Read_Address2;
    wire [15:0] Read_Data1, Read_Data2;

    RF dut (
        .Clock(Clock),
        .Reset(Reset),
        .Write_Enable(Write_Enable),
        .Write_Address(Write_Address),
        .Write_Data(Write_Data),
        .Read_Address1(Read_Address1),
        .Read_Address2(Read_Address2),
        .Read_Data1(Read_Data1),
        .Read_Data2(Read_Data2)
    );

    initial begin
        Clock = 0;
        forever #5 Clock = ~Clock;
    end

    integer i;

    initial begin
        Write_Enable = 0;
        Write_Address = 0;
        Write_Data = 0;
        Read_Address1 = 0;
        Read_Address2 = 0;
        Reset = 1; #20;
        Reset = 0; #10;

        for (i = 0; i < 4; i = i + 1) begin
            Read_Address1 = i;
            #1;
            if (Read_Data1 !== 16'b0) begin
                $display("[FAIL] Reset failed for reg %0d", i);
                $finish;
            end
        end

        for (i = 0; i < 4; i = i + 1) begin
            Write_Address = i;
            Write_Data = 16'hA0A0 + i;
            Write_Enable = 1;
            #20;
            Write_Enable = 0;
            #10;
        end

        for (i = 0; i < 4; i = i + 1) begin
            Read_Address1 = i;
            #1;
            if (Read_Data1 !== (16'hA0A0 + i)) begin
                $display("[FAIL] Write/Read failed for reg %0d: got %h, expected %h", i, Read_Data1, 16'hA0A0 + i);
                $finish;
            end
        end

        for (i = 0; i < 4; i = i + 1) begin
            Read_Address2 = i;
            #1;
            if (Read_Data2 !== (16'hA0A0 + i)) begin
                $display("[FAIL] Write/Read failed for reg %0d: got %h, expected %h", i, Read_Data2, 16'hA0A0 + i);
                $finish;
            end
        end

        Read_Address1 = 1;
        Read_Address2 = 2;
        #1;
        if (Read_Data1 !== 16'hA0A1 || Read_Data2 !== 16'hA0A2) begin
            $display("[FAIL] Dual read failed: got %h and %h", Read_Data1, Read_Data2);
            $finish;
        end

        $display("All PASS!");
        $finish;
    end
endmodule 