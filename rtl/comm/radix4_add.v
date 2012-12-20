`define width 11
module radix4_add (/*AUTOARG*/
    // Outputs
    or0, or1, or2, or3, oi0, oi1, oi2, oi3,
    // Inputs
    ir0, ir1, ir2, ir3, ii0, ii1, ii2, ii3
    );

    input  [44:0] ir0, ir1, ir2, ir3;
    input  [44:0] ii0, ii1, ii2, ii3;
    output [44:0] or0, or1, or2, or3;
    output [44:0] oi0, oi1, oi2, oi3;

    // バタフライ
    assign or0 = ir0+ir1+ir2+ir3;
    assign oi0 = ii0+ii1+ii2+ii3;
    assign or1 = ir0+ii1-ir2-ii3;
    assign oi1 = ii0-ir1-ii2+ir3;
    assign or2 = ir0-ir1+ir2-ir3;
    assign oi2 = ii0-ii1+ii2-ii3;
    assign or3 = ir0-ii1-ir2+ii3;
    assign oi3 = ii0+ir1-ii2-ir3;
    
endmodule // radoo4
