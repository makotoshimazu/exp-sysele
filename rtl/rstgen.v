
module rstgen
  (input CLK,
   input nRST,
   input  locked,

   output reg rstgen);

   reg [7:0] counter;
   
   always @(posedge CLK or negedge nRST)
     if (!nRST)
       counter <= 8'h00;
     else begin
        if (locked)
          if (counter != 8'd255)
            counter <= counter + 8'd1;
     end

   always @(posedge CLK or negedge nRST)
     if (!nRST)
       rstgen <= 1'b0;
     else if (counter == 8'd255)
       rstgen <= 1'b1;

endmodule // rstgen

             