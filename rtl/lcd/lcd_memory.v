
module lcd_memory
  (
   input            CLK,

   input [4:0]      raddr,
   output reg [7:0] rdata, 

   input [4:0]      waddr,
   input [7:0]      wdata,
   input            wen
   );

   reg [7:0]   mem[0:31];
   
   always @(posedge CLK)
     if (wen)
       mem[waddr] <= wdata;

   always @(posedge CLK)
     rdata <= mem[raddr];
   
endmodule
