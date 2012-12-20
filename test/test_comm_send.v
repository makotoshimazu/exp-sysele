
`timescale 1ps/1ps

`include "assert.vh"

`define clk 3750
`define filename "test_fftfifo.result"

module test_comm_send;
   integer file;
   
   reg         CLK;
   reg         RST;
   
   wire        rd_en;
   reg [127:0] din;
   reg         empty;

   wire        da_valid;
   wire [5:0]  da1;
   wire [5:0]  da2;

   wire        valid_raw;
   wire [5:0]  raw;

   comm_send inst
     (
      .CLK(CLK),
      .RST(RST),
     
      .rd_en(rd_en),
      .din(din),
      .empty(empty),

      .da_valid(da_valid),
      .da1(da1),
      .da2(da2),

      .valid_raw(valid_raw),
      .raw(raw)       
      );

   task set_valid_test;

      begin
         din[31:0] = $random;
         din[63:32] = $random;
         din[95:64] = $random;
         din[127:96] = $random;
         empty = 0;

         while (!da_valid)
           #`clk;
      end
   endtask

   initial begin
      file = $fopen(`filename);

      empty = 1;

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
