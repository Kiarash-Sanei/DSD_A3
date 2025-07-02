module K (
    input Clock, Reset, Start,
    input [15:0] Multiplicand,
    input [15:0] Multiplier,
    output reg [31:0] Product,
    output reg Done
);

    localparam IDLE = 4'b0000, PRECALCULATION = 4'b0001, 
               START_Z0 = 4'b0010, WAIT_Z0 = 4'b0011, 
               START_Z1 = 4'b0100, WAIT_Z1 = 4'b0101, 
               START_Z2 = 4'b0110, WAIT_Z2 = 4'b0111, 
               FINAL_CALCULATION = 4'b1000, DONE = 4'b1001,
               ZERO_CASE = 4'b1010;

    reg [3:0] State_reg, State_next;
    
    reg [15:0] z0_reg, z2_reg;
    reg [16:0] z1_reg;
    
    reg [8:0] x_sum, y_sum;
    
    wire [15:0] Product_0, Product_1, Product_2;
    wire Done_0, Done_1, Done_2;
    reg Start_0, Start_1, Start_2;

    SAM sam_0 (
        .Clock(Clock),
        .Reset(Reset),
        .Start(Start_0),
        .Multiplicand(Multiplicand[7:0]),
        .Multiplier(Multiplier[7:0]),
        .Product(Product_0),
        .Done(Done_0)
    );
    
    SAM sam_1 (
        .Clock(Clock),
        .Reset(Reset),
        .Start(Start_1),
        .Multiplicand(Multiplicand[15:8]),
        .Multiplier(Multiplier[15:8]),
        .Product(Product_1),
        .Done(Done_1)
    );
    
    SAM sam_2 (
        .Clock(Clock),
        .Reset(Reset),
        .Start(Start_2),
        .Multiplicand(x_sum[7:0]),
        .Multiplier(y_sum[7:0]),
        .Product(Product_2),
        .Done(Done_2)
    );

    always @(posedge Clock or posedge Reset) begin
        if (Reset) begin
            State_reg <= IDLE;
            Done <= 1'b0;
            Product <= 32'b0;
            z0_reg <= 16'b0;
            z1_reg <= 17'b0;
            z2_reg <= 16'b0;
            x_sum <= 9'b0;
            y_sum <= 9'b0;
        end else begin
            State_reg <= State_next;
            
            case (State_reg)
                PRECALCULATION: begin
                    x_sum <= {1'b0, Multiplicand[15:8]} + {1'b0, Multiplicand[7:0]};
                    y_sum <= {1'b0, Multiplier[15:8]} + {1'b0, Multiplier[7:0]};
                end
                
                WAIT_Z0: begin
                    if (Done_0) begin
                        z0_reg <= Product_0;
                    end
                end
                
                WAIT_Z1: begin
                    if (Done_1) begin
                        z2_reg <= Product_1;
                    end
                end
                
                WAIT_Z2: begin
                    if (Done_2) begin
                        z1_reg <= {1'b0, Product_2} - {1'b0, z0_reg} - {1'b0, z2_reg};
                    end
                end
                
                FINAL_CALCULATION: begin
                    Product <= ({16'b0, z2_reg} << 16) + ({15'b0, z1_reg} << 8) + {16'b0, z0_reg};
                    Done <= 1'b1;
                end
                
                ZERO_CASE: begin
                    Product <= 32'b0;
                    Done <= 1'b1;
                end
                
                IDLE: begin
                    if (Start) begin
                        Done <= 1'b0;
                    end
                end
            endcase
        end
    end

    always @(*) begin
        State_next = State_reg;
        Start_0 = 1'b0;
        Start_1 = 1'b0;
        Start_2 = 1'b0;
        
        case (State_reg)
            IDLE: begin
                if (Start) begin
                    if (Multiplicand == 16'b0 || Multiplier == 16'b0) begin
                        State_next = ZERO_CASE;
                    end else begin
                        State_next = PRECALCULATION;
                    end
                end
            end
            
            PRECALCULATION: begin
                State_next = START_Z0;
            end
            
            START_Z0: begin
                Start_0 = 1'b1;
                State_next = WAIT_Z0;
            end
            
            WAIT_Z0: begin
                Start_0 = 1'b0;
                if (Done_0) begin
                    State_next = START_Z1;
                end
            end
            
            START_Z1: begin
                Start_1 = 1'b1;
                State_next = WAIT_Z1;
            end
            
            WAIT_Z1: begin
                Start_1 = 1'b0;
                if (Done_1) begin
                    State_next = START_Z2;
                end
            end
            
            START_Z2: begin
                Start_2 = 1'b1;
                State_next = WAIT_Z2;
            end
            
            WAIT_Z2: begin
                Start_2 = 1'b0;
                if (Done_2) begin
                    State_next = FINAL_CALCULATION;
                end
            end
            
            FINAL_CALCULATION: begin
                State_next = DONE;
            end
            
            ZERO_CASE: begin
                State_next = DONE;
            end
            
            DONE: begin
                if (!Start) begin
                    State_next = IDLE;
                end
            end
            
            default: State_next = IDLE;
        endcase
    end
endmodule