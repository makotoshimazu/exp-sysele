
module variable_delay
  #(parameter delay_min = 24,
    parameter sel_width = 4,
    parameter width = 8,
    parameter with_reset = 0,
    parameter rstval = 8'h0
    )
   (
    input                  CLK,
    input                  RST,

    input                  ce,

    input [width-1:0]      din,
    input [sel_width-1:0]  sel,
    output reg [width-1:0] dout);
   
   localparam sel_num = (1 << sel_width);
   localparam total_delay = delay_min + sel_num;
   reg [width-1:0]        dl[0:total_delay - 2];

   genvar                 m;
   
   generate
      for (m=1; m<total_delay-1; m=m+1) begin : GEN_DELAY_MIN
         if (with_reset) begin
            always @(posedge CLK or negedge RST) begin
               if (!RST)
                 dl[m] <= rstval;
               else if (ce)
                 dl[m] <= dl[m-1];
            end
         end

         else begin
            always @(posedge CLK)
              if (ce)
                dl[m] <= dl[m-1];
         end
      end
   endgenerate

   generate
      if (with_reset)
        always @(posedge CLK or negedge RST) begin
          if (!RST)
            dl[0] <= rstval;
          else if (ce)
            dl[0] <= din;
        end
      else begin
        always @(posedge CLK)
          if (ce)
            dl[0] <= din;
      end
   endgenerate

   
   generate
      if (with_reset) begin
         if (delay_min == 1) begin
            always @(posedge CLK or negedge RST) begin
               if (!RST)
                 dout <= rstval;
               else if (ce) begin
                  if (sel == {(sel_width){1'b0}})
                    dout <= din;
                  else
                    dout <= dl[delay_min + sel - 2];
               end
            end
         end
         else begin
            always @(posedge CLK or negedge RST) begin
               if (!RST)
                 dout <= din;
               else if (ce)
                 dout <= dl[delay_min + sel - 2];
            end
         end
      end


      else begin
         if (delay_min == 1) begin
            always @(posedge CLK) begin
               if (ce) begin
                  if (sel == {(sel_width){1'b0}})
                    dout <= din;
                  else
                    dout <= dl[delay_min + sel - 2];
               end
            end
         end
         else begin
            always @(posedge CLK)
              if (ce)
                dout <= dl[delay_min + sel - 2];
         end
      end
   endgenerate

endmodule // variable_delay
