
module control
  (
   input            clk240,
   input            clk80,
   input            clk66,
   input            clk_sysace,
   input            clkcomm,

   input            RST,

   // DIP Switches
   input [7:0]      DIP,

   // North, East, South, West and Center LEDs
   // Active High
   input            BTN_N,
   input            BTN_E,
   input            BTN_S,
   input            BTN_W,
   input            BTN_C,

   output           lcd_row,
   output [3:0]     lcd_col,
   output [7:0]     lcd_char,
   output           lcd_we,

   output           lcd_update,
   input            lcd_busy,

   output reg       reader_da_start,
   output           reader_da_bottom,

   output           reader_eth_start,
   output           reader_eth_bottom,

   output           fps30_start,

   output           sysace_top_start,

   output           adc_spi_button,

   output reg [3:0] ad1_delay,
   output reg [3:0] ad2_delay,
   output reg [3:0] ad_valid_delay
   );

   assign reader_da_bottom = 1'b0;
   assign reader_eth_bottom = 1'b0;

   wire         reader_da_start_button = DIP == 8'd0 && BTN_C;
   wire         reader_eth_start_button = DIP == 8'd0 && BTN_E;
   wire         fps30_start_button = DIP == 8'd0 && BTN_N;
   wire         sysace_top_start_button = DIP == 8'd1 && BTN_C;

   wire         ad1_incr_button = DIP == 8'd128 && BTN_N;
   wire         ad1_decr_button = DIP == 8'd128 && BTN_S;
   wire         ad2_incr_button = DIP == 8'd129 && BTN_N;
   wire         ad2_decr_button = DIP == 8'd129 && BTN_S;
   wire         adv_incr_button = DIP == 8'd130 && BTN_N;
   wire         adv_decr_button = DIP == 8'd130 && BTN_S;

   assign       adc_spi_button = DIP == 8'd4 && BTN_S;

   wire         ad1_incr;
   wire         ad1_decr;
   wire         ad2_incr;
   wire         ad2_decr;
   wire         adv_incr;
   wire         adv_decr;
   wire         reader_da_start_toggle;

   switch sw_da
     (.CLK(clkcomm),
      .RST(RST),

      .sw(reader_da_start_button),
      .pos(reader_da_start_toggle));

   switch sw_eth
     (.CLK(clk66),
      .RST(RST),

      .sw(reader_eth_start_button),
      .pos(reader_eth_start));
   
   switch sw_btn_n
     (.CLK(clk80),
      .RST(RST),

      .sw(fps30_start_button),

      .pos(fps30_start),
      .neg(),
      .d()
      );

   switch sw_ad1_incr
     (.CLK(clkcomm),
      .RST(RST),

      .sw(ad1_incr_button),
      .pos(ad1_incr));

   switch sw_ad1_decr
     (.CLK(clkcomm),
      .RST(RST),

      .sw(ad1_decr_button),
      .pos(ad1_decr));

   switch sw_ad2_incr
     (.CLK(clkcomm),
      .RST(RST),

      .sw(ad2_incr_button),
      .pos(ad2_incr));

   switch sw_ad2_decr
     (.CLK(clkcomm),
      .RST(RST),
      .sw(ad2_decr_button),
      .pos(ad2_decr));

   switch sw_adv_incr
     (.CLK(clkcomm),
      .RST(RST),
      .sw(adv_incr_button),
      .pos(adv_incr));

   switch sw_adv_decr
     (.CLK(clkcomm),
      .RST(RST),
      .sw(adv_decr_button),
      .pos(adv_decr));

   switch sw_sysace_top_start
     (.CLK(clk_sysace),
      .RST(RST),
      .sw(sysace_top_start_button),
      .pos(sysace_top_start));

   always @(posedge clkcomm or negedge RST)
     if (!RST) begin
        // 240
        // ad1_delay <= 4'd5;

        // 80
        ad1_delay <= 4'd2;
     end else begin
        if (ad1_incr)
          ad1_delay <= ad1_delay + 4'd1;
        else if (ad1_decr)
          ad1_delay <= ad1_delay - 4'd1;
     end

   always @(posedge clkcomm or negedge RST)
     if (!RST) begin
        // 240
        // ad2_delay <= 4'd0;

        // 80
        ad2_delay <= 4'd0;
     end else begin
        if (ad2_incr)
          ad2_delay <= ad2_delay + 4'd1;
        else if (ad2_decr)
          ad2_delay <= ad2_delay - 4'd1;
     end

   always @(posedge clkcomm or negedge RST)
     if (!RST) begin
        // 240
        // ad_valid_delay <= 4'd8;

        // 80
        ad_valid_delay <= 4'd0;
     end else begin
        if (adv_incr)
          ad_valid_delay <= ad_valid_delay + 4'd1;
        else if (adv_decr)
          ad_valid_delay <= ad_valid_delay - 4'd1;
     end // else: !if(!RST)

   always @(posedge clkcomm or negedge RST)
     if (!RST) begin
        reader_da_start <= 1'b0;
     end else begin
        if (reader_da_start_toggle)
          reader_da_start <= ~reader_da_start;
     end

endmodule
