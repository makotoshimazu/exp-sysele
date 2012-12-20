
module fftfifo
  (
   input                CLK,
   input                RST,

   input                wr_en,
   input [21:0]  din,
   output               full,

   output reg           valid_o,
   output [21:0] dout,
   input                rd_en
   );

   localparam counter_top = 6'd63;
   reg [5:0]            counter;

   wire                 rd_en_w;

   assign rd_en_w = rd_en & valid_o;

   fft_feed_fifo fifo_inst
     (.clk(CLK),
      .rst(!RST),

      .full(full),
      .din(din),
      .wr_en(wr_en),

      .dout(dout),
      .empty(empty),
      .prog_empty(prog_empty),
      .rd_en(rd_en_w));

   always @(posedge CLK or negedge RST)
     if (!RST) begin
        counter <= 11'd0;
     end else begin
        if (rd_en_w)
          counter <= counter + 6'd1;
     end

   always @(posedge CLK or negedge RST)
     if (!RST) begin
        valid_o <= 1'b0;
     end else begin
        if (!prog_empty)
          valid_o <= 1'b1;
        if (counter == counter_top && prog_empty)
          valid_o <= 1'b0;
     end

endmodule
