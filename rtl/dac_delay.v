
module dac_delay
  (
   input        clkcomm,
   input        clk200,
   input        RST,

   output [5:0] DA1,
   output [5:0] DA2,

   input [5:0]  da1_nd,
   input [5:0]  da2_nd
   );
   
   generate
      genvar    g;

      for (g=0; g<6; g=g+1) begin : GENERATE_DAC_DELAY
         IODELAY
             #(.REFCLK_FREQUENCY(200.0),
               .ODELAY_VALUE(25),
               .DELAY_SRC("O"),
               .IDELAY_TYPE("FIXED"),
               .SIGNAL_PATTERN("DATA"))
         odelay1
             (.C(clk200),
              .DATAOUT(DA1[g]),
              .CE(1'b1),
              .DATAIN(1'b0),
              .IDATAIN(1'b0),
              .INC(1'b0),
              .ODATAIN(da1_nd[g]),
              .RST(!rstgen),
              .T(1'b0));

         IODELAY
           #(.REFCLK_FREQUENCY(200.0),
             .ODELAY_VALUE(25),
             .DELAY_SRC("O"),
             .IDELAY_TYPE("FIXED"),
             .SIGNAL_PATTERN("DATA"))               
         odelay2
             (.C(clk200),
              .DATAOUT(DA2[g]),
              .CE(1'b1),
              .DATAIN(1'b0),
              .IDATAIN(1'b0),
              .INC(1'b0),
              .ODATAIN(da2_nd[g]),
              .RST(!rstgen),
              .T(1'b0));
      end
   endgenerate

endmodule
