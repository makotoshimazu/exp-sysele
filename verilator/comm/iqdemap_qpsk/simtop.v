
module simtop 
  (
   input              CLK,
   input              RST,

   input              ce,
  
   input              valid_i,
   input [127:0]      reader_data,
   output             reader_en,

   output reg         valid_o,
   output reg [127:0] writer_data,

   output             valid_raw,
   output [1:0]       raw
   );
   
   wire               valid_1;
   wire [10:0]        ar1, ai1;

   iqmap_qpsk map
     (
      .CLK(CLK),
      .RST(RST),

      .ce(ce),
     
      .valid_i(valid_i),
      .reader_data(reader_data),
      .reader_en(reader_en),

      .xr(ar1),
      .xi(ai1),
      .valid_o(valid_1),

      .valid_raw(),
      .raw()
      );

   iqdemap_qpsk demap
     (
      .CLK(CLK),
      .RST(RST),

      .ce(ce),

      .valid_i(valid_1),
      .ar(ar1),
      .ai(ai1),

      .valid_o(valid_o),
      .writer_data(writer_data),

      .valid_raw(valid_raw),
      .raw(raw)
      );
   
endmodule
