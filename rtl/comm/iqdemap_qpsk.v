
module iqdemap_qpsk 
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
   output reg [1:0]    raw
   );

`define SW 2
   localparam s_idle = `SW'b01;
   localparam s_active = `SW'b10;
   reg [`SW-1:0]      state;
`undef SW

   reg                valid_1;
   reg signed [11:0]  add;
   reg signed [11:0]  sub;
   
   wire [1:0]         dem;

   localparam counter_top = 6'h3f;
   reg [5:0]          counter;
   
   always @(posedge CLK or negedge RST)
     if (!RST) begin
        valid_1 <= 1'b0;
     end else begin
        if (ce)
          valid_1 <= valid_i;
     end

   always @(posedge CLK) 
     if (ce) begin
        add <= ar + ai;
        sub <= ar - ai;
     end

   assign dem 
     = add > 0 ?
       (sub > 0 ? 2'b00 : 2'b01) :
       (sub > 0 ? 2'b10 : 2'b11);

   always @(posedge CLK or negedge RST)
     if (!RST) begin
        valid_raw <= 1'b0;
     end else begin
        if (ce)
          valid_raw <= valid_1;
     end

   always @(posedge CLK)
     if (ce)
       if (valid_1)
         raw <= dem;

   always @(posedge CLK) begin
      if (ce) begin
         if (valid_1)
           writer_data <= {dem, writer_data[127:2]};
      end
   end

   always @(posedge CLK or negedge RST)
     if (!RST) begin
        counter <= 6'd0;
     end else begin
        if (ce) begin
           if (valid_1)
             counter <= counter + 6'd1;
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
