
module iqdemap_bpsk 
  (
   input               CLK,
   input               RST,

   input               ce,

   input               valid_i,
   input signed [10:0] ar,
   input signed [10:0] ai,

   output reg          valid_o,
   output reg [127:0]  writer_data,

   output reg          valid_raw,
   output reg          raw
   );

`define SW 2
   localparam s_idle = `SW'b01;
   localparam s_active = `SW'b10;
   reg [`SW-1:0]      state;
`undef SW

   wire               dem;

   localparam counter_top = 7'h7f;
   reg [6:0]          counter;
   
   assign dem = ar > 0 ? 1'b1 : 1'b0;

   always @(posedge CLK)
     if (ce)
       raw <= dem;

   always @(posedge CLK or negedge RST)
     if (!RST) begin
        valid_raw <= 1'b0;
     end else begin
        if (ce)
          valid_raw <= valid_i;
     end


   always @(posedge CLK) begin
      if (ce) begin
         if (valid_i)
           writer_data <= {dem, writer_data[127:1]};
      end
   end

   always @(posedge CLK or negedge RST)
     if (!RST) begin
        counter <= 7'd0;
     end else begin
        if (ce) begin
           if (valid_i)
             counter <= counter + 7'd1;
        end
     end

   always @(posedge CLK) begin
      if (ce) begin
         if (counter == counter_top)
           valid_o <= 1'b1;
         else
           valid_o <= 1'b0;
      end
   end


endmodule
