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
    reg [7:0] multiplier_reg, multiplier_next;
    reg done_reg, done_next;

    // Sign extension wires
    wire [15:0] multiplicand_se = {{8{Multiplicand[7]}}, Multiplicand};
    wire [15:0] multiplier_se = {{8{Multiplier[7]}}, Multiplier};

    always @(posedge Clock or posedge Reset) begin
        if (Reset) begin
            state_reg <= IDLE;
            count_reg <= 4'b0;
            product_reg <= 16'b0;
            multiplicand_reg <= 16'b0;
            multiplier_reg <= 8'b0;
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
        // Default assignments
        state_next = state_reg;
        count_next = count_reg;
        product_next = product_reg;
        multiplicand_next = multiplicand_reg;
        multiplier_next = multiplier_reg;
        done_next = 1'b0;

        case (state_reg)
            IDLE: begin
                if (Start) begin
                    product_next = 16'd0;
                    count_next = 4'd0;
                    multiplicand_next = multiplicand_se;
                    multiplier_next = Multiplier;
                    state_next = WORK;
                end
            end

            WORK: begin
                if (count_reg == 8) begin
                    state_next = DONE;
                    done_next = 1'b1;
                    
                    // Handle negative multiplier case
                    if (Multiplier[7]) begin
                        product_next = product_reg - (multiplicand_se << 8);
                    end
                end else begin
                    if (multiplier_reg[0]) begin
                        product_next = product_reg + multiplicand_reg;
                    end
                    multiplicand_next = multiplicand_reg << 1;
                    multiplier_next = multiplier_reg >> 1;
                    count_next = count_reg + 1;
                end
            end

            DONE: begin
                done_next = 1'b1;
                if (!Start) begin
                    state_next = IDLE;
                    done_next = 1'b0;
                end
            end

            default: begin
                state_next = IDLE;
            end
        endcase
    end

    // Output assignments
    always @(*) begin
        Product = product_reg;
        Done = done_reg;
    end
endmodule