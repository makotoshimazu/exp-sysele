`define points 64
`define num_in 4
`define s1_step 16
`define s2_step 4
`define s3_step 1
module fft64
  #(parameter width = 11)
   (
    input              CLK,
    input              RST,

    input              valid_a,
    input [width-1:0]  ar,
    input [width-1:0]  ai,

    output             valid_o,
    input              rd_en,
    output             full,
    output [width-1:0] xr,
    output [width-1:0] xi
    );


    // -- registers --
    // for pipeline
    reg   [width-1:0] xr0     [`points-1:0]; // input buffer real
    reg   [width-1:0] xi0     [`points-1:0];
    reg   [44:0]      xr1     [`points-1:0];
    reg   [44:0]      xi1     [`points-1:0];
    reg   [44:0]      xr2     [`points-1:0];
    reg   [44:0]      xi2     [`points-1:0];
    reg   [width-1:0] xr3     [`points-1:0];
    reg   [width-1:0] xi3     [`points-1:0];
    reg   [width-1:0] outr    [`points-1:0];
    reg   [width-1:0] outi    [`points-1:0];

    reg   [7:0]  cur0, cur1,   cur2,   cur3,   cur4;   // new cursor
    reg   [7:0]        cur1_p, cur2_p, cur3_p, cur4_p; // previous cursor
    reg   [7:0]        cur1_pp,cur2_pp;

    reg   [44:0]      xra2m0, xra2m1, xra2m2, xra2m3;
    reg   [44:0]      xia2m0, xia2m1, xia2m2, xia2m3;

    // -- wires --
    wire  [5:0]  bp1,   bp2,   bp3;   // base pointer
    wire  [5:0]  bp1_p, bp2_p, bp3_p; // base pointer previous
    // 山ほどのwire
    wire  [10:0] xr0w0, xr0w1, xr0w2, xr0w3;
    wire  [10:0] xi0w0, xi0w1, xi0w2, xi0w3;
    wire  [44:0] xrw0a,xrw1a,xrw2a,xrw3a; // output
    wire  [44:0] xiw0a,xiw1a,xiw2a,xiw3a;
    wire  [44:0] xrw0m,xrw1m,xrw2m,xrw3m; // output
    wire  [44:0] xiw0m,xiw1m,xiw2m,xiw3m;
    wire  [44:0] xr3w0a,xr3w1a,xr3w2a,xr3w3a;
    wire  [44:0] xi3w0a,xi3w1a,xi3w2a,xi3w3a;
    wire  [44:0] xrw0in, xrw1in, xrw2in, xrw3in; // input for r4a
    wire  [44:0] xiw0in, xiw1in, xiw2in, xiw3in;
    wire  [4:0]  nw;
    
    // -- assigns --

    // output data
    assign xr = outr[ cur4_p[5:0] ];
    assign xi = outi[ cur4_p[5:0] ];
    
    // valid data flag
    assign valid_o = ( cur4 != 0 ) ? 1 : 0;
    
    // base pointer
    assign bp1     = {cur1[7:2]} + 6'b0;
    assign bp1_p   = {cur1_pp[7:2]} + 6'b0;
    assign bp2     = {cur2[5:4], 4'b0} + {4'b0, cur2[3:2]};
    assign bp2_p   = {cur2_pp[5:4], 4'b0} + {4'b0, cur2_pp[3:2]};
    assign bp3     = cur3[5:0];
    assign bp3_p   = cur3_p[5:0];

    // r4a1 input for sign extension
    assign xr0w0 = xr0[bp1];
    assign xr0w1 = xr0[bp1+`s1_step];
    assign xr0w2 = xr0[bp1+(`s1_step*2)];
    assign xr0w3 = xr0[bp1+(`s1_step*3)];
    assign xi0w0 = xi0[bp1];
    assign xi0w1 = xi0[bp1+`s1_step];
    assign xi0w2 = xi0[bp1+(`s1_step*2)];
    assign xi0w3 = xi0[bp1+(`s1_step*3)];

    // r4a input
    assign xrw0in = (cur2!=0 || cur1==`points) ? (xr1[bp2])              : {{34{xr0w0[10]}},xr0w0}; 
    assign xrw1in = (cur2!=0 || cur1==`points) ? (xr1[bp2+`s2_step])     : {{34{xr0w1[10]}},xr0w1}; 
    assign xrw2in = (cur2!=0 || cur1==`points) ? (xr1[bp2+(`s2_step*2)]) : {{34{xr0w2[10]}},xr0w2}; 
    assign xrw3in = (cur2!=0 || cur1==`points) ? (xr1[bp2+(`s2_step*3)]) : {{34{xr0w3[10]}},xr0w3}; 
    assign xiw0in = (cur2!=0 || cur1==`points) ? (xi1[bp2])              : {{34{xi0w0[10]}},xi0w0}; 
    assign xiw1in = (cur2!=0 || cur1==`points) ? (xi1[bp2+`s2_step])     : {{34{xi0w1[10]}},xi0w1}; 
    assign xiw2in = (cur2!=0 || cur1==`points) ? (xi1[bp2+(`s2_step*2)]) : {{34{xi0w2[10]}},xi0w2}; 
    assign xiw3in = (cur2!=0 || cur1==`points) ? (xi1[bp2+(`s2_step*3)]) : {{34{xi0w3[10]}},xi0w3}; 

    assign nw = (cur2!=0) ? {1'b0,cur2_p[3:2],2'b0} : {cur1_p[7:2]} + 6'b0;

    // -- modules --
    // stage1/stage2
    radix4_add r4a(
                    // Outputs
                    .or0                (xrw0a), 
                    .or1                (xrw1a), 
                    .or2                (xrw2a), 
                    .or3                (xrw3a), 
                    .oi0                (xiw0a), 
                    .oi1                (xiw1a), 
                    .oi2                (xiw2a), 
                    .oi3                (xiw3a), 
                    // Inputs
                    .ir0                (xrw0in),
                    .ir1                (xrw1in),
                    .ir2                (xrw2in),
                    .ir3                (xrw3in),
                    .ii0                (xiw0in), 
                    .ii1                (xiw1in), 
                    .ii2                (xiw2in), 
                    .ii3                (xiw3in)); 
    radix4_mul r4m(
                    // Outputs
                    .or0                (xrw0m),
                    .or1                (xrw1m),
                    .or2                (xrw2m),
                    .or3                (xrw3m),
                    .oi0                (xiw0m),
                    .oi1                (xiw1m),
                    .oi2                (xiw2m),
                    .oi3                (xiw3m),
                    // Inputs
                    .clk                (CLK),
                    .rst                (RST),
                    .n                  (nw),
                    .ir0                (xra2m0), 
                    .ir1                (xra2m1), 
                    .ir2                (xra2m2), 
                    .ir3                (xra2m3), 
                    .ii0                (xia2m0), 
                    .ii1                (xia2m1), 
                    .ii2                (xia2m2), 
                    .ii3                (xia2m3));
    // stage3
    radix4_add r4a3(/*AUTOINST*/
                    // Outputs
                    .or0                (xr3w0a), 
                    .or1                (xr3w1a), 
                    .or2                (xr3w2a), 
                    .or3                (xr3w3a), 
                    .oi0                (xi3w0a), 
                    .oi1                (xi3w1a), 
                    .oi2                (xi3w2a), 
                    .oi3                (xi3w3a), 
                    // Inputs
                    .ir0                (xr2[bp3]),
                    .ir1                (xr2[bp3+`s3_step]),
                    .ir2                (xr2[bp3+(`s3_step*2)]),
                    .ir3                (xr2[bp3+(`s3_step*3)]),
                    .ii0                (xi2[bp3]),
                    .ii1                (xi2[bp3+`s3_step]),
                    .ii2                (xi2[bp3+(`s3_step*2)]),
                    .ii3                (xi2[bp3+(`s3_step*3)]));
    // rearrangement
    // yet


    integer i;
    always @( posedge CLK or negedge RST ) begin
        if ( !RST ) begin
            for ( i = 0; i < `points; i=i+1 ) begin
                xr0[i]  <= 11'b0;
                xi0[i]  <= 11'b0;
                xr1[i]  <= 11'b0;
                xi1[i]  <= 11'b0;
                xr2[i]  <= 11'b0;
                xi2[i]  <= 11'b0;
                xr3[i]  <= 11'b0;
                xi3[i]  <= 11'b0;
                outr[i] <= 11'b0;
                outi[i] <= 11'b0;
            end
            cur0 <= 0; cur1   <= 0; cur2   <= 0; cur3   <= 0; cur4   <= 0;
                       cur1_p <= 0; cur2_p <= 0; cur3_p <= 0; cur4_p <= 0;
                       cur1_pp<= 0; cur2_pp<= 0;
            xra2m0 <= 0;
            xra2m1 <= 0;
            xra2m2 <= 0;
            xra2m3 <= 0;
            xia2m0 <= 0;
            xia2m1 <= 0;
            xia2m2 <= 0;
            xia2m3 <= 0;
        end else begin
            // 一つ前のカーソルをcurN_pに入れる。_pは_previousの略。
            cur1_p  <= cur1;
            cur1_pp <= cur1_p;
            cur2_p  <= cur2;
            cur2_pp <= cur2_p;
            cur3_p  <= cur3;
            cur4_p  <= cur4;

            // -- STAGE0 --
            // Input stage
            // finish
            if ( cur0 == `points ) begin
                // for continuous input
                if ( valid_a ) begin
                    cur0 <= 1;
                    xr0[0] <= ar;
                    xi0[0] <= ai;
                end else begin
                    cur0 <= 0;
                end
                cur1 <= `num_in; // start next stage
                // Register control for next ntage
                xra2m0 <= xrw0a;
                xra2m1 <= xrw1a;
                xra2m2 <= xrw2a;
                xra2m3 <= xrw3a;
                xia2m0 <= xiw0a;
                xia2m1 <= xiw1a;
                xia2m2 <= xiw2a;
                xia2m3 <= xiw3a;
            end
            // valid_i = 1;
            else if ( valid_a ) begin
                cur0 <= cur0 + 1;
                xr0[cur0[5:0]] <= ar;
                xi0[cur0[5:0]] <= ai;
            end 
            // // if valid_a is unexpected state
            // else begin
            //     cur0 <= 0;
            // end

            // -- STAGE1 --
            // finish
            if ( cur1 == `points+`num_in ) begin
                cur1 <= 0;
                // Register control
                xr1[bp1_p]               <= xrw0m; 
                xr1[bp1_p+`s1_step]      <= xrw1m; 
                xr1[bp1_p+(`s1_step*2)]  <= xrw2m; 
                xr1[bp1_p+(`s1_step*3)]  <= xrw3m; 
                xi1[bp1_p]               <= xiw0m; 
                xi1[bp1_p+`s1_step]      <= xiw1m; 
                xi1[bp1_p+(`s1_step*2)]  <= xiw2m; 
                xi1[bp1_p+(`s1_step*3)]  <= xiw3m; 
            end
            // process
            else if ( cur1 != 0 ) begin
                cur1 <= cur1 + `num_in;
                if ( cur1 == `points ) cur2 <= `num_in;
                // Register control
                xr1[bp1_p]               <= xrw0m; 
                xr1[bp1_p+`s1_step]      <= xrw1m; 
                xr1[bp1_p+(`s1_step*2)]  <= xrw2m; 
                xr1[bp1_p+(`s1_step*3)]  <= xrw3m; 
                xi1[bp1_p]               <= xiw0m; 
                xi1[bp1_p+`s1_step]      <= xiw1m; 
                xi1[bp1_p+(`s1_step*2)]  <= xiw2m; 
                xi1[bp1_p+(`s1_step*3)]  <= xiw3m;
                xra2m0 <= xrw0a;
                xra2m1 <= xrw1a;
                xra2m2 <= xrw2a;
                xra2m3 <= xrw3a;
                xia2m0 <= xiw0a;
                xia2m1 <= xiw1a;
                xia2m2 <= xiw2a;
                xia2m3 <= xiw3a;
            end

            // -- STAGE2 --
            // finish
            if ( cur2 == `points+`num_in ) begin
                cur2 <= 0;
                // Register control
                xr2[bp2_p]               <= {{28{xrw0m[44]}},xrw0m[44:28]}; 
                xr2[bp2_p+`s2_step]      <= {{28{xrw1m[44]}},xrw1m[44:28]}; 
                xr2[bp2_p+(`s2_step*2)]  <= {{28{xrw2m[44]}},xrw2m[44:28]}; 
                xr2[bp2_p+(`s2_step*3)]  <= {{28{xrw3m[44]}},xrw3m[44:28]}; 
                xi2[bp2_p]               <= {{28{xiw0m[44]}},xiw0m[44:28]}; 
                xi2[bp2_p+`s2_step]      <= {{28{xiw1m[44]}},xiw1m[44:28]}; 
                xi2[bp2_p+(`s2_step*2)]  <= {{28{xiw2m[44]}},xiw2m[44:28]}; 
                xi2[bp2_p+(`s2_step*3)]  <= {{28{xiw3m[44]}},xiw3m[44:28]};
                
                cur3 <= `num_in; // Start next stage
                // Register control for next stage
                xr3[bp3]               <= xr3w0a; 
                xr3[bp3+`s3_step]      <= xr3w1a; 
                xr3[bp3+(`s3_step*2)]  <= xr3w2a; 
                xr3[bp3+(`s3_step*3)]  <= xr3w3a; 
                xi3[bp3]               <= xi3w0a; 
                xi3[bp3+`s3_step]      <= xi3w1a; 
                xi3[bp3+(`s3_step*2)]  <= xi3w2a; 
                xi3[bp3+(`s3_step*3)]  <= xi3w3a; 
            end
            // process
            else if ( cur2 != 0 ) begin
                cur2 <= cur2 + `num_in;
                // Register control
                xra2m0 <= xrw0a;
                xra2m1 <= xrw1a;
                xra2m2 <= xrw2a;
                xra2m3 <= xrw3a;
                xia2m0 <= xiw0a;
                xia2m1 <= xiw1a;
                xia2m2 <= xiw2a;
                xia2m3 <= xiw3a;
                xr2[bp2_p]               <= {{28{xrw0m[44]}},xrw0m[44:28]}; 
                xr2[bp2_p+`s2_step]      <= {{28{xrw1m[44]}},xrw1m[44:28]}; 
                xr2[bp2_p+(`s2_step*2)]  <= {{28{xrw2m[44]}},xrw2m[44:28]}; 
                xr2[bp2_p+(`s2_step*3)]  <= {{28{xrw3m[44]}},xrw3m[44:28]}; 
                xi2[bp2_p]               <= {{28{xiw0m[44]}},xiw0m[44:28]}; 
                xi2[bp2_p+`s2_step]      <= {{28{xiw1m[44]}},xiw1m[44:28]}; 
                xi2[bp2_p+(`s2_step*2)]  <= {{28{xiw2m[44]}},xiw2m[44:28]}; 
                xi2[bp2_p+(`s2_step*3)]  <= {{28{xiw3m[44]}},xiw3m[44:28]}; 
            end

            // -- STAGE3 --
            // finish
            if ( cur3 == `points ) begin
                cur3 <= 0;
                cur4 <= 1; // Start next stage
                // set outr/outi
                // real part
                outr[0 ] <= xr3[0 ]; outr[16] <= xr3[1 ]; outr[32] <= xr3[2 ]; outr[48] <= xr3[3 ]; 
                outr[4 ] <= xr3[4 ]; outr[20] <= xr3[5 ]; outr[36] <= xr3[6 ]; outr[52] <= xr3[7 ]; 
                outr[8 ] <= xr3[8 ]; outr[24] <= xr3[9 ]; outr[40] <= xr3[10]; outr[56] <= xr3[11]; 
                outr[12] <= xr3[12]; outr[28] <= xr3[13]; outr[44] <= xr3[14]; outr[60] <= xr3[15]; 
                outr[1 ] <= xr3[16]; outr[17] <= xr3[17]; outr[33] <= xr3[18]; outr[49] <= xr3[19]; 
                outr[5 ] <= xr3[20]; outr[21] <= xr3[21]; outr[37] <= xr3[22]; outr[53] <= xr3[23]; 
                outr[9 ] <= xr3[24]; outr[25] <= xr3[25]; outr[41] <= xr3[26]; outr[57] <= xr3[27]; 
                outr[13] <= xr3[28]; outr[29] <= xr3[29]; outr[45] <= xr3[30]; outr[61] <= xr3[31]; 
                outr[2 ] <= xr3[32]; outr[18] <= xr3[33]; outr[34] <= xr3[34]; outr[50] <= xr3[35]; 
                outr[6 ] <= xr3[36]; outr[22] <= xr3[37]; outr[38] <= xr3[38]; outr[54] <= xr3[39]; 
                outr[10] <= xr3[40]; outr[26] <= xr3[41]; outr[42] <= xr3[42]; outr[58] <= xr3[43]; 
                outr[14] <= xr3[44]; outr[30] <= xr3[45]; outr[46] <= xr3[46]; outr[62] <= xr3[47]; 
                outr[3 ] <= xr3[48]; outr[19] <= xr3[49]; outr[35] <= xr3[50]; outr[51] <= xr3[51]; 
                outr[7 ] <= xr3[52]; outr[23] <= xr3[53]; outr[39] <= xr3[54]; outr[55] <= xr3[55]; 
                outr[11] <= xr3[56]; outr[27] <= xr3[57]; outr[43] <= xr3[58]; outr[59] <= xr3[59]; 
                outr[15] <= xr3[60]; outr[31] <= xr3[61]; outr[47] <= xr3[62]; outr[63] <= xr3[63];
                // imaginary part
                outi[0 ] <= xi3[0 ]; outi[16] <= xi3[1 ]; outi[32] <= xi3[2 ]; outi[48] <= xi3[3 ]; 
                outi[4 ] <= xi3[4 ]; outi[20] <= xi3[5 ]; outi[36] <= xi3[6 ]; outi[52] <= xi3[7 ]; 
                outi[8 ] <= xi3[8 ]; outi[24] <= xi3[9 ]; outi[40] <= xi3[10]; outi[56] <= xi3[11]; 
                outi[12] <= xi3[12]; outi[28] <= xi3[13]; outi[44] <= xi3[14]; outi[60] <= xi3[15]; 
                outi[1 ] <= xi3[16]; outi[17] <= xi3[17]; outi[33] <= xi3[18]; outi[49] <= xi3[19]; 
                outi[5 ] <= xi3[20]; outi[21] <= xi3[21]; outi[37] <= xi3[22]; outi[53] <= xi3[23]; 
                outi[9 ] <= xi3[24]; outi[25] <= xi3[25]; outi[41] <= xi3[26]; outi[57] <= xi3[27]; 
                outi[13] <= xi3[28]; outi[29] <= xi3[29]; outi[45] <= xi3[30]; outi[61] <= xi3[31]; 
                outi[2 ] <= xi3[32]; outi[18] <= xi3[33]; outi[34] <= xi3[34]; outi[50] <= xi3[35]; 
                outi[6 ] <= xi3[36]; outi[22] <= xi3[37]; outi[38] <= xi3[38]; outi[54] <= xi3[39]; 
                outi[10] <= xi3[40]; outi[26] <= xi3[41]; outi[42] <= xi3[42]; outi[58] <= xi3[43]; 
                outi[14] <= xi3[44]; outi[30] <= xi3[45]; outi[46] <= xi3[46]; outi[62] <= xi3[47]; 
                outi[3 ] <= xi3[48]; outi[19] <= xi3[49]; outi[35] <= xi3[50]; outi[51] <= xi3[51]; 
                outi[7 ] <= xi3[52]; outi[23] <= xi3[53]; outi[39] <= xi3[54]; outi[55] <= xi3[55]; 
                outi[11] <= xi3[56]; outi[27] <= xi3[57]; outi[43] <= xi3[58]; outi[59] <= xi3[59]; 
                outi[15] <= xi3[60]; outi[31] <= xi3[61]; outi[47] <= xi3[62]; outi[63] <= xi3[63]; 
                
            end
            // process
            else if ( cur3 != 0 ) begin
                cur3 <= cur3 + `num_in;
                // Register control
                xr3[bp3]               <= xr3w0a; 
                xr3[bp3+`s3_step]      <= xr3w1a; 
                xr3[bp3+(`s3_step*2)]  <= xr3w2a; 
                xr3[bp3+(`s3_step*3)]  <= xr3w3a; 
                xi3[bp3]               <= xi3w0a; 
                xi3[bp3+`s3_step]      <= xi3w1a; 
                xi3[bp3+(`s3_step*2)]  <= xi3w2a; 
                xi3[bp3+(`s3_step*3)]  <= xi3w3a; 
            end

            // -- STAGE3 --
            // finish
            if ( cur4 == `points ) begin
                if ( cur3 != `points ) begin
                    cur4 <= 0; // reset
                end
            end
            // process
            else if ( cur4 != 0 ) begin
                cur4 <= cur4 + 1;
            end
        end
    end
    
endmodule
