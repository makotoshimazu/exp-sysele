
module pri
  #(parameter msb = 3,
    parameter lsb = 0,
    parameter pri_w = 3,
    parameter rstval = 0
    )
  (
   input                CLK,
   input                RST,

   input                is_idle,

   input                req1,
   input                req2,
   input                req3,

   input [pri_w-1:0]    pri,
   
   output reg [msb:lsb] value_o,
   input [msb:lsb]      value1_i,
   input [msb:lsb]      value2_i,
   input [msb:lsb]      value3_i
   );
   
`define PRI_W 3
   parameter p123 = `PRI_W'd0;
   parameter p132 = `PRI_W'd1;
   parameter p213 = `PRI_W'd2;
   parameter p231 = `PRI_W'd3;
   parameter p312 = `PRI_W'd4;
   parameter p321 = `PRI_W'd5;
`undef PRI_W

   always @(posedge CLK or negedge RST)
     if (!RST) begin
        value_o <= rstval;
     end else begin
        if (is_idle)
          case (pri)
            p123: 
              if (req1) 
                value_o <= value1_i;
              else if(req2)
                value_o <= value2_i;
              else if (req3)
                value_o <= value3_i;

            p132:
              if (req1)
                value_o <= value1_i;
              else if (req3)
                value_o <= value3_i;
              else if (req2)
                value_o <= value2_i;

            p213:
              if (req2)
                value_o <= value2_i;
              else if (req1)
                value_o <= value1_i;
              else if (req3)
                value_o <= value3_i;

            p231:
              if (req2)
                value_o <= value2_i;
              else if (req3)
                value_o <= value3_i;
              else if (req1)
                value_o <= value1_i;

            p312:
              if (req3)
                value_o <= value3_i;
              else if (req1)
                value_o <= value1_i;
              else if(req2)
                value_o <= value2_i;

            p321:
              if (req3)
                value_o <= value3_i;
              else if (req2)
                value_o <= value2_i;
              else if (req1)
                value_o <= value1_i;

          endcase
     end

endmodule // pri
