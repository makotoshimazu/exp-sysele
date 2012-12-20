
module lcd_ber_top
  #(
    parameter number_of_bits = 8,
    parameter update_period  = 32'd240_000_000
    )
  (
   input        CLK,
   input        RST,

   output       update,
   output       lcd_row, 
   output [3:0] lcd_col,
   output [7:0] lcd_char,
   output       lcd_we,

   input        lcd_busy,

   input        valid_i,
   input [7:0]  sent_data,
   input [7:0]  recv_data
   );

   wire         ber_valid_o;
   wire [31:0]  error_rate;

   wire         start_update;
   wire [7:0]   char;
   wire         n2c_valid_o;

   ber
     #(.update_period(update_period))
   ber_inst
     (
      .CLK(CLK),
      .RST(RST),

      .valid_i(valid_i),
      .sent_data(sent_data),
      .recv_data(recv_data),

      .valid_o(ber_valid_o),
      .error_rate(error_rate)
      );
   assign start_update = ber_valid_o;

   num2char num2char_inst
     (
      .CLK(CLK),
      .RST(RST),

      .start_update(start_update),
      .error_rate(error_rate),

      .char(char),
      .valid_o(n2c_valid_o)
      );

   lcd_control lcd_control_inst
     (
      .CLK(CLK),
      .RST(RST),

      .start_update(start_update),
      .lcd_row(lcd_row), 
      .lcd_col(lcd_col),
      .lcd_char(lcd_char),
      .lcd_we(lcd_we),

      .lcd_busy(lcd_busy),

      .valid_i(n2c_valid_o),
      .update(update),
      .char(char)
      );

endmodule // lcd_test

   
