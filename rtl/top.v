
//`define SIMULATION

module sysele
  (
   // Global 100MHz clock
   input         CLK,
   input         CLK_33MHZ_FPGA,
   
   // Reset signal, active low
   input         nRST,

   // North, East, South, West and Center buttons
   // Active High
   input         BTN_N,
   input         BTN_E,
   input         BTN_S,
   input         BTN_W,
   input         BTN_C,

   // DIP Switches
   input [7:0]   DIP,

   // North, East, South, West and Center LEDs
   // Active High
   output        LED_N,
   output        LED_E,
   output        LED_S,
   output        LED_W,
   output        LED_C,

   // LEDs
   output [7:0]  LED,

   // LCD driver
   inout [3:0]  LCDDATA,
   output        RS,
   output        RW,
   output        EN,

   // SystemACE MPU Interface
   output [6:0]  MPA,
   inout [15:0]  MPD,
   output        nMPCE,
   output        nMPWE,
   output        nMPOE,
   input         MPBRDY,
   input         MPIRQ,

   // DAC interface
   output [9:4]  DA2,
   output        DACLK,
   output [9:4]  DA1,

   // ADC interface
   input [7:0]   ADN,
   input [7:0]   ADP,
   input         DCON,
   input         DCOP,
   output        ADC_nOE,
   output        SCLK,
   inout         SDIO,
   output        CSB,
   output        ADCLKP,
   output        ADCLKN,

   // DDR2 interface
   output [12:0] ddr2_a,
   output [1:0]  ddr2_ba,
   output        ddr2_ras_n,
   output        ddr2_cas_n,
   output        ddr2_we_n,
   output [1:0]  ddr2_cs_n,
   output [1:0]  ddr2_odt,
   output [1:0]  ddr2_cke,
   output [7:0]  ddr2_dm,
   
   inout [63:0]  ddr2_dq, 
   inout [7:0]   ddr2_dqs,
   inout [7:0]   ddr2_dqs_n,
   output [1:0]  ddr2_ck,
   output [1:0]  ddr2_ck_n
   );

   // ==================================================
   // WIRES
   // ==================================================
   // --------------------------------------------------
   // CLOCKS
   // --------------------------------------------------
   wire          clk33, clk40, exec, busy, hsync, vsync, active;
   wire          clk80;
   wire          clk100;
   wire          clk240;
   wire          clk240n;
   wire          clk125;
   wire          clk66;

   wire          clkcomm;
   wire          clkadc;

   reg [24:0]    counter;

   // --------------------------------------------------
   // PLLS
   // --------------------------------------------------
   wire          locked, locked1, locked2, locked3, locked4;
   wire          rstgen;

   // --------------------------------------------------
   // ADC
   // --------------------------------------------------
   wire          adclk;
   wire [7:0]    ad;
   wire [7:0]    ad_delayed;
   wire [7:0]    ad1;
   wire [7:0]    ad2;
   wire          ad_dco;

   // ch1, ch2
   wire [7:0]    ad1_240;
   wire [7:0]    ad2_240;

   // SPI signals
   wire [7:0]  adc_recvdata;

   wire        adc_spi_button;

   // --------------------------------------------------
   // DAC
   // --------------------------------------------------
   wire          daclk;

   wire [5:0]    da1_nd;
   wire [5:0]    da2_nd;

   // --------------------------------------------------
   // SYSTEMACE
   // --------------------------------------------------
   wire [15:0]   sysace_read_data;
   wire          sysace_read_avail;

   wire          sysace_top_busy;
   wire          sysace_top_start;

   wire          llread;
   wire          llwrite;
   wire [15:0]   llwritedata;
   wire [6:0]    lladdr;
   wire [15:0]   llreaddata;
   wire          llavail;
   wire          llbusy;
   wire          ll_isbuffer;

   wire [27:0]   sysace_mpulba;
   wire [7:0]    sysace_nsectors;
   wire          sysace_start;
   wire          sysace_busy;

   wire          start;

   reg [15:0]    readreg;
   
   wire [21:1] data_w_address;
   wire [31:0] data_w;
   wire       data_w_full;
   wire       data_w_we;
   
   wire [21:1] data_r_address;
   wire [31:0] data_r;
   wire        data_r_empty;
   wire        data_r_req;

   wire [15:0] fifo_dout;
   wire        fifo_full;
   wire        fifo_empty;
   wire        rd_en;

   wire [27:0] mpulba_80;
   wire [7:0]  nsectors_80;

   wire        sysace_start_80;
   wire        sysace_busy_80;

   wire        picload_start;
   wire        picload_busy;

   wire        fps30_start;
   wire        frame;

   // --------------------------------------------------
   // DDR2
   // --------------------------------------------------
   wire        ddr2_rstout;
   wire        ddr2_clk;

   wire        app_af_wren;
   wire        app_af_afull;
   wire [30:0] app_af_addr;
   wire        app_af_read;

   wire        app_wdf_wren;
   wire        app_wdf_afull;
   wire [127:0] app_wdf_data;
   wire [15:0] app_wdf_mask_data;

   wire        phy_init_done;

   wire        rd_data_valid;
   wire [127:0] rd_data_fifo_out;

   wire         ddr2_test_start;
   wire         ddr2_test_busy;
   wire         ddr2_test_done;
   wire         ddr2_test_error;

   // --------------------------------------------------
   // DDR2 ARB
   // --------------------------------------------------
   wire          ddr2_req1;
   wire         ddr2_ack1;
   wire [30:0]   ddr2_addr1;
   wire          ddr2_read1;
   wire          ddr2_fin1;
   wire [255:0]  ddr2_data1_i;
   wire [31:0]   ddr2_mask1;
   wire         ddr2_valid1;
   wire [127:0] ddr2_data1_o;
   
   wire          ddr2_req2;
   wire          ddr2_ack2;
   wire [30:0]   ddr2_addr2;
   wire          ddr2_read2;
   wire          ddr2_fin2;
   wire [255:0]  ddr2_data2_i;
   wire [31:0]   ddr2_mask2;
   wire         ddr2_valid2;
   wire [127:0] ddr2_data2_o;

   wire          ddr2_req3;
   wire         ddr2_ack3;
   wire [30:0]   ddr2_addr3;
   wire          ddr2_read3;
   wire          ddr2_fin3;
   wire [255:0]  ddr2_data3_i;
   wire [31:0]   ddr2_mask3;
   wire         ddr2_valid3;
   wire [127:0] ddr2_data3_o;

   wire         ddr2_req4;
   wire         ddr2_ack4;
   wire [30:0]  ddr2_addr4;
   wire         ddr2_read4;
   wire         ddr2_fin4;
   wire [255:0] ddr2_data4_i;
   wire [31:0]  ddr2_mask4;
   wire         ddr2_valid4;
   wire [127:0] ddr2_data4_o;

   wire         ddr2_req5;
   wire         ddr2_ack5;
   wire [30:0]  ddr2_addr5;
   wire         ddr2_read5;
   wire         ddr2_fin5;
   wire [255:0] ddr2_data5_i;
   wire [31:0]  ddr2_mask5;
   wire         ddr2_valid5;
   wire [127:0] ddr2_data5_o;

   // TEST
   wire writer_en;
   wire [127:0] writer_din;
   wire         writer_full;
   
   wire         reader_en;
   wire [127:0] reader_dout;
   wire         reader_empty;
   wire         reader_almost_empty;
   
   // --------------------------------------------------
   // LCD
   // --------------------------------------------------
   wire [7:0] lcd_char;
   wire [3:0] lcd_col;
   wire       lcd_row;
   wire       lcd_we;
   wire       lcd_busy;
   wire       lcd_update;

   // --------------------------------------------------
   // BER
   // --------------------------------------------------
   wire  lcd_ber_valid_i;
   wire  [7:0]  ber_sent_data;
   wire  [7:0]  ber_recv_data;

   // --------------------------------------------------
   // COMM
   // --------------------------------------------------
   wire [3:0] ad1_delay;
   wire [3:0] ad2_delay;
   wire [3:0] ad_valid_delay;

   // ==================================================
   // INSTANCES AND ASSIGNMENTS
   // ==================================================
   // **************************************************
   // CLOCK GENERATORS
   // **************************************************
   // --------------------------------------------------
   // PLLS
   // --------------------------------------------------
