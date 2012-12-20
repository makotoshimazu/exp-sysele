
module lcd_control
  (
   input            CLK,
   input            RST,

   output           update,
   output           lcd_row, 
   output reg [3:0] lcd_col,
   output [7:0]     lcd_char,
   output           lcd_we,

   input            lcd_busy,

   input            valid_i,
   input            start_update,
   input [7:0]      char
   );

   reg              valid_i_d;
   
   assign lcd_char = char;
   assign lcd_we = valid_i;
   assign lcd_row = 1'b0;
   assign update = ~valid_i & valid_i_d;

   always @(posedge CLK or negedge RST)
     if (!RST) begin
        lcd_col <= 4'd0;
     end else begin
        if (valid_i)
          lcd_col <= lcd_col + 4'd1;
        else if (start_update)
          lcd_col <= 4'd0;
     end

   always @(posedge CLK or negedge RST)
     if (!RST) begin
        valid_i_d <= 1'b0;
     end else begin
        valid_i_d <= valid_i;
     end

endmodule
