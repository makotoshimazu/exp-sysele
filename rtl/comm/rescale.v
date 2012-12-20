
module rescale
  #(parameter width=11)
  (
   input                         CLK,
   input                         RST,

   input [7:0]                   ad1i,
   input [7:0]                   ad2i,
   input                         valid_i,
   
   output reg signed [width-1:0] ad1o,
   output reg signed [width-1:0] ad2o,
   output reg                    valid_o
   );

   wire signed [width-1:0]       ad1;
   wire signed [width-1:0]       ad2;
   wire signed [width-1:0]       offset;

   // [128, 255] -> [0..1023][-1024..-1]
   assign ad1 = {ad1i[6:0], {(width-7){1'b0}}};
   assign ad2 = {ad2i[6:0], {(width-7){1'b0}}};
   // offset 1024
   assign offset = {1'b1, 1'b0, {(width-2){1'b0}}};

   always @(posedge CLK) begin
      ad1o <= (ad1 - offset) >>> 6;
      ad2o <= (ad2 - offset) >>> 6;
   end

   always @(posedge CLK or negedge RST)
     if (!RST) begin
        valid_o <= 1'b0;
     end else begin
        valid_o <= valid_i;
     end


endmodule
