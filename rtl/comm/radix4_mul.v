`define width 11
`define shift 14
module radix4_mul (/*AUTOARG*/
    // Outputs
    or0, or1, or2, or3, oi0, oi1, oi2, oi3,
    // Inputs
    clk, rst, n, ir0, ir1, ir2, ir3, ii0, ii1, ii2, ii3
    ) ;
    input  clk, rst;
    input  [4:0] n;
    input  signed [44:0] ir0, ir1, ir2, ir3;
    input  signed [44:0] ii0, ii1, ii2, ii3;
    output signed [44:0] or0, or1, or2, or3;
    output signed [44:0] oi0, oi1, oi2, oi3;

    wire signed [`shift+1:0]  w_r0, w_r1, w_r2, w_r3,
                              w_i0, w_i1, w_i2, w_i3;

    wire signed [24:0] ir0_w, ir1_w, ir2_w, ir3_w;
    wire signed [24:0] ii0_w, ii1_w, ii2_w, ii3_w;

    reg signed [44:0] mr0_0, mr0_1;
    reg signed [44:0] mr1_0, mr1_1;
    reg signed [44:0] mr2_0, mr2_1;
    reg signed [44:0] mr3_0, mr3_1;
    reg signed [44:0] mi0_0, mi0_1;
    reg signed [44:0] mi1_0, mi1_1;
    reg signed [44:0] mi2_0, mi2_1;
    reg signed [44:0] mi3_0, mi3_1;

    assign w_r0 = twieedle_r(0,n);
    assign w_r1 = twieedle_r(1,n);
    assign w_r2 = twieedle_r(2,n);
    assign w_r3 = twieedle_r(3,n);
    assign w_i0 = twieedle_i(0,n);
    assign w_i1 = twieedle_i(1,n);
    assign w_i2 = twieedle_i(2,n);
    assign w_i3 = twieedle_i(3,n);

    assign ir0_w = ir0[24:0];
    assign ir1_w = ir1[24:0];
    assign ir2_w = ir2[24:0];
    assign ir3_w = ir3[24:0];
    assign ii0_w = ii0[24:0];
    assign ii1_w = ii1[24:0];
    assign ii2_w = ii2[24:0];
    assign ii3_w = ii3[24:0];
    

    // twieedleの掛け算
    assign or0 = ( mr0_0 - mr0_1 );
    assign oi0 = ( mi0_0 + mi0_1 );
    assign or1 = ( mr1_0 - mr1_1 ); 
    assign oi1 = ( mi1_0 + mi1_1 ); 
    assign or2 = ( mr2_0 - mr2_1 );
    assign oi2 = ( mi2_0 + mi2_1 );
    assign or3 = ( mr3_0 - mr3_1 ); 
    assign oi3 = ( mi3_0 + mi3_1 ); 


    always @(posedge clk or negedge rst) begin
        if ( !rst ) begin
            mr0_0 <= 0; mr0_1 <= 0; 
            mr1_0 <= 0; mr1_1 <= 0; 
            mr2_0 <= 0; mr2_1 <= 0; 
            mr3_0 <= 0; mr3_1 <= 0; 
            mi0_0 <= 0; mi0_1 <= 0; 
            mi1_0 <= 0; mi1_1 <= 0; 
            mi2_0 <= 0; mi2_1 <= 0; 
            mi3_0 <= 0; mi3_1 <= 0;
        end else begin
            mr0_0 <= ir0_w*w_r0;  mr0_1 <= ii0_w*w_i0;
            mi0_0 <= ir0_w*w_i0;  mi0_1 <= ii0_w*w_r0;
            mr1_0 <= ir1_w*w_r1;  mr1_1 <= ii1_w*w_i1;
            mi1_0 <= ir1_w*w_i1;  mi1_1 <= ii1_w*w_r1;
            mr2_0 <= ir2_w*w_r2;  mr2_1 <= ii2_w*w_i2;
            mi2_0 <= ir2_w*w_i2;  mi2_1 <= ii2_w*w_r2;
            mr3_0 <= ir3_w*w_r3;  mr3_1 <= ii3_w*w_i3;
            mi3_0 <= ir3_w*w_i3;  mi3_1 <= ii3_w*w_r3;
        end
    end
    
    function [`shift+1:0] twieedle_r;
        input  [1:0]  k;
        input  [4:0]  n;
        begin
            if ( k == 0 ) begin
                twieedle_r = 16'b01_0000_0000_0000_00;
            end else if ( k == 1 ) begin
                case ( n )
                  5'd 0: twieedle_r = 16'b0100000000000000; 
                  5'd 1: twieedle_r = 16'b0011111110110001; 
                  5'd 2: twieedle_r = 16'b0011111011000101; 
                  5'd 3: twieedle_r = 16'b0011110100111110; 
                  5'd 4: twieedle_r = 16'b0011101100100000; 
                  5'd 5: twieedle_r = 16'b0011100001110001; 
                  5'd 6: twieedle_r = 16'b0011010100110110; 
                  5'd 7: twieedle_r = 16'b0011000101111001; 
                  5'd 8: twieedle_r = 16'b0010110101000001; 
                  5'd 9: twieedle_r = 16'b0010100010011001; 
                  5'd10: twieedle_r = 16'b0010001110001110; 
                  5'd11: twieedle_r = 16'b0001111000101011; 
                  5'd12: twieedle_r = 16'b0001100001111101; 
                  5'd13: twieedle_r = 16'b0001001010010100; 
                  5'd14: twieedle_r = 16'b0000110001111100; 
                  5'd15: twieedle_r = 16'b0000011001000101; 
                  5'd16: twieedle_r = 16'b0000000000000000; 
                  5'd17: twieedle_r = 16'b1111100110111011; 
                  5'd18: twieedle_r = 16'b1111001110000100; 
                  5'd19: twieedle_r = 16'b1110110101101100; 
                  5'd20: twieedle_r = 16'b1110011110000011; 
                  5'd21: twieedle_r = 16'b1110000111010101; 
                  5'd22: twieedle_r = 16'b1101110001110010; 
                  5'd23: twieedle_r = 16'b1101011101100111; 
                  5'd24: twieedle_r = 16'b1101001010111111; 
                  5'd25: twieedle_r = 16'b1100111010000111; 
                  5'd26: twieedle_r = 16'b1100101011001010; 
                  5'd27: twieedle_r = 16'b1100011110001111; 
                  5'd28: twieedle_r = 16'b1100010011100000; 
                  5'd29: twieedle_r = 16'b1100001011000010; 
                  5'd30: twieedle_r = 16'b1100000100111011; 
                  5'd31: twieedle_r = 16'b1100000001001111;
                endcase // case ( n )
            end else if ( k == 2 ) begin
                case ( n )
                  5'd 0: twieedle_r = 16'b0100000000000000; 
                  5'd 1: twieedle_r = 16'b0011111011000101; 
                  5'd 2: twieedle_r = 16'b0011101100100000; 
                  5'd 3: twieedle_r = 16'b0011010100110110; 
                  5'd 4: twieedle_r = 16'b0010110101000001; 
                  5'd 5: twieedle_r = 16'b0010001110001110; 
                  5'd 6: twieedle_r = 16'b0001100001111101; 
                  5'd 7: twieedle_r = 16'b0000110001111100; 
                  5'd 8: twieedle_r = 16'b0000000000000000; 
                  5'd 9: twieedle_r = 16'b1111001110000100; 
                  5'd10: twieedle_r = 16'b1110011110000011; 
                  5'd11: twieedle_r = 16'b1101110001110010; 
                  5'd12: twieedle_r = 16'b1101001010111111; 
                  5'd13: twieedle_r = 16'b1100101011001010; 
                  5'd14: twieedle_r = 16'b1100010011100000; 
                  5'd15: twieedle_r = 16'b1100000100111011; 
                  5'd16: twieedle_r = 16'b1100000000000000; 
                  5'd17: twieedle_r = 16'b1100000100111011; 
                  5'd18: twieedle_r = 16'b1100010011100000; 
                  5'd19: twieedle_r = 16'b1100101011001010; 
                  5'd20: twieedle_r = 16'b1101001010111111; 
                  5'd21: twieedle_r = 16'b1101110001110010; 
                  5'd22: twieedle_r = 16'b1110011110000011; 
                  5'd23: twieedle_r = 16'b1111001110000100; 
                  5'd24: twieedle_r = 16'b0000000000000000; 
                  5'd25: twieedle_r = 16'b0000110001111100; 
                  5'd26: twieedle_r = 16'b0001100001111101; 
                  5'd27: twieedle_r = 16'b0010001110001110; 
                  5'd28: twieedle_r = 16'b0010110101000001; 
                  5'd29: twieedle_r = 16'b0011010100110110; 
                  5'd30: twieedle_r = 16'b0011101100100000; 
                  5'd31: twieedle_r = 16'b0011111011000101;
                endcase // case ( n )
            end else if ( k == 3 ) begin
                case ( n )
                  5'd 0: twieedle_r = 16'b0100000000000000; 
                  5'd 1: twieedle_r = 16'b0011110100111110; 
                  5'd 2: twieedle_r = 16'b0011010100110110; 
                  5'd 3: twieedle_r = 16'b0010100010011001; 
                  5'd 4: twieedle_r = 16'b0001100001111101; 
                  5'd 5: twieedle_r = 16'b0000011001000101; 
                  5'd 6: twieedle_r = 16'b1111001110000100; 
                  5'd 7: twieedle_r = 16'b1110000111010101; 
                  5'd 8: twieedle_r = 16'b1101001010111111; 
                  5'd 9: twieedle_r = 16'b1100011110001111; 
                  5'd10: twieedle_r = 16'b1100000100111011; 
                  5'd11: twieedle_r = 16'b1100000001001111; 
                  5'd12: twieedle_r = 16'b1100010011100000; 
                  5'd13: twieedle_r = 16'b1100111010000111; 
                  5'd14: twieedle_r = 16'b1101110001110010; 
                  5'd15: twieedle_r = 16'b1110110101101100; 
                  5'd16: twieedle_r = 16'b0000000000000000; 
                  5'd17: twieedle_r = 16'b0001001010010100; 
                  5'd18: twieedle_r = 16'b0010001110001110; 
                  5'd19: twieedle_r = 16'b0011000101111001; 
                  5'd20: twieedle_r = 16'b0011101100100000; 
                  5'd21: twieedle_r = 16'b0011111110110001; 
                  5'd22: twieedle_r = 16'b0011111011000101; 
                  5'd23: twieedle_r = 16'b0011100001110001; 
                  5'd24: twieedle_r = 16'b0010110101000001; 
                  5'd25: twieedle_r = 16'b0001111000101011; 
                  5'd26: twieedle_r = 16'b0000110001111100; 
                  5'd27: twieedle_r = 16'b1111100110111011; 
                  5'd28: twieedle_r = 16'b1110011110000011; 
                  5'd29: twieedle_r = 16'b1101011101100111; 
                  5'd30: twieedle_r = 16'b1100101011001010; 
                  5'd31: twieedle_r = 16'b1100001011000010;
                endcase // case ( n )
            end
        end
    endfunction //
    
    function [`shift+1:0] twieedle_i;
        input  [1:0]  k;
        input  [4:0]  n;
        begin
            if ( k == 0 ) begin
                twieedle_i = 16'b00_0000_0000_0000_00;
            end else if ( k == 1 ) begin
                case ( n )
                  5'd 0: twieedle_i = 16'b00_00000000000000; 
                  5'd 1: twieedle_i = 16'b11_11100110111011; 
                  5'd 2: twieedle_i = 16'b11_11001110000100; 
                  5'd 3: twieedle_i = 16'b11_10110101101100; 
                  5'd 4: twieedle_i = 16'b11_10011110000011; 
                  5'd 5: twieedle_i = 16'b11_10000111010101; 
                  5'd 6: twieedle_i = 16'b11_01110001110010; 
                  5'd 7: twieedle_i = 16'b11_01011101100111; 
                  5'd 8: twieedle_i = 16'b11_01001010111111; 
                  5'd 9: twieedle_i = 16'b11_00111010000111; 
                  5'd10: twieedle_i = 16'b11_00101011001010; 
                  5'd11: twieedle_i = 16'b11_00011110001111; 
                  5'd12: twieedle_i = 16'b11_00010011100000; 
                  5'd13: twieedle_i = 16'b11_00001011000010; 
                  5'd14: twieedle_i = 16'b11_00000100111011; 
                  5'd15: twieedle_i = 16'b11_00000001001111; 
                  5'd16: twieedle_i = 16'b11_00000000000000; 
                  5'd17: twieedle_i = 16'b11_00000001001111; 
                  5'd18: twieedle_i = 16'b11_00000100111011; 
                  5'd19: twieedle_i = 16'b11_00001011000010; 
                  5'd20: twieedle_i = 16'b11_00010011100000; 
                  5'd21: twieedle_i = 16'b11_00011110001111; 
                  5'd22: twieedle_i = 16'b11_00101011001010; 
                  5'd23: twieedle_i = 16'b11_00111010000111; 
                  5'd24: twieedle_i = 16'b11_01001010111111; 
                  5'd25: twieedle_i = 16'b11_01011101100111; 
                  5'd26: twieedle_i = 16'b11_01110001110010; 
                  5'd27: twieedle_i = 16'b11_10000111010101; 
                  5'd28: twieedle_i = 16'b11_10011110000011; 
                  5'd29: twieedle_i = 16'b11_10110101101100; 
                  5'd30: twieedle_i = 16'b11_11001110000100; 
                  5'd31: twieedle_i = 16'b11_11100110111011;
                endcase // case ( n )                      
            end else if ( k == 2 ) begin
                case ( n )
                  5'd 0: twieedle_i = 16'b0000000000000000; 
                  5'd 1: twieedle_i = 16'b1111001110000100; 
                  5'd 2: twieedle_i = 16'b1110011110000011; 
                  5'd 3: twieedle_i = 16'b1101110001110010; 
                  5'd 4: twieedle_i = 16'b1101001010111111; 
                  5'd 5: twieedle_i = 16'b1100101011001010; 
                  5'd 6: twieedle_i = 16'b1100010011100000; 
                  5'd 7: twieedle_i = 16'b1100000100111011; 
                  5'd 8: twieedle_i = 16'b1100000000000000; 
                  5'd 9: twieedle_i = 16'b1100000100111011; 
                  5'd10: twieedle_i = 16'b1100010011100000; 
                  5'd11: twieedle_i = 16'b1100101011001010; 
                  5'd12: twieedle_i = 16'b1101001010111111; 
                  5'd13: twieedle_i = 16'b1101110001110010; 
                  5'd14: twieedle_i = 16'b1110011110000011; 
                  5'd15: twieedle_i = 16'b1111001110000100; 
                  5'd16: twieedle_i = 16'b0000000000000000; 
                  5'd17: twieedle_i = 16'b0000110001111100; 
                  5'd18: twieedle_i = 16'b0001100001111101; 
                  5'd19: twieedle_i = 16'b0010001110001110; 
                  5'd20: twieedle_i = 16'b0010110101000001; 
                  5'd21: twieedle_i = 16'b0011010100110110; 
                  5'd22: twieedle_i = 16'b0011101100100000; 
                  5'd23: twieedle_i = 16'b0011111011000101; 
                  5'd24: twieedle_i = 16'b0100000000000000; 
                  5'd25: twieedle_i = 16'b0011111011000101; 
                  5'd26: twieedle_i = 16'b0011101100100000; 
                  5'd27: twieedle_i = 16'b0011010100110110; 
                  5'd28: twieedle_i = 16'b0010110101000001; 
                  5'd29: twieedle_i = 16'b0010001110001110; 
                  5'd30: twieedle_i = 16'b0001100001111101; 
                  5'd31: twieedle_i = 16'b0000110001111100;
                endcase // case ( n )
            end else if ( k == 3 ) begin
                case ( n )
                  5'd 0: twieedle_i = 16'b0000000000000000; 
                  5'd 1: twieedle_i = 16'b1110110101101100; 
                  5'd 2: twieedle_i = 16'b1101110001110010; 
                  5'd 3: twieedle_i = 16'b1100111010000111; 
                  5'd 4: twieedle_i = 16'b1100010011100000; 
                  5'd 5: twieedle_i = 16'b1100000001001111; 
                  5'd 6: twieedle_i = 16'b1100000100111011; 
                  5'd 7: twieedle_i = 16'b1100011110001111; 
                  5'd 8: twieedle_i = 16'b1101001010111111; 
                  5'd 9: twieedle_i = 16'b1110000111010101; 
                  5'd10: twieedle_i = 16'b1111001110000100; 
                  5'd11: twieedle_i = 16'b0000011001000101; 
                  5'd12: twieedle_i = 16'b0001100001111101; 
                  5'd13: twieedle_i = 16'b0010100010011001; 
                  5'd14: twieedle_i = 16'b0011010100110110; 
                  5'd15: twieedle_i = 16'b0011110100111110; 
                  5'd16: twieedle_i = 16'b0100000000000000; 
                  5'd17: twieedle_i = 16'b0011110100111110; 
                  5'd18: twieedle_i = 16'b0011010100110110; 
                  5'd19: twieedle_i = 16'b0010100010011001; 
                  5'd20: twieedle_i = 16'b0001100001111101; 
                  5'd21: twieedle_i = 16'b0000011001000101; 
                  5'd22: twieedle_i = 16'b1111001110000100; 
                  5'd23: twieedle_i = 16'b1110000111010101; 
                  5'd24: twieedle_i = 16'b1101001010111111; 
                  5'd25: twieedle_i = 16'b1100011110001111; 
                  5'd26: twieedle_i = 16'b1100000100111011; 
                  5'd27: twieedle_i = 16'b1100000001001111; 
                  5'd28: twieedle_i = 16'b1100010011100000; 
                  5'd29: twieedle_i = 16'b1100111010000111; 
                  5'd30: twieedle_i = 16'b1101110001110010; 
                  5'd31: twieedle_i = 16'b1110110101101100;
                endcase // case ( n )
            end
        end
    endfunction //
    // function [`shift+1:0] twieedle_r;
    //     input  [1:0]  k;
    //     input  [4:0]  n;
    //     begin
    //         if ( k == 0 ) begin
    //             twieedle_r = 16'b01_0000_0000_0000_00;
    //         end else if ( k == 1 ) begin
    //             case ( n )
    //               5'd 0: twieedle_r = 16'b01_00000000000000; 
    //               5'd 1: twieedle_r = 16'b00_11111111101100; 
    //               5'd 2: twieedle_r = 16'b00_11111110110001; 
    //               5'd 3: twieedle_r = 16'b00_11111101001110; 
    //               5'd 4: twieedle_r = 16'b00_11111011000101; 
    //               5'd 5: twieedle_r = 16'b00_11111000010100; 
    //               5'd 6: twieedle_r = 16'b00_11110100111110; 
    //               5'd 7: twieedle_r = 16'b00_11110001000010; 
    //               5'd 8: twieedle_r = 16'b00_11101100100000; 
    //               5'd 9: twieedle_r = 16'b00_11100111011010; 
    //               5'd10: twieedle_r = 16'b00_11100001110001; 
    //               5'd11: twieedle_r = 16'b00_11011011100101; 
    //               5'd12: twieedle_r = 16'b00_11010100110110; 
    //               5'd13: twieedle_r = 16'b00_11001101100111; 
    //               5'd14: twieedle_r = 16'b00_11000101111001; 
    //               5'd15: twieedle_r = 16'b00_10111101101011; 
    //               5'd16: twieedle_r = 16'b00_10110101000001; 
    //               5'd17: twieedle_r = 16'b00_10101011111010; 
    //               5'd18: twieedle_r = 16'b00_10100010011001; 
    //               5'd19: twieedle_r = 16'b00_10011000011111; 
    //               5'd20: twieedle_r = 16'b00_10001110001110; 
    //               5'd21: twieedle_r = 16'b00_10000011100111; 
    //               5'd22: twieedle_r = 16'b00_01111000101011; 
    //               5'd23: twieedle_r = 16'b00_01101101011101; 
    //               5'd24: twieedle_r = 16'b00_01100001111101; 
    //               5'd25: twieedle_r = 16'b00_01010110001111; 
    //               5'd26: twieedle_r = 16'b00_01001010010100; 
    //               5'd27: twieedle_r = 16'b00_00111110001100; 
    //               5'd28: twieedle_r = 16'b00_00110001111100; 
    //               5'd29: twieedle_r = 16'b00_00100101100100; 
    //               5'd30: twieedle_r = 16'b00_00011001000101; 
    //               5'd31: twieedle_r = 16'b00_00001100100011;
    //             endcase // case ( n )
    //         end else if ( k == 2 ) begin
    //             case ( n )
    //               5'd 0: twieedle_r = 16'b01_00000000000000; 
    //               5'd 1: twieedle_r = 16'b00_11111110110001; 
    //               5'd 2: twieedle_r = 16'b00_11111011000101; 
    //               5'd 3: twieedle_r = 16'b00_11110100111110; 
    //               5'd 4: twieedle_r = 16'b00_11101100100000; 
    //               5'd 5: twieedle_r = 16'b00_11100001110001; 
    //               5'd 6: twieedle_r = 16'b00_11010100110110; 
    //               5'd 7: twieedle_r = 16'b00_11000101111001; 
    //               5'd 8: twieedle_r = 16'b00_10110101000001; 
    //               5'd 9: twieedle_r = 16'b00_10100010011001; 
    //               5'd10: twieedle_r = 16'b00_10001110001110; 
    //               5'd11: twieedle_r = 16'b00_01111000101011; 
    //               5'd12: twieedle_r = 16'b00_01100001111101; 
    //               5'd13: twieedle_r = 16'b00_01001010010100; 
    //               5'd14: twieedle_r = 16'b00_00110001111100; 
    //               5'd15: twieedle_r = 16'b00_00011001000101; 
    //               5'd16: twieedle_r = 16'b00_00000000000000; 
    //               5'd17: twieedle_r = 16'b11_11100110111011; 
    //               5'd18: twieedle_r = 16'b11_11001110000100; 
    //               5'd19: twieedle_r = 16'b11_10110101101100; 
    //               5'd20: twieedle_r = 16'b11_10011110000011; 
    //               5'd21: twieedle_r = 16'b11_10000111010101; 
    //               5'd22: twieedle_r = 16'b11_01110001110010; 
    //               5'd23: twieedle_r = 16'b11_01011101100111; 
    //               5'd24: twieedle_r = 16'b11_01001010111111; 
    //               5'd25: twieedle_r = 16'b11_00111010000111; 
    //               5'd26: twieedle_r = 16'b11_00101011001010; 
    //               5'd27: twieedle_r = 16'b11_00011110001111; 
    //               5'd28: twieedle_r = 16'b11_00010011100000; 
    //               5'd29: twieedle_r = 16'b11_00001011000010; 
    //               5'd30: twieedle_r = 16'b11_00000100111011; 
    //               5'd31: twieedle_r = 16'b11_00000001001111;
    //             endcase // case ( n )
    //         end else if ( k == 3 ) begin
    //             case ( n )
    //               5'd 0: twieedle_r = 16'b01_00000000000000; 
    //               5'd 1: twieedle_r = 16'b00_11111101001110; 
    //               5'd 2: twieedle_r = 16'b00_11110100111110; 
    //               5'd 3: twieedle_r = 16'b00_11100111011010; 
    //               5'd 4: twieedle_r = 16'b00_11010100110110; 
    //               5'd 5: twieedle_r = 16'b00_10111101101011; 
    //               5'd 6: twieedle_r = 16'b00_10100010011001; 
    //               5'd 7: twieedle_r = 16'b00_10000011100111; 
    //               5'd 8: twieedle_r = 16'b00_01100001111101; 
    //               5'd 9: twieedle_r = 16'b00_00111110001100; 
    //               5'd10: twieedle_r = 16'b00_00011001000101; 
    //               5'd11: twieedle_r = 16'b11_11110011011101; 
    //               5'd12: twieedle_r = 16'b11_11001110000100; 
    //               5'd13: twieedle_r = 16'b11_10101001110001; 
    //               5'd14: twieedle_r = 16'b11_10000111010101; 
    //               5'd15: twieedle_r = 16'b11_01100111100001; 
    //               5'd16: twieedle_r = 16'b11_01001010111111; 
    //               5'd17: twieedle_r = 16'b11_00110010011001; 
    //               5'd18: twieedle_r = 16'b11_00011110001111; 
    //               5'd19: twieedle_r = 16'b11_00001110111110; 
    //               5'd20: twieedle_r = 16'b11_00000100111011; 
    //               5'd21: twieedle_r = 16'b11_00000000010100; 
    //               5'd22: twieedle_r = 16'b11_00000001001111; 
    //               5'd23: twieedle_r = 16'b11_00000111101100; 
    //               5'd24: twieedle_r = 16'b11_00010011100000; 
    //               5'd25: twieedle_r = 16'b11_00100100011011; 
    //               5'd26: twieedle_r = 16'b11_00111010000111; 
    //               5'd27: twieedle_r = 16'b11_01010100000110; 
    //               5'd28: twieedle_r = 16'b11_01110001110010; 
    //               5'd29: twieedle_r = 16'b11_10010010100011; 
    //               5'd30: twieedle_r = 16'b11_10110101101100; 
    //               5'd31: twieedle_r = 16'b11_11011010011100;
    //             endcase // case ( n )
    //         end
    //     end
    // endfunction //
    
    // function [`shift+1:0] twieedle_i;
    //     input  [1:0]  k;
    //     input  [4:0]  n;
    //     begin
    //         if ( k == 0 ) begin
    //             twieedle_i = 16'b00_0000_0000_0000_00;
    //         end else if ( k == 1 ) begin
    //             case ( n )
    //               5'd 0: twieedle_i = 16'b00_00000000000000; 
    //               5'd 1: twieedle_i = 16'b11_11110011011101; 
    //               5'd 2: twieedle_i = 16'b11_11100110111011; 
    //               5'd 3: twieedle_i = 16'b11_11011010011100; 
    //               5'd 4: twieedle_i = 16'b11_11001110000100; 
    //               5'd 5: twieedle_i = 16'b11_11000001110100; 
    //               5'd 6: twieedle_i = 16'b11_10110101101100; 
    //               5'd 7: twieedle_i = 16'b11_10101001110001; 
    //               5'd 8: twieedle_i = 16'b11_10011110000011; 
    //               5'd 9: twieedle_i = 16'b11_10010010100011; 
    //               5'd10: twieedle_i = 16'b11_10000111010101; 
    //               5'd11: twieedle_i = 16'b11_01111100011001; 
    //               5'd12: twieedle_i = 16'b11_01110001110010; 
    //               5'd13: twieedle_i = 16'b11_01100111100001; 
    //               5'd14: twieedle_i = 16'b11_01011101100111; 
    //               5'd15: twieedle_i = 16'b11_01010100000110; 
    //               5'd16: twieedle_i = 16'b11_01001010111111; 
    //               5'd17: twieedle_i = 16'b11_01000010010101; 
    //               5'd18: twieedle_i = 16'b11_00111010000111; 
    //               5'd19: twieedle_i = 16'b11_00110010011001; 
    //               5'd20: twieedle_i = 16'b11_00101011001010; 
    //               5'd21: twieedle_i = 16'b11_00100100011011; 
    //               5'd22: twieedle_i = 16'b11_00011110001111; 
    //               5'd23: twieedle_i = 16'b11_00011000100110; 
    //               5'd24: twieedle_i = 16'b11_00010011100000; 
    //               5'd25: twieedle_i = 16'b11_00001110111110; 
    //               5'd26: twieedle_i = 16'b11_00001011000010; 
    //               5'd27: twieedle_i = 16'b11_00000111101100; 
    //               5'd28: twieedle_i = 16'b11_00000100111011; 
    //               5'd29: twieedle_i = 16'b11_00000010110010; 
    //               5'd30: twieedle_i = 16'b11_00000001001111; 
    //               5'd31: twieedle_i = 16'b11_00000000010100;
    //             endcase // case ( n )
    //         end else if ( k == 2 ) begin
    //             case ( n )
    //               5'd 0: twieedle_i = 16'b00_00000000000000; 
    //               5'd 1: twieedle_i = 16'b11_11100110111011; 
    //               5'd 2: twieedle_i = 16'b11_11001110000100; 
    //               5'd 3: twieedle_i = 16'b11_10110101101100; 
    //               5'd 4: twieedle_i = 16'b11_10011110000011; 
    //               5'd 5: twieedle_i = 16'b11_10000111010101; 
    //               5'd 6: twieedle_i = 16'b11_01110001110010; 
    //               5'd 7: twieedle_i = 16'b11_01011101100111; 
    //               5'd 8: twieedle_i = 16'b11_01001010111111; 
    //               5'd 9: twieedle_i = 16'b11_00111010000111; 
    //               5'd10: twieedle_i = 16'b11_00101011001010; 
    //               5'd11: twieedle_i = 16'b11_00011110001111; 
    //               5'd12: twieedle_i = 16'b11_00010011100000; 
    //               5'd13: twieedle_i = 16'b11_00001011000010; 
    //               5'd14: twieedle_i = 16'b11_00000100111011; 
    //               5'd15: twieedle_i = 16'b11_00000001001111; 
    //               5'd16: twieedle_i = 16'b11_00000000000000; 
    //               5'd17: twieedle_i = 16'b11_00000001001111; 
    //               5'd18: twieedle_i = 16'b11_00000100111011; 
    //               5'd19: twieedle_i = 16'b11_00001011000010; 
    //               5'd20: twieedle_i = 16'b11_00010011100000; 
    //               5'd21: twieedle_i = 16'b11_00011110001111; 
    //               5'd22: twieedle_i = 16'b11_00101011001010; 
    //               5'd23: twieedle_i = 16'b11_00111010000111; 
    //               5'd24: twieedle_i = 16'b11_01001010111111; 
    //               5'd25: twieedle_i = 16'b11_01011101100111; 
    //               5'd26: twieedle_i = 16'b11_01110001110010; 
    //               5'd27: twieedle_i = 16'b11_10000111010101; 
    //               5'd28: twieedle_i = 16'b11_10011110000011; 
    //               5'd29: twieedle_i = 16'b11_10110101101100; 
    //               5'd30: twieedle_i = 16'b11_11001110000100; 
    //               5'd31: twieedle_i = 16'b11_11100110111011;
    //             endcase // case ( n )
    //         end else if ( k == 3 ) begin
    //             case ( n )
    //               5'd 0: twieedle_i = 16'b00_00000000000000; 
    //               5'd 1: twieedle_i = 16'b11_11011010011100; 
    //               5'd 2: twieedle_i = 16'b11_10110101101100; 
    //               5'd 3: twieedle_i = 16'b11_10010010100011; 
    //               5'd 4: twieedle_i = 16'b11_01110001110010; 
    //               5'd 5: twieedle_i = 16'b11_01010100000110; 
    //               5'd 6: twieedle_i = 16'b11_00111010000111; 
    //               5'd 7: twieedle_i = 16'b11_00100100011011; 
    //               5'd 8: twieedle_i = 16'b11_00010011100000; 
    //               5'd 9: twieedle_i = 16'b11_00000111101100; 
    //               5'd10: twieedle_i = 16'b11_00000001001111; 
    //               5'd11: twieedle_i = 16'b11_00000000010100; 
    //               5'd12: twieedle_i = 16'b11_00000100111011; 
    //               5'd13: twieedle_i = 16'b11_00001110111110; 
    //               5'd14: twieedle_i = 16'b11_00011110001111; 
    //               5'd15: twieedle_i = 16'b11_00110010011001; 
    //               5'd16: twieedle_i = 16'b11_01001010111111; 
    //               5'd17: twieedle_i = 16'b11_01100111100001; 
    //               5'd18: twieedle_i = 16'b11_10000111010101; 
    //               5'd19: twieedle_i = 16'b11_10101001110001; 
    //               5'd20: twieedle_i = 16'b11_11001110000100; 
    //               5'd21: twieedle_i = 16'b11_11110011011101; 
    //               5'd22: twieedle_i = 16'b00_00011001000101; 
    //               5'd23: twieedle_i = 16'b00_00111110001100; 
    //               5'd24: twieedle_i = 16'b00_01100001111101; 
    //               5'd25: twieedle_i = 16'b00_10000011100111; 
    //               5'd26: twieedle_i = 16'b00_10100010011001; 
    //               5'd27: twieedle_i = 16'b00_10111101101011; 
    //               5'd28: twieedle_i = 16'b00_11010100110110; 
    //               5'd29: twieedle_i = 16'b00_11100111011010; 
    //               5'd30: twieedle_i = 16'b00_11110100111110; 
    //               5'd31: twieedle_i = 16'b00_11111101001110;
    //             endcase // case ( n )
    //         end
    //     end
    // endfunction //
    
endmodule // twieedle
