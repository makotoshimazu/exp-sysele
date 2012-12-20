
`timescale 1ps/1ps

`include "assert.vh"

`define clk 3750
`define filename "test_fftfifo.result"

module test_comm_send;
   integer file;

   reg          CLK;
   reg          RST;
  
   wire         wr_en;
   wire [127:0] dout;
   reg          full;

   reg [7:0]    ad1;
   reg [7:0]    ad2;
   reg          ad_valid;

   wire         valid_raw;
   wire [5:0]   raw;

   comm_recv inst
     (
      .CLK(CLK),
      .RST(RST),
     
      .wr_en(wr_en),
      .dout(dout),
      .full(full),

      .ad1(ad1),
      .ad2(ad2),
      .ad_valid(ad_valid),

      .valid_raw(valid_raw),
      .raw(raw)       
      );

   task set_valid_test;

      begin
         while (!wr_en) begin
            ad1 = $random;
            ad2 = $random;
            ad_valid = 1;
            #`clk;
         end
      end
   endtask

   initial begin
      file = $fopen(`filename);

      ad_valid = 0;
      full = 0;

      CLK <= 1'b0;
      RST <= 1'b1;
      #`clk;
      RST <= 1'b0;
      #`clk;
      RST <= 1'b1;
      #`clk;
      #`clk;

      set_valid_test;
      
      
   end

   always #(`clk/2) CLK <= ~CLK;

endmodule
