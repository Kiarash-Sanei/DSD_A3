module SAM (
    input Clock, 
    input Reset, 
    input Start, 
    input [7:0] Multiplicand, 
    input [7:0] Multiplier,
    output reg [15:0] Product, 
    output reg Done
);
    localparam IDLE = 2'b00, WORK = 2'b01, DONE = 2'b10;

    reg [1:0] state_reg, state_next;
    reg [3:0] count_reg, count_next;
    reg [15:0] product_reg, product_next;
    reg [15:0] multiplicand_reg, multiplicand_next;
    reg [15:0] multiplier_reg, multiplier_next;
    reg done_reg, done_next;

    always @(posedge Clock or posedge Reset) begin
        if (Reset) begin
            state_reg <= IDLE;
            count_reg <= 4'b0;
            product_reg <= 16'b0;
            multiplicand_reg <= 16'b0;
            multiplier_reg <= 16'b0;
            done_reg <= 1'b0;
        end else begin
            state_reg <= state_next;
            count_reg <= count_next;
            product_reg <= product_next;
            multiplicand_reg <= multiplicand_next;
            multiplier_reg <= multiplier_next;
            done_reg <= done_next;
        end
    end

    always @(*) begin
        state_next = state_reg;
        count_next = count_reg;
        product_next = product_reg;
        multiplicand_next = multiplicand_reg;
        multiplier_next = multiplier_reg;
        done_next = done_reg;

        case (state_reg)
            IDLE: begin
                done_next = 1'b0;
                if (Start) begin
                    product_next = 16'd0;
                    count_next = 4'd0;
                    multiplicand_next = {8'b0, Multiplicand};
                    multiplier_next = {8'b0, Multiplier};
                    state_next = WORK;
                end
            end

            WORK: begin
                done_next = 1'b0;
                if (count_reg < 4'd8) begin
                    if (multiplier_reg[0]) begin
                        product_next = product_reg + multiplicand_reg;
                    end else begin
                        product_next = product_reg;
                    end
                    multiplicand_next = multiplicand_reg << 1;
                    multiplier_next = multiplier_reg >> 1;
                    count_next = count_reg + 1;
                end else begin
                    state_next = DONE;
                    done_next = 1'b1;
                end
            end

            DONE: begin
                done_next = 1'b1;
                if (!Start) begin
                    state_next = IDLE;
                end
            end

            default: begin
                state_next = IDLE;
                done_next = 1'b0;
            end
        endcase
    end

    always @(*) begin
        Product = product_reg;
        Done = done_reg;
    end
endmodule