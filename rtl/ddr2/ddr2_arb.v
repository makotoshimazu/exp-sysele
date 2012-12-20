
module ddr2_arb
  #(
    parameter word_count_top = 3'd7
    )
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

   // * CONVERT 
   // ** control
   output reg     req,
   input          ack,
   output [30:0]  addr,
   output         read,
   
   output [255:0] data_i,
   output [31:0]  mask,

   input          valid,
   input [127:0]  data_o
   );

   reg [4:0]      en;
   wire           req_w;
   wire [4:0]     reqs = {req5, req4, req3, req2, req1};
   wire [24:0]    out;
   wire [4:0]     targ_w;
   wire [2:0]     targ_bin_w;
   reg [4:0]      targ;
   reg [2:0]      targ_bin;
   wire [4:0]     read_targ;
   reg [4:0]      d_targ;
   wire           write_fifo;
   reg            d_write_fifo;
   reg            even;

   wire           fin;
   
   wire           next;
   wire           update_targ;
   
   localparam ack_counter_top = 3'd7;
   reg [2:0] ack_counter;

   // assign req
   //   = | (targ & reqs);
   assign req_w
     = targ_bin == 3'd1 ? req1 :
       targ_bin == 3'd2 ? req2 :
       targ_bin == 3'd3 ? req3 :
       targ_bin == 3'd4 ? req4 :
       targ_bin == 3'd5 ? req5 :
       1'b0;

   assign fin
     = targ_bin == 3'd1 ? fin1 :
       targ_bin == 3'd2 ? fin2 :
       targ_bin == 3'd3 ? fin3 :
       targ_bin == 3'd4 ? fin4 :
       targ_bin == 3'd5 ? fin5 :
       1'b0;

   assign {ack5, ack4, ack3, ack2, ack1}
     = {5{ack}} & targ;

   // assign addr
   //   = (addr1 & {31{targ[0]}}) |
   //     (addr2 & {31{targ[1]}}) |
   //     (addr3 & {31{targ[2]}}) |
   //     (addr4 & {31{targ[3]}}) |
   //     (addr5 & {31{targ[4]}});
   assign addr
     = targ_bin == 3'd1 ? addr1 :
       targ_bin == 3'd2 ? addr2 :
       targ_bin == 3'd3 ? addr3 :
       targ_bin == 3'd4 ? addr4 :
       targ_bin == 3'd5 ? addr5 :
       31'hx;

   // assign read
   //   = | (targ & {read5, read4, read3, read2, read1});
   assign read
     = targ_bin == 3'd1 ? read1 :
       targ_bin == 3'd2 ? read2 :
       targ_bin == 3'd3 ? read3 :
       targ_bin == 3'd4 ? read4 :
       targ_bin == 3'd5 ? read5 :
       1'bx;

   // assign data_i
   //   = (data1_i & {256{targ[0]}}) |
   //     (data2_i & {256{targ[1]}}) |
   //     (data3_i & {256{targ[2]}}) |
   //     (data4_i & {256{targ[3]}}) |
   //     (data5_i & {256{targ[4]}});
   assign data_i
     = targ_bin == 3'd1 ? data1_i :
       targ_bin == 3'd2 ? data2_i :
       targ_bin == 3'd3 ? data3_i :
       targ_bin == 3'd4 ? data4_i :
       targ_bin == 3'd5 ? data5_i :
       31'hx;
   
   // assign mask
   //   = (mask1 & {32{targ[0]}}) |
   //     (mask2 & {32{targ[1]}}) |
   //     (mask3 & {32{targ[2]}}) |
   //     (mask4 & {32{targ[3]}}) |
   //     (mask5 & {32{targ[4]}});
   assign mask
     = targ_bin == 3'd1 ? mask1 :
       targ_bin == 3'd2 ? mask2 :
       targ_bin == 3'd3 ? mask3 :
       targ_bin == 3'd4 ? mask4 :
       targ_bin == 3'd5 ? mask5 :
       32'dx;

   assign data1_o = data_o;
   assign data2_o = data_o;
   assign data3_o = data_o;
   assign data4_o = data_o;
   assign data5_o = data_o;

   assign valid1 = read_targ[0] & valid;
   assign valid2 = read_targ[1] & valid;
   assign valid3 = read_targ[2] & valid;
   assign valid4 = read_targ[3] & valid;
   assign valid5 = read_targ[4] & valid;

   assign read_fifo = valid & even;
   assign write_fifo = ack && read;

   fifo_targ fifo_targ_inst
     (.clk(CLK),
      .rst(!RST),

      .wr_en(d_write_fifo),
      .rd_en(read_fifo),

      .din(d_targ),
      .dout(read_targ),
      .empty(),
      .full(),
      .prog_full());

   assign targ_bin_w
     = targ_w == 5'b00001 ? 3'd1 :
       targ_w == 5'b00010 ? 3'd2 :
       targ_w == 5'b00100 ? 3'd3 :
       targ_w == 5'b01000 ? 3'd4 :
       targ_w == 5'b10000 ? 3'd5 :
       3'd0;
   
   genvar         v;
   generate
      for (v=0; v<5; v=v+1) begin : GEN_PRIENC
         prienc prienc0
             (.in0(reqs[v]),
              .in1(reqs[(v+1)%5]),
              .in2(reqs[(v+2)%5]),
              .in3(reqs[(v+3)%5]),
              .in4(reqs[(v+4)%5]),
              .en(en[v]),
              .out0(out[5*v + v]),
              .out1(out[5*v + (v+1)%5]),
              .out2(out[5*v + (v+2)%5]),
              .out3(out[5*v + (v+3)%5]),
              .out4(out[5*v + (v+4)%5]));
      end
   endgenerate

   genvar g;
   generate
      for (g=0; g<5; g=g+1) begin : GEN_TARG_W
         assign targ_w[g] = out[5*g + g] | out[5*g + (g+1)%5] | out[5*g + (g+2)%5] | out[5*g + (g+3)%5] | out[5*g + (g+4)%5];
      end
   endgenerate

   assign next = update_targ;
   always @(posedge CLK or negedge RST)
     if (!RST) begin
        en <= 5'b00001;
     end else begin
        if (next)
          en <= {en[3:0], en[4]};
     end

   assign update_targ = (ack_counter == ack_counter_top || !req) && !req_w;
   always @(posedge CLK or negedge RST)
     if (!RST) begin
        targ <= 5'b00000;
        targ_bin <= 3'd0;
     end else begin
        if (update_targ) begin
           targ <= targ_w;
           targ_bin <= targ_bin_w;
        end
     end

   always @(posedge CLK or negedge RST)
     if (!RST) begin
        ack_counter <= 3'd0;
     end else begin
        if (ack)
          ack_counter <= ack_counter + 3'd1;
        else if (update_targ)
          ack_counter <= 3'd0;
     end

   always @(posedge CLK or negedge RST)
     if (!RST) begin
        d_write_fifo <= 1'b0;
     end else begin
        d_write_fifo <= write_fifo;
     end

   always @(posedge CLK or negedge RST)
     if (!RST) begin
        d_targ <= 5'b00000;
     end else begin
        d_targ <= targ;
     end

   always @(posedge CLK or negedge RST)
     if (!RST) begin
        even <= 1'b0;
     end else begin
        if (valid)
          even <= ~even;
     end

   always @(posedge CLK or negedge RST)
     if (!RST) begin
        req <= 1'b0;
     end else begin
        if (fin && ack)
          req <= 1'b0;
        else
          req <= req_w;
     end

   
endmodule
