
module prienc
  (
   input  in0,
   input  in1,
   input  in2,
   input  in3,
   input  in4,
   input  en,
   output out0,
   output out1,
   output out2,
   output out3,
   output out4
   );

   reg [4:0] out;

   assign {out4, out3, out2, out1, out0} = out;
   
   always @* begin
      if (!en)
        out <= 5'b00000;
      else if (in0)
        out <= 5'b00001;
      else if (in1)
        out <= 5'b00010;
      else if (in2)
        out <= 5'b00100;
      else if (in3)
        out <= 5'b01000;
      else if (in4)
        out <= 5'b10000;
      else
        out <= 5'b00000;
   end
   
endmodule
