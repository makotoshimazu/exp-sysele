
`timescale 1ps/1ps

`include "assert.vh"

`define clk 3750
`define filename "test_comm.result"

module test_comm;
   integer file;

   reg     CLK;
   reg     RST;

   wire [7:0] ad1;
   wire [7:0] ad2;

   wire [5:0] da1;
   wire [5:0] da2;

   wire       rd_en;
   reg [127:0] din;
   reg         empty;

   wire [127:0] dout;
   wire         wr_en;
   reg          full;

   comm
     #(.valid_delay_min(1),
       .modtype(1))
   inst
     (
      .CLK(CLK),
      .RST(RST),

      .ad1(ad1),
      .ad2(ad2),

      .da1(da1),
      .da2(da2),

      .rd_en(rd_en),
      .din(din),
      .empty(empty),

      .dout(dout),
      .wr_en(wr_en),
      .full(full),

      .ad1_delay(4'd0),
      .ad2_delay(4'd0),
      .ad_valid_delay(4'd0)
      );

   assign ad1 = {1'b1, da1, 1'b0};
   assign ad2 = {1'b1, da2, 1'b0};
                
   task test1;
      begin
         din[31:0] = $random;
         din[63:32] = $random;
         din[95:64] = $random;
         din[127:96] = $random;
         empty = 0;
         #`clk;

         empty = 1;
         #`clk;

         while (!wr_en)
           #`clk;

         `assert_eq(din, dout)
      end
   endtask // test1

   task testmany;
      integer i;
      integer j;
      reg [31:0] mem1[0:99];
      reg [31:0] mem2[0:99];
      reg [31:0] mem3[0:99];
      reg [31:0] mem4[0:99];

      begin
         for (i=0; i<100; i=i+1) begin
            mem1[i] = $random;
            mem2[i] = $random;
            mem3[i] = $random;
            mem4[i] = $random;
         end

         i=1;
         din[31:0] = mem1[0];
         din[63:32] = mem2[0];
         din[95:64] = mem3[0];
         din[127:96] = mem4[0];
         empty = 0;

         j = 0;

         while (i<100 && j<100) begin
            #`clk;
            
            if (wr_en) begin
               `assert_eq(dout[31:0], mem1[j])
               `assert_eq(dout[63:32], mem2[j])
               `assert_eq(dout[95:64], mem3[j])
               `assert_eq(dout[127:96], mem4[j])
               j = j + 1;
            end

            if (rd_en) begin
               din[31:0] = mem1[i];
               din[63:32] = mem2[i];
               din[95:64] = mem3[i];
               din[127:96] = mem4[i];
               i = i + 1;
            end
         end
         
      end
   endtask

   initial begin
      file = $fopen(`filename);

      empty = 1;
      full = 0;

      CLK <= 1'b0;
      RST <= 1'b1;
      #`clk;
      RST <= 1'b0;
      #`clk;
      RST <= 1'b1;
      #`clk;
      #`clk;

      test1;

      #`clk;
      
      testmany;
      
      
      $finish;
   end

   always #(`clk/2) CLK <= ~CLK;

endmodule