`ifndef SIMULATION
   pll pll(
           .CLKIN1_IN(CLK),
           .RST_IN(!nRST),
           .CLKOUT0_OUT(clk40),
           .CLKOUT1_OUT(clk33),
           .CLKOUT2_OUT(clk80),
           .CLKOUT3_OUT(clk80_2),
           .CLKOUT4_OUT(clk100),
           .LOCKED_OUT(locked1));

   pll2 pll2(
             .CLKIN1_IN(clk80_2),
             .RST_IN(!locked1),
             .CLKOUT0_OUT(clk240),
             .CLKOUT1_OUT(clk240n),
             .CLKOUT2_OUT(),
             .LOCKED_OUT(locked2));

   pll3 pll3(
             .CLKIN1_IN(clk100),
             .RST_IN(!locked1),
             .CLKOUT0_OUT(clk200),
             .CLKOUT1_OUT(clk266),
             .CLKOUT2_OUT(clk266_90),
             .CLKOUT3_OUT(clk133),
             .LOCKED_OUT(locked3));   
   
   pll4 pll4(
             .CLKIN1_IN(clk100),
             .RST_IN(!locked1),
             .CLKOUT0_OUT(clk125),
             .CLKOUT1_OUT(clk66),
             .LOCKED_OUT(locked4));

`endif

   rstgen rstmod(.CLK(clk40),
                 .nRST(nRST),
                 .locked(locked),
                 .rstgen(rstgen));

   assign locked = locked1 & locked2 & locked3 & locked4;

   // always @(posedge ad_dco or negedge nRST)
   //   begin
   //      if (!nRST) 
   //        counter <= 25'h0;
   //      else
   //        counter <= counter + 25'h1;
   //   end

   // **************************************************
   // CLK_33MHZ_FPGA
   // **************************************************
   // --------------------------------------------------
   // SYSTEMACE
   // --------------------------------------------------
   systemace systemace
     (.CLK(CLK_33MHZ_FPGA),
      .RST(rstgen),

      .llread(llread),
      .llwrite(llwrite),
      .llwritedata(llwritedata),
      .lladdr(lladdr),
      .llreaddata(llreaddata),
      .llavail(llavail),
      .llbusy(llbusy),
      .ll_isbuffer(ll_isbuffer),

      .mpulba(sysace_mpulba),
      .nsectors(sysace_nsectors),

      .start(sysace_start),
      .busy(sysace_busy),

      .sysace_read_data(sysace_read_data),
      .sysace_read_avail(sysace_read_avail));

   systemace_ll systemace_ll
     (.CLK(CLK_33MHZ_FPGA),
      .RST(rstgen),

      .MPA(MPA),
      .MPD(MPD),
      .nMPCE(nMPCE),
      .nMPWE(nMPWE),
      .nMPOE(nMPOE),
      .MPBRDY(MPBRDY),
      .MPIRQ(MPIRQ),

      .llread(llread),
      .llwrite(llwrite),
      .llwritedata(llwritedata),
      .lladdr(lladdr),
      .llreaddata(llreaddata),
      .llavail(llavail),
      .llbusy(llbusy),
      .ll_isbuffer(ll_isbuffer)
      );

   // --------------------------------------------------
   // ADC
   // --------------------------------------------------
   // assign clkadc = clkcomm;
   
   // wire       ADCLKN_;
   // wire       ADCLKP_;
   
   OBUFDS 
     ADCLK(.I(clkadc),
           .O(ADCLKN),
           .OB(ADCLKP));

   IODELAY 
     #(.REFCLK_FREQUENCY(200.0),
       .ODELAY_VALUE(25),
       .DELAY_SRC("O"),
       .IDELAY_TYPE("FIXED"),
       .SIGNAL_PATTERN("CLOCK"))
   odelay_adc
     (.C(clk200),
      .DATAOUT(clkadc),
      .CE(1'b1),
      .DATAIN(1'b0),
      .IDATAIN(1'b0),
      .INC(1'b0),
      .ODATAIN(clkcomm),
      .RST(!rstgen),
      .T(1'b0));
      
   adc_sync adc_sync_inst
     (
      .DCOP(DCOP),
      .DCON(DCON),

      .clk240(clkcomm),
      .clk200(clk200),

      .nRST(nRST),
      .RST(rstgen),

      .ADP(ADP),
      .ADN(ADN),

      // edge
      .ad1_240(ad2_240),
      .ad2_240(ad1_240)
      );

   adc_test adc_test_inst(
                          .CLK(clkcomm),
                          .RST(rstgen),

                          .SDIO(SDIO),
                          .SCLK(SCLK),
                          .CSB(CSB),

                          .recvdata(adc_recvdata),

                          .button(adc_spi_button));

   assign ADC_nOE = 1'b0;

   wire [127:0] writer_ad_din;
   wire         writer_ad_full;
   wire         writer_ad_en;
   
   async_seq_writer
     #(.address_bottom(30'h0100_0000),
       .address_top(30'h0200_0000 - 30'd4)
       )
   writer_ad
     (
      .ddr2_clk(ddr2_clk),
      .wr_clk(clkcomm),
      .RST(rstgen),

      .req(ddr2_req2),
      .ack(ddr2_ack2),
      .addr(ddr2_addr2),
      .read(ddr2_read2),
      .fin(ddr2_fin2),

      .data_write(ddr2_data2_i),
      .mask(ddr2_mask2),

      .valid(ddr2_valid2),
      .data_read(ddr2_data2_o),

      .wr_en(writer_ad_en),
      .din(writer_ad_din),
      .fifo_full(writer_ad_full));
   
   // --------------------------------------------------
   // DAC
   // --------------------------------------------------
   assign DACLK  = clkcomm;

   wire [127:0] reader_da_dout;
   wire         reader_da_empty;
   wire         reader_da_en;
   wire         reader_da_start;

   dac_delay dac_delay_inst
     (.clkcomm(clkcomm),
      .clk200(clk200),
      
      .RST(rstgen),
      .DA1(DA1),
      .DA2(DA2),

      .da1_nd(da1_nd),
      .da2_nd(da2_nd));
      

   async_seq_reader
     #(.address_bottom(30'h0000_0000),
       .address_top(30'h200_000 - 30'd4)
       // .address_top(30'h0100_0000 - 30'd4)
       // .address_top(30'd512 - 30'd4)
       )
   reader_da
     (
      .ddr2_clk(ddr2_clk),
      .rd_clk(clkcomm),
      .RST(rstgen),

      .req(ddr2_req1),
      .ack(ddr2_ack1),
      .addr(ddr2_addr1),
      .read(ddr2_read1),
      .fin(ddr2_fin1),

      .data_write(ddr2_data1_i),
      .mask(ddr2_mask1),

      .valid(ddr2_valid1),
      .data_read(ddr2_data1_o),

      .rd_en(reader_da_en),
      .dout(reader_da_dout),
      .fifo_empty(reader_da_empty),
      .fifo_almost_empty(),
      .start(reader_da_start),
      .bottom(1'b0));

   // --------------------------------------------------
   // COMM
   // --------------------------------------------------
   // assign clkcomm = clk240;
   assign clkcomm = clk80;
   
   comm
     #(.modtype(1),
       .valid_delay_min(32))
   comm_inst
     (
      .CLK(clkcomm),
      .RST(rstgen),

      .ad1(ad1_240),
      .ad2(ad2_240),

      .da1(da1_nd),
      .da2(da2_nd),

      .rd_en(reader_da_en),
      .din(reader_da_dout),
      .empty(reader_da_empty),

      .dout(writer_ad_din),
      .wr_en(writer_ad_en),
      .full(writer_ad_full),

      .ad1_delay(ad1_delay),
      .ad2_delay(ad2_delay),
      .ad_valid_delay(ad_valid_delay),

      .raw_send_d(ber_sent_data),
      .raw_recv(ber_recv_data),
      .valid_raw(lcd_ber_valid_i)
      );
   

   // **************************************************
   // misc
   // **************************************************
   // --------------------------------------------------
   // CONTROL
   // --------------------------------------------------
   control control_inst
     (.clk240(clk240),
      .clk80(clk80),
      .clk66(clk66),
      .clk_sysace(CLK_33MHZ_FPGA),
      .clkcomm(clkcomm),

      .RST(rstgen),

      .DIP(DIP),

      .BTN_N(BTN_N),
      .BTN_E(BTN_E),
      .BTN_S(BTN_S),
      .BTN_W(BTN_W),
      .BTN_C(BTN_C),

      .lcd_row(),
      .lcd_col(),
      .lcd_char(),
      .lcd_we(),

      .lcd_update(),
      .lcd_busy(),

      .reader_da_start(reader_da_start),
      .reader_da_bottom(reader_da_bottom),
      .reader_eth_start(reader_eth_start),
      .reader_eth_bottom(reader_eth_bottom),

      .fps30_start(fps30_start),

      .sysace_top_start(sysace_top_start),

      .adc_spi_button(adc_spi_button),
      .ad1_delay(ad1_delay),
      .ad2_delay(ad2_delay),
      .ad_valid_delay(ad_valid_delay));
   
   // --------------------------------------------------
   // LEDS AND SWITCHES
   // --------------------------------------------------
   assign LED = DIP == 8'b0 ? app_af_cmd[23:16] : 
                DIP == 8'd4 ? ad1_240 : 
                DIP == 8'd5 ? ad2_240 : 
                DIP == 8'd128 ? ad1_delay : 
                DIP == 8'd129 ? ad2_delay : 
                DIP == 8'd130 ? ad_valid_delay : 
                DIP == 8'd131 ? DA1 : 
                DIP == 8'd132 ? DA2 : 
                8'h0;

   assign LED_C = 1'b0;
   assign LED_S = 1'b0;
   assign LED_E = 1'b0;
   assign LED_W = 1'b0;
   assign LED_N = 1'b0;
   
   // --------------------------------------------------
   // LCD
   // --------------------------------------------------
   lcd lcd_inst
     (.CLK(clkcomm),
      .RST(rstgen),

      .LCD_DATA(LCDDATA),
      .RS(RS),
      .RW(RW),
      .EN(EN),

      .row(lcd_row),
      .col(lcd_col),
      .char(lcd_char),
      .we(lcd_we),

      .busy(lcd_busy),

      .update(lcd_update)
      );
   
   lcd_ber_top
     #(
       .update_period(32'd80_000_000)
       )
      lcd_ber_top_inst
     (
      .CLK(clkcomm),
      .RST(rstgen),

      .update(lcd_update),
      .lcd_row(lcd_row),
      .lcd_col(lcd_col),
      .lcd_char(lcd_char),
      .lcd_we(lcd_we),

      .lcd_busy(lcd_busy),

      .valid_i(lcd_ber_valid_i),
      .sent_data(ber_sent_data),
      .recv_data(ber_recv_data)
      );
   
   // --------------------------------------------------
   // DDR
   // --------------------------------------------------   
   ddr2 ddr2_inst
     (
      // chip
      .ddr2_a(ddr2_a),
      .ddr2_ba(ddr2_ba),
      .ddr2_ras_n(ddr2_ras_n),
      .ddr2_cas_n(ddr2_cas_n),
      .ddr2_we_n(ddr2_we_n),
      .ddr2_cs_n(ddr2_cs_n),
      .ddr2_odt(ddr2_odt),
      .ddr2_cke(ddr2_cke),
      .ddr2_dm(ddr2_dm),

      .ddr2_dq(ddr2_dq),
      .ddr2_dqs(ddr2_dqs),
      .ddr2_dqs_n(ddr2_dqs_n),
      .ddr2_ck(ddr2_ck),
      .ddr2_ck_n(ddr2_ck_n),
      
      // system signals
      .sys_rst_n(rstgen),
      .phy_init_done(phy_init_done),
      .locked(locked),
      .clk0(clk266),
      .clk90(clk266_90),
      .clkdiv0(clk133),
      .clk200(clk200),

      // user if signals
      .rst0_tb(ddr2_rstout),
      .clk0_tb(ddr2_clk),
      .app_wdf_afull(app_wdf_afull),
      .app_af_afull(app_af_afull),
      .rd_data_valid(rd_data_valid),
      .app_wdf_wren(app_wdf_wren),
      .app_af_wren(app_af_wren),
      .app_af_addr(app_af_addr),
      .app_af_cmd({2'b00, app_af_read}),
      .rd_data_fifo_out(rd_data_fifo_out),
      .app_wdf_data(app_wdf_data),
      .app_wdf_mask_data(app_wdf_mask_data));


   ddr2_arb_top arb_top_inst
     (
      .CLK(ddr2_clk),
      .RST(rstgen),

      // * .IF(IF) .1(1)
      // ** .control(control)
      .req1(ddr2_req1),
      .ack1(ddr2_ack1),
      .addr1(ddr2_addr1),
      .read1(ddr2_read1),
      .fin1(ddr2_fin1),

      // ** .write(ddr2_write)
      .data1_i(ddr2_data1_i),
      .mask1(ddr2_mask1),

      // ** .read(ddr2_read)
      .valid1(ddr2_valid1),
      .data1_o(ddr2_data1_o),
      
      // * .IF(ddr2_IF) .2(ddr2_2)
      // ** .control(ddr2_control)
      .req2(ddr2_req2),
      .ack2(ddr2_ack2),
      .addr2(ddr2_addr2),
      .read2(ddr2_read2),
      .fin2(ddr2_fin2),

      // ** .write(ddr2_write)
      .data2_i(ddr2_data2_i),
      .mask2(ddr2_mask2),

      // ** .read(ddr2_read)
      .valid2(ddr2_valid2),
      .data2_o(ddr2_data2_o),

      // * .IF(ddr2_IF) .3(ddr2_3)
      // ** .control(ddr2_control)
      .req3(ddr2_req3),
      .ack3(ddr2_ack3),
      .addr3(ddr2_addr3),
      .read3(ddr2_read3),
      .fin3(ddr2_fin3),

      // ** .write(ddr2_write)
      .data3_i(ddr2_data3_i),
      .mask3(ddr2_mask3),

      // ** .read(ddr2_read)
      .valid3(ddr2_valid3),
      .data3_o(ddr2_data3_o),

      // * .IF(ddr2_IF) .4(ddr2_4)
      // ** .control(ddr2_control)
      .req4(ddr2_req4),
      .ack4(ddr2_ack4),
      .addr4(ddr2_addr4),
      .read4(ddr2_read4),
      .fin4(ddr2_fin4),

      // ** .write(ddr2_write)
      .data4_i(ddr2_data4_i),
      .mask4(ddr2_mask4),

      // ** .read(ddr2_read)
      .valid4(ddr2_valid4),
      .data4_o(ddr2_data4_o),

      // * .IF(ddr2_IF) .5(ddr2_5)
      // ** .control(ddr2_control)
      .req5(ddr2_req5),
      .ack5(ddr2_ack5),
      .addr5(ddr2_addr5),
      .read5(ddr2_read5),
      .fin5(ddr2_fin5),

      // ** .write(ddr2_write)
      .data5_i(ddr2_data5_i),
      .mask5(ddr2_mask5),

      // ** .read(ddr2_read)
      .valid5(ddr2_valid5),
      .data5_o(ddr2_data5_o),

      // .DDR2(DDR2) .IF(IF)
      .phy_init_done(phy_init_done),
      
      .app_af_wren(app_af_wren),
      .app_af_afull(app_af_afull),
      .app_af_addr(app_af_addr),
      .app_af_read(app_af_read),

      .app_wdf_wren(app_wdf_wren),
      .app_wdf_afull(app_wdf_afull),
      .app_wdf_data(app_wdf_data),
      .app_wdf_mask_data(app_wdf_mask_data),

      .rd_data_valid(rd_data_valid),
      .rd_data_fifo_out(rd_data_fifo_out)
      );

   assign ddr2_req3 = 1'b0;
   assign ddr2_req4 = 1'b0;
   
   wire         writer_cf_en;
   wire [127:0] writer_cf_din;
   wire         writer_cf_full;

   sysace_top sysace_top
     (.CLK(CLK_33MHZ_FPGA),
      .RST(rstgen),

      .mpulba(sysace_mpulba),
      .nsectors(sysace_nsectors),
      .sysace_start(sysace_start),
      .sysace_busy(sysace_busy),
      .sysace_read_data(sysace_read_data),
      .sysace_read_avail(sysace_read_avail),

      .wr_en(writer_cf_en),
      .dout(writer_cf_din),
      .fifo_full(writer_cf_full),

      .start(sysace_top_start),
      .busy(sysace_top_busy));

   async_seq_writer writer_cf
     (.ddr2_clk(ddr2_clk),
      .wr_clk(CLK_33MHZ_FPGA),
      .RST(rstgen),

      .req(ddr2_req5),
      .ack(ddr2_ack5),
      .addr(ddr2_addr5),
      .read(ddr2_read5),
      .fin(ddr2_fin5),
      
      .data_write(ddr2_data5_i),
      .mask(ddr2_mask5),

      .valid(ddr2_valid5),
      .data_read(ddr2_data5_o),

      .wr_en(writer_cf_en),
      .din(writer_cf_din),
      .fifo_full(writer_cf_full));

endmodule // sysele
