
module comm
  #(
    // modtype
    // 0 -> raw
    // 1 -> BPSK
    parameter modtype = 1,
    parameter valid_delay_min = 24
    )
   (
    input          CLK,
    input          RST,

    input [7:0]    ad1,
    input [7:0]    ad2,

    output [5:0]   da1,
    output [5:0]   da2,

    output         rd_en,
    input [127:0]  din,
    input          empty,

    output [127:0] dout,
    output         wr_en,
    input          full,

    input [3:0]    ad1_delay,
    input [3:0]    ad2_delay,
    input [3:0]    ad_valid_delay,

    output [7:0]   raw_send_d,
    output [7:0]   raw_recv,
    output         valid_raw
    );

   wire           valid_raw_send;
   wire           valid_raw_recv;
   wire [7:0]     raw_send;

   assign valid_raw = valid_raw_recv;

   // **************************************************
   // DELAY
   //   8*2             8*2
   // ---/--- [DELAY] ---/---> comm_recv
   // **************************************************
   wire [7:0]     ad1_dl, ad2_dl;
   wire           da_valid;
   wire           ad_valid;

   variable_delay
     #(.width(1),
       .sel_width(4),
       .delay_min(valid_delay_min),
       .with_reset(1),
       .rstval(1'b0))
   ad_valid_delay_inst
     (.CLK(CLK),
      .RST(RST),
      .ce(1'b1),
      .din(da_valid),
      .sel(ad_valid_delay),
      .dout(ad_valid));

   fifo_raw_send fifo_raw_send
     (.clk(CLK),
      .rst(!RST),

      .din(raw_send),
      .wr_en(valid_raw_send),
      .full(),
      
      .rd_en(valid_raw_recv),
      .empty(),
      .dout(raw_send_d));
   
   variable_delay
     #(.width(8),
       .sel_width(4),
       .delay_min(1))
   ad1_delay_inst
     (.CLK(CLK),
      .RST(RST),

      .ce(1'b1),
      .din(ad1),
      .sel(ad1_delay),
      .dout(ad1_dl));

   variable_delay
     #(.width(8),
       .sel_width(4),
       .delay_min(1))
   ad2_delay_inst
     (.CLK(CLK),
      .RST(RST),

      .ce(1'b1),
      .din(ad2),
      .sel(ad2_delay),
      .dout(ad2_dl));


   // **************************************************
   // DDR >--- [MOD] ---> AD
   // DA  >--- [DEMOD] ---> DDR
   // **************************************************
   generate
      if (modtype == 0) begin
         // SENDER
         datop datop_inst
           (
            .CLK(CLK),
            .RST(RST),

            .rd_en(rd_en),
            .din(din),
            .empty(empty),
            .da1(da1),
            .da2(da2),
            .da_valid(da_valid));
         assign valid_raw_send = da_valid;
         assign raw_send = da1;

         // RECEIVER
         adtop adtop_inst
           (
            .CLK(CLK),
            .RST(RST),

            .din1(ad1_dl),
            .din2(ad2_dl),
            .valid(ad_valid),

            .dout(dout),
            .wr_en(wr_en),
            .full(full)
            );

         assign valid_raw_recv = ad_valid;
         assign raw_recv = ad1_dl;
         
      end else begin
         // **************************************************
         // SEND
         // **************************************************
         comm_send
           #(.modtype(modtype))
         comm_send_inst
           (
            .CLK(CLK),
            .RST(RST),
            
            .rd_en(rd_en),
            .din(din),
            .empty(empty),

            .da_valid(da_valid),
            .da1(da1),
            .da2(da2),

            .valid_raw(valid_raw_send),
            .raw(raw_send)       
            );
         
         // **************************************************
         // RECV
         // **************************************************
         comm_recv
           #(.modtype(modtype))
         comm_recv_inst
           (
            .CLK(CLK),
            .RST(RST),
            
            .wr_en(wr_en),
            .dout(dout),
            .full(full),

            .ad1(ad1_dl),
            .ad2(ad2_dl),
            .ad_valid(ad_valid),

            .valid_raw(valid_raw_recv),
            .raw(raw_recv)       
            );
      end
   endgenerate
   
endmodule
