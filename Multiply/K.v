module K (
    input Clock,
    input Reset,
    input Start,
    input [15:0] Multiplier,
    input [15:0] Multiplicand,
    output [31:0] Product,
    output Done
);
    localparam IDLE = 4'h0;
    localparam PRE_CALC = 4'h1;
    localparam START_MUL_Z0 = 4'h2;
    localparam WAIT_MUL_Z0 = 4'h3;
    localparam START_MUL_Z2 = 4'h4;
    localparam WAIT_MUL_Z2 = 4'h5;
    localparam START_MUL_Z1 = 4'h6;
    localparam WAIT_MUL_Z1 = 4'h7;
    localparam FINAL_CALC = 4'h8;
    localparam DONE = 4'h9;

    reg [3:0] state_reg, state_next;

    reg [7:0]  xh_reg, xl_reg, yh_reg, yl_reg;
    reg [8:0]  sum_x, sum_y;
    reg [15:0] z0_reg, z2_reg, z1_intermediate_reg;
    reg [15:0] z1_reg;
    reg [31:0] product_reg;
    reg        done_reg;

    wire [15:0] mul0_product, mul1_product, mul2_product;
    wire        mul0_done, mul1_done, mul2_done;
    reg         mul0_start, mul1_start, mul2_start;

    reg multiplier_sign, multiplicand_sign, result_sign;
    reg [15:0] abs_multiplier, abs_multiplicand;

    assign Product = product_reg;
    assign Done = done_reg;

    SAM mul0_inst (
        .Clock(Clock), .Reset(Reset), .Start(mul0_start),
        .Multiplicand(xl_reg), .Multiplier(yl_reg),
        .Product(mul0_product), .Done(mul0_done)
    );
    SAM mul2_inst (
        .Clock(Clock), .Reset(Reset), .Start(mul2_start),
        .Multiplicand(xh_reg), .Multiplier(yh_reg),
        .Product(mul2_product), .Done(mul2_done)
    );
    SAM mul1_inst (
        .Clock(Clock), .Reset(Reset), .Start(mul1_start),
        .Multiplicand(sum_x[7:0]), .Multiplier(sum_y[7:0]),
        .Product(mul1_product), .Done(mul1_done)
    );

    always @(posedge Clock or posedge Reset) begin
        if (Reset) begin
            state_reg <= IDLE;
            done_reg  <= 1'b0;
        end else begin
            state_reg <= state_next;
            if (state_next == DONE) begin
                if (result_sign)
                    product_reg <= ~unsigned_product + 1;
                else
                    product_reg <= unsigned_product;
                done_reg    <= 1'b1;
            end else if (state_reg == IDLE) begin
                done_reg <= 1'b0;
            end
        end
    end

    reg [31:0] unsigned_product;

    always @(*) begin
        state_next = state_reg;
        mul0_start = 1'b0;
        mul1_start = 1'b0;
        mul2_start = 1'b0;

        case (state_reg)
            IDLE: if (Start) state_next = PRE_CALC;
            PRE_CALC: begin
                multiplier_sign = Multiplier[15];
                multiplicand_sign = Multiplicand[15];
                abs_multiplier = multiplier_sign ? (~Multiplier + 1) : Multiplier;
                abs_multiplicand = multiplicand_sign ? (~Multiplicand + 1) : Multiplicand;
                result_sign = multiplier_sign ^ multiplicand_sign;
                xl_reg = abs_multiplier[7:0]; xh_reg = abs_multiplier[15:8];
                yl_reg = abs_multiplicand[7:0]; yh_reg = abs_multiplicand[15:8];
                sum_x = xh_reg + xl_reg; sum_y = yh_reg + yl_reg;
                state_next = START_MUL_Z0;
            end
            START_MUL_Z0: begin mul0_start = 1'b1; state_next = WAIT_MUL_Z0; end
            WAIT_MUL_Z0: if (mul0_done) begin z0_reg = mul0_product; state_next = START_MUL_Z2; end
            START_MUL_Z2: begin mul2_start = 1'b1; state_next = WAIT_MUL_Z2; end
            WAIT_MUL_Z2: if (mul2_done) begin z2_reg = mul2_product; state_next = START_MUL_Z1; end
            START_MUL_Z1: begin mul1_start = 1'b1; state_next = WAIT_MUL_Z1; end
            WAIT_MUL_Z1: if (mul1_done) begin z1_intermediate_reg = mul1_product; state_next = FINAL_CALC; end
            FINAL_CALC: begin
                z1_reg = z1_intermediate_reg - z2_reg - z0_reg;
                unsigned_product = (z2_reg << 16) + (z1_reg << 8) + z0_reg;
                state_next = DONE;
            end
            DONE: if (!Start) state_next = IDLE;
            default: state_next = IDLE;
        endcase
    end
endmodule