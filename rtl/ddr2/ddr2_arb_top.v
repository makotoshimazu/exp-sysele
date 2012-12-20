
module ddr2_arb_top
  (
   input          CLK,
   input          RST,

   // * IF 1
   // ** control
   input          req1,
   output         ack1,
   input [30:0]   addr1,
   input          read1,
   input          fin1, 

   // ** write
   input [255:0]  data1_i,
   input [31:0]   mask1,

   // ** read
   output         valid1,
   output [127:0] data1_o,
   
   // * IF 2
   // ** control
   input          req2,
   output         ack2,
   input [30:0]   addr2,
   input          read2,
   input          fin2, 

   // ** write
   input [255:0]  data2_i,
   input [31:0]   mask2,

   // ** read
   output         valid2,
   output [127:0] data2_o,

   // * IF 3
   // ** control
   input          req3,
   output         ack3,
   input [30:0]   addr3,
   input          read3,
   input          fin3,

   // ** write
   input [255:0]  data3_i,
   input [31:0]   mask3,

   // ** read
   output         valid3,
   output [127:0] data3_o,

   // * IF 4
   // ** control
   input          req4,
   output         ack4,
   input [30:0]   addr4,
   input          read4,
   input          fin4,

   // ** write
   input [255:0]  data4_i,
   input [31:0]   mask4,

   // ** read
   output         valid4,
   output [127:0] data4_o,

   // * IF 5
   // ** control
   input          req5,
   output         ack5,
   input [30:0]   addr5,
   input          read5,
   input          fin5,

   // ** write
   input [255:0]  data5_i,
   input [31:0]   mask5,

   // ** read
   output         valid5,
   output [127:0] data5_o,

   // DDR2 IF
   input          phy_init_done,
   
   output         app_af_wren,
   input          app_af_afull,
   output [30:0]  app_af_addr,
   output         app_af_read,

   output         app_wdf_wren,
   input          app_wdf_afull,
   output [127:0] app_wdf_data,
   output [15:0]  app_wdf_mask_data,

   input          rd_data_valid,
   input [127:0]  rd_data_fifo_out
   );

   // CONV
   wire         conv_req;
   wire         conv_ack;
   wire [30:0]  conv_addr;
   wire         conv_read;
   wire [255:0] conv_data_i;
   wire [31:0]  conv_mask;
   wire         conv_valid;
   wire [127:0] conv_data_o;

   /* 
    (progn 
      (forward-line 3)
      (insert "ddr2_arb ddr2_arb_inst\n") 
      (insert "(.CLK(CLK),\n.RST(RST),\n")
      (dotimes (i 5)
         (dolist (k '("req%d" "ack%d" "addr%d" "read%d" "data%d_i" "mask%d" "valid%d" "data%d_o" "fin%d"))
            (let ((j (+ i 1)))
                (insert "." (format k j) "(" (format k j) "),\n")))))
    */


   ddr2_arb ddr2_arb_inst
     (.CLK(CLK),
      .RST(RST),
      .req1(req1),
      .ack1(ack1),
      .addr1(addr1),
      .read1(read1),
      .data1_i(data1_i),
      .mask1(mask1),
      .valid1(valid1),
      .data1_o(data1_o),
      .fin1(fin1),
      .req2(req2),
      .ack2(ack2),
      .addr2(addr2),
      .read2(read2),
      .data2_i(data2_i),
      .mask2(mask2),
      .valid2(valid2),
      .data2_o(data2_o),
      .fin2(fin2),
      .req3(req3),
      .ack3(ack3),
      .addr3(addr3),
      .read3(read3),
      .data3_i(data3_i),
      .mask3(mask3),
      .valid3(valid3),
      .data3_o(data3_o),
      .fin3(fin3),
      .req4(req4),
      .ack4(ack4),
      .addr4(addr4),
      .read4(read4),
      .data4_i(data4_i),
      .mask4(mask4),
      .valid4(valid4),
      .data4_o(data4_o),
      .fin4(fin4),
      .req5(req5),
      .ack5(ack5),
      .addr5(addr5),
      .read5(read5),
      .data5_i(data5_i),
      .mask5(mask5),
      .valid5(valid5),
      .data5_o(data5_o),
      .fin5(fin5),
      
      .req(conv_req),
      .ack(conv_ack),
      .addr(conv_addr),
      .read(conv_read),
     
      .data_i(conv_data_i),
      .mask(conv_mask),

      .valid(conv_valid),
      .data_o(conv_data_o)
      );
   
   ddr2_convert ddr2_convert_inst
     (
      .CLK(CLK),
      .RST(RST),

      .req(conv_req),
      .ack(conv_ack),
      .addr(conv_addr),
      .read(conv_read),
      
      .data_i(conv_data_i),
      .mask(conv_mask),

      .valid(conv_valid),
      .data_o(conv_data_o),
      
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

endmodule // ddr2_arb_top
