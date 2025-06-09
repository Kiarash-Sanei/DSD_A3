module CU (input S, OR_R1, CMP_L_R1,
            output reg L_R1, L_R2, L_R3, L_R4, R_R3, Dec_R1, Sel_R1, Sel_R2, S_R, R_R);
    reg [1:0] p_state, n_state;
    localparam [1:0] init=2'b00, cmp=2'b01, mul=2'b10;
    // specify next state and control signals
    always @( p_state or S or OR_R1 or CMP_L_R1 )
    begin:combinational
        n_state = init;
        // Set all of Control Signals to Zero
        case (p_state):
            init:
            begin
                if (S == 1)
                begin
                    n_state = cmp;
                    // TODO: Set Related Signals
                end
                else
                    n_state = init;
            end
            cmp:
            begin
                n_state = mul;
                if (CMP_L_R1 == 0)
                begin
                    // TODO: Set Related Signals
                end
            end
            mul:
            begin
                if (OR_R1 == 1)
                begin
                    n_state = mul;
                    // TODO: Set Related Signals
                end
                else if (OR_R1 == 0)
                begin
                    n_state = init;
                    // TODO: Set Related Signals
                end
            end
        endcase 
    end
    // change state
    always @(posedge clk)
    begin:sequential
        if ( rst ) p_state = init;
        else p_state = n_state;
    end
endmodule