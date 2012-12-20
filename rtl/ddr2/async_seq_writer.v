
module async_seq_writer
  #(parameter word_count_top = 2'd3,
    parameter read_count_top = 3'd7,
    parameter address_step   = 30'd4,
    parameter address_bottom = 30'h0000_0000,
    parameter address_top    = 30'h0200_0000 - address_step
    )
   (
    input              ddr2_clk,
    input              wr_clk,
    input              RST,

    output reg         req,
    input              ack,
    output reg [30:0]  addr,
    output             read,
    output             fin,

    output reg [255:0] data_write,
    output [31:0]      mask,

    input              valid, // unused
    input [127:0]      data_read, // unused

    input              wr_en,
    input [127:0]      din,
    output             fifo_full
    );

   wire            fifo_empty;
   wire            fifo_almost_empty;
   wire [255:0]    data_write_w;
   reg             rd_en;
   reg             req_1;
   reg             written;

   // assign req = !fifo_almost_empty ||
   //              (!fifo_empty & !written);
   assign read = 1'b0;
   assign mask = 31'h0;
   assign fin  = req & fifo_empty;

   always @(posedge ddr2_clk or negedge RST)
     if (!RST) begin
        rd_en <= 1'b0;
     end else begin
        rd_en <= !fifo_empty && (ack || written);
     end

   always @(posedge ddr2_clk or negedge RST)
     if (!RST) begin
        written <= 1'b1;
     end else begin
        if (ack && fifo_empty)
          written <= 1'b1;
        else if (!fifo_empty)
          written <= 1'b0;
     end

   (* MAX_FANOUT = "10" *)
   async_fifo_ddr2_x2 async_fifo_ddr2_x2_inst
     (.rst(!RST),
      .wr_clk(wr_clk),
      .rd_clk(ddr2_clk),
      .din(din),
      .wr_en(wr_en),

      .rd_en(rd_en),
      .dout(data_write_w),
      .full(fifo_full),
      .empty(fifo_empty),
      .almost_empty(fifo_almost_empty)
      );

   always @(posedge ddr2_clk or negedge RST)
     if (!RST) begin
        addr <= address_bottom;
     end else begin
        if (ack) begin
           if (addr == address_top)
             addr <= address_bottom;
           else
             addr <= addr + address_step;
        end
     end

   always @(posedge ddr2_clk or negedge RST)
     if (!RST) begin
        req <= 1'b0;
     end else begin
        if (ack && fifo_empty)
          req <= 1'b0;
        else if (!fifo_empty)
          req <= 1'b1;
     end

   always @(posedge ddr2_clk)
     if (written || ack)
       data_write <= data_write_w;

endmodule
