
module adc_sync
  #(
    parameter adc_idelay_value0 = 24,
    parameter adc_idelay_value1 = 24,
    parameter adc_idelay_value2 = 21,
    parameter adc_idelay_value3 = 35,
    parameter adc_idelay_value4 = 25,
    parameter adc_idelay_value5 = 18,
    parameter adc_idelay_value6 = 21,
    parameter adc_idelay_value7 = 30
    )
  (
   input        DCOP,
   input        DCON,

   input        clk240,
   input        clk200,

   input        nRST,
   input        RST,

   input [7:0]  ADP,
   input [7:0]  ADN,

   output [7:0] ad1_240,
   output [7:0] ad2_240
   );
   
   (* BUFFER_TYPE="none" *)
   wire         ad_dco;

   // ADP,N -- [IBUFDS] -- ad -- [IDELAY] -- ad_delayed
   wire [7:0]   ad;
   wire [7:0]   ad_delayed;

   // ad_delayed -- [IDDR] -- ad1,2
   wire [7:0]   ad1;
   wire [7:0]   ad2;
   
   // ad1,2 -- [FIFO] -- ads240
   // ad_dco     |       clk240   
   wire [15:0]  ads240;

   IBUFDS AD0(.I(ADP[0]), .IB(ADN[0]), .O(ad[0]));
   IBUFDS AD1(.I(ADP[1]), .IB(ADN[1]), .O(ad[1]));
   IBUFDS AD2(.I(ADP[2]), .IB(ADN[2]), .O(ad[2]));
   IBUFDS AD3(.I(ADP[3]), .IB(ADN[3]), .O(ad[3]));
   IBUFDS AD4(.I(ADP[4]), .IB(ADN[4]), .O(ad[4]));
   IBUFDS AD5(.I(ADP[5]), .IB(ADN[5]), .O(ad[5]));
   IBUFDS AD6(.I(ADP[6]), .IB(ADN[6]), .O(ad[6]));
   IBUFDS AD7(.I(ADP[7]), .IB(ADN[7]), .O(ad[7]));
   IBUFDS ADDCO(.I(DCOP), .IB(DCON), .O(ad_dco));

   fifo_ad fifo_ad_inst
     (.rst(!RST),
      .wr_clk(ad_dco),
      .rd_clk(clk240),
      .din({ad1, ad2}),
      .dout(ads240),
      .wr_en(1'b1),
      .rd_en(1'b1),
      .full(),
      .empty());

   genvar adc_io_gen;

   generate
      for (adc_io_gen = 0; adc_io_gen < 8; adc_io_gen = adc_io_gen + 1) begin : GENERATE_ADC_IO

         IDDR #(.DDR_CLK_EDGE("SAME_EDGE"),
                .INIT_Q1(1'b0),
                .INIT_Q2(1'b0),
                .SRTYPE("ASYNC"))
         ADDDR(.Q1(ad1[adc_io_gen]), .Q2(ad2[adc_io_gen]), .C(ad_dco), .CE(1'b1), .D(ad_delayed[adc_io_gen]), .R(!RST), .S(1'b0));

      end // block: GENERATE_ADC_IO
   endgenerate
  
   assign ad1_240 = ads240[15:8];
   assign ad2_240 = ads240[7:0];

   /***************************************************
    EMACS LISP AUTO GENERATION
    (progn
       (forward-line 2)
       (beginning-of-line)
       (insert "\n")
    (dotimes (i 8)
      (insert (format "\
   IODELAY #(.IDELAY_TYPE(\"FIXED\"),\n\
             .IDELAY_VALUE(adc_idelay_value%d),\n\
             .DELAY_SRC(\"I\"),\n\
             .REFCLK_FREQUENCY(200.0))\n\
   ADDELAY%d(.C(clk200),\n\
           .RST(!RST),\n\
\n\
           .CE(1'b0),\n\
           .INC(1'b0),\n\
           .DATAIN(1'b0),\n\
           .IDATAIN(ad[%d]),\n\
           .ODATAIN(1'b0),\n\
           .T(1'b1),\n\
           .DATAOUT(ad_delayed[%d]));\n\n"
    i i i i)))
    (insert "/" "**************************************************" "/\n"))
    
    */         

   IODELAY #(.IDELAY_TYPE("FIXED"),
             .IDELAY_VALUE(adc_idelay_value0),
             .DELAY_SRC("I"),
             .REFCLK_FREQUENCY(200.0))
   ADDELAY0(.C(clk200),
           .RST(!RST),

           .CE(1'b0),
           .INC(1'b0),
           .DATAIN(1'b0),
           .IDATAIN(ad[0]),
           .ODATAIN(1'b0),
           .T(1'b1),
           .DATAOUT(ad_delayed[0]));

   IODELAY #(.IDELAY_TYPE("FIXED"),
             .IDELAY_VALUE(adc_idelay_value1),
             .DELAY_SRC("I"),
             .REFCLK_FREQUENCY(200.0))
   ADDELAY1(.C(clk200),
           .RST(!RST),

           .CE(1'b0),
           .INC(1'b0),
           .DATAIN(1'b0),
           .IDATAIN(ad[1]),
           .ODATAIN(1'b0),
           .T(1'b1),
           .DATAOUT(ad_delayed[1]));

   IODELAY #(.IDELAY_TYPE("FIXED"),
             .IDELAY_VALUE(adc_idelay_value2),
             .DELAY_SRC("I"),
             .REFCLK_FREQUENCY(200.0))
   ADDELAY2(.C(clk200),
           .RST(!RST),

           .CE(1'b0),
           .INC(1'b0),
           .DATAIN(1'b0),
           .IDATAIN(ad[2]),
           .ODATAIN(1'b0),
           .T(1'b1),
           .DATAOUT(ad_delayed[2]));

   IODELAY #(.IDELAY_TYPE("FIXED"),
             .IDELAY_VALUE(adc_idelay_value3),
             .DELAY_SRC("I"),
             .REFCLK_FREQUENCY(200.0))
   ADDELAY3(.C(clk200),
           .RST(!RST),

           .CE(1'b0),
           .INC(1'b0),
           .DATAIN(1'b0),
           .IDATAIN(ad[3]),
           .ODATAIN(1'b0),
           .T(1'b1),
           .DATAOUT(ad_delayed[3]));

   IODELAY #(.IDELAY_TYPE("FIXED"),
             .IDELAY_VALUE(adc_idelay_value4),
             .DELAY_SRC("I"),
             .REFCLK_FREQUENCY(200.0))
   ADDELAY4(.C(clk200),
           .RST(!RST),

           .CE(1'b0),
           .INC(1'b0),
           .DATAIN(1'b0),
           .IDATAIN(ad[4]),
           .ODATAIN(1'b0),
           .T(1'b1),
           .DATAOUT(ad_delayed[4]));

   IODELAY #(.IDELAY_TYPE("FIXED"),
             .IDELAY_VALUE(adc_idelay_value5),
             .DELAY_SRC("I"),
             .REFCLK_FREQUENCY(200.0))
   ADDELAY5(.C(clk200),
           .RST(!RST),

           .CE(1'b0),
           .INC(1'b0),
           .DATAIN(1'b0),
           .IDATAIN(ad[5]),
           .ODATAIN(1'b0),
           .T(1'b1),
           .DATAOUT(ad_delayed[5]));

   IODELAY #(.IDELAY_TYPE("FIXED"),
             .IDELAY_VALUE(adc_idelay_value6),
             .DELAY_SRC("I"),
             .REFCLK_FREQUENCY(200.0))
   ADDELAY6(.C(clk200),
           .RST(!RST),

           .CE(1'b0),
           .INC(1'b0),
           .DATAIN(1'b0),
           .IDATAIN(ad[6]),
           .ODATAIN(1'b0),
           .T(1'b1),
           .DATAOUT(ad_delayed[6]));

   IODELAY #(.IDELAY_TYPE("FIXED"),
             .IDELAY_VALUE(adc_idelay_value7),
             .DELAY_SRC("I"),
             .REFCLK_FREQUENCY(200.0))
   ADDELAY7(.C(clk200),
           .RST(!RST),

           .CE(1'b0),
           .INC(1'b0),
           .DATAIN(1'b0),
           .IDATAIN(ad[7]),
           .ODATAIN(1'b0),
           .T(1'b1),
           .DATAOUT(ad_delayed[7]));

/**************************************************/

   IDELAYCTRL
     idelayctrl_adc1
       (.RST(nRST),
        .REFCLK(clk200),
        .RDY());

   IDELAYCTRL
     idelayctrl_adc2
       (.RST(nRST),
        .REFCLK(clk200),
        .RDY());
        // .RDY(adc_idelay_ready));

endmodule // adc_sync

