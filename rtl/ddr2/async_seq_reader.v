
module async_seq_reader
  #(
    parameter address_step   = 30'd4,
    parameter address_bottom = 30'h0000_0000,
    parameter address_top    = 30'h0200_0000 - address_step
    )
  (
   input             ddr2_clk,
   input             rd_clk,
   input             RST,

   output            req,
   input             ack,
   output reg [30:0] addr,
   output            read,
   output            fin,

   output [255:0]    data_write,
   output [31:0]     mask,

   input             valid,
   input [127:0]     data_read,

   input             rd_en,
   output [127:0]    dout,
   output            fifo_empty,
   output            fifo_almost_empty,
   input             start,
   input             bottom
   );

`define WS 2
   parameter s_idle    = `WS'd0;
   parameter s_reading = `WS'd1;
   parameter s_wait    = `WS'd2;
   
   reg [`WS-1:0]  state;
`undef WS
   
   // depth - 1 of async_fifo
   reg [9:0]      pending_count;
   wire [9:0]     wr_data_count;
   reg [10:0]     wr_data_pend;
   reg            stop;

   localparam wr_data_pend_top = 10'd1000; // just to avoid nasty bugs
 
   reg            ack_r;
   reg            valid_r;
   reg [127:0]    data_read_r;
   

   reg            start_l;
   reg            bottom_l;

   reg            start_;
   reg            start__;
   reg            bottom_;
   reg            bottom__;
   reg            next_ack_is_the_last;
   
   assign read = 1'b1;
   assign data_write = 256'h0;
   assign mask = 32'h0;

   assign req = state == s_reading;
   assign fin = req & (stop || next_ack_is_the_last);

//   assign wr_data_pend = pending_count + wr_data_count;

   (* MAX_FANOUT = "10" *)
   async_fifo_ddr2 async_fifo_ddr2_inst
     (.rst(!RST),
      .wr_clk(ddr2_clk),
      .rd_clk(rd_clk),
      .din(data_read_r),
      .wr_en(valid_r),

      .rd_en(rd_en),
      .dout(dout),
      .full(),
      .empty(fifo_empty),
      .almost_empty(fifo_almost_empty),
      .wr_data_count(wr_data_count));

   always @(posedge ddr2_clk or negedge RST)
     if (!RST) begin
        state <= s_idle;
     end else begin
        case (state)
          s_idle:
            if (start__)
              state <= s_wait;

          s_wait:
            if (!stop)
              state <= s_reading;

          s_reading:
            if (next_ack_is_the_last && ack)
              state <= s_idle;
            else if (stop && ack)
              state <= s_wait;

          default: ;

        endcase
        // enforce bottom
        if (bottom__)
          state <= s_idle;

     end // else: !if(!RST)

   always @(posedge ddr2_clk or negedge RST)
     if (!RST) begin
        next_ack_is_the_last <= 1'b0;
     end else begin
        if ((addr == address_top - address_step && ack) || addr == address_top)
          next_ack_is_the_last <= 1'b1;
        else
          next_ack_is_the_last <= 1'b0;
     end


   always @(posedge ddr2_clk or negedge RST)
     if (!RST) begin
        addr <= address_bottom;
     end else begin
        if (ack) begin
          if (next_ack_is_the_last)
            addr <= address_bottom;
          else
            addr <= addr + address_step;
        end

        if (bottom__)
          addr <= address_bottom;
     end // else: !if(!RST)

   always @(posedge ddr2_clk or negedge RST)
     if (!RST) begin
        pending_count <= 10'h0;
     end else begin
        if (ack_r && valid_r)
          pending_count <= pending_count + 10'd1;
        else if (ack_r)
          pending_count <= pending_count + 10'd2;
        else if (valid_r)
          pending_count <= pending_count - 10'd1;
     end

   always @(posedge ddr2_clk or negedge RST)
     if (!RST) begin
        stop <= 1'b0;
     end else begin
        if (state == s_reading && wr_data_pend > wr_data_pend_top)
          stop <= 1'b1;
        else if (wr_data_pend <= wr_data_pend_top)
          stop <= 1'b0;
     end

   always @(posedge ddr2_clk or negedge RST)
     if (!RST) begin
        wr_data_pend <= 10'd0;
     end else begin
        wr_data_pend <= pending_count + wr_data_count;
     end

   always @(posedge ddr2_clk or negedge RST)
     if (!RST) begin
        start_ <= 1'b0;
        start__ <= 1'b0;
        bottom_ <= 1'b0;
        bottom__ <= 1'b0;
     end else begin
        start__ <= start_;
        start_ <= start_l;
        bottom__ <= bottom_;
        bottom_ <= bottom_l;
     end

   always @(posedge rd_clk or negedge RST)
     if (!RST) begin
        start_l <= 1'b0;
        bottom_l <= 1'b0;
     end else begin
        start_l <= start;
        bottom_l <= bottom;
     end

   always @(posedge ddr2_clk or negedge RST)
     if (!RST) begin
        valid_r <= 1'b0;
     end else begin
        valid_r <= valid;
     end

   always @(posedge ddr2_clk)
     data_read_r <= data_read;

   always @(posedge ddr2_clk or negedge RST)
     if (!RST) begin
        ack_r <= 1'b0;
     end else begin
        ack_r <= ack;
     end


endmodule
