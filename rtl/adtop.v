
module adtop 
  (
   input              CLK,
   input              RST,

   input [7:0]        din1,
   input [7:0]        din2,
   input              valid,

   output reg [127:0] dout,
   output reg         wr_en,
   input              full
   );

   localparam counter_top = 3'd7;
   reg [2:0]          counter;

   always @(posedge CLK) begin
      if (valid)
        dout <= {dout[111:0], din1, din2};
      
   end

   always @(posedge CLK or negedge RST)
     if (!RST) begin
        counter <= 3'd0;
     end else begin
        if (valid)
          counter <= counter + 3'd1;
     end

   always @(posedge CLK or negedge RST)
     if (!RST) begin
        wr_en <= 1'b0;
     end else begin
        if (counter == counter_top && valid)
          wr_en <= 1'b1;
        else
          wr_en <= 1'b0;
     end


endmodule
