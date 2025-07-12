module MTB;
    reg Clock;
    reg Reset;
    reg Write_Enable;
    reg [15:0] Write_Address;
    reg [15:0] Write_Data;
    reg [15:0] Read_Address;
    wire [15:0] Read_Data;

    M dut (
        .Clock(Clock),
        .Reset(Reset),
        .Write_Enable(Write_Enable),
        .Write_Address(Write_Address),
        .Write_Data(Write_Data),
        .Read_Address(Read_Address),
        .Read_Data(Read_Data)
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
        Read_Address = 0;
        Reset = 1; #20;
        Reset = 0; #10;

        for (i = 0; i < 4; i = i + 1) begin
            Read_Address = i;
            #1;
            if (Read_Data !== 16'b0) begin
                $display("[FAIL] Reset failed for mem[%0d]", i);
                $finish;
            end
        end

        for (i = 0; i < 4; i = i + 1) begin
            Write_Address = i;
            Write_Data = 16'hBEEF + i;
            Write_Enable = 1;
            #20;
            Write_Enable = 0;
            #10;
        end

        for (i = 0; i < 4; i = i + 1) begin
            Read_Address = i;
            #1;
            if (Read_Data !== (16'hBEEF + i)) begin
                $display("[FAIL] Write/Read failed for mem[%0d]: got %h, expected %h", i, Read_Data, 16'hBEEF + i);
                $finish;
            end
        end

        $display("All PASS!");
        $finish;
    end
endmodule 