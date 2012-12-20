
module ddr2_convert 
  (
   input              CLK,
   input              RST,

   // * control
   input              req,
   output             ack,
   input [30:0]       addr,
   input              read,

   // * write
   input [255:0]      data_i,
   input [31:0]       mask,

   // * read
   output             valid,
   output [127:0]     data_o,

   // DDR2 IF
   input              phy_init_done,
   
   output reg         app_af_wren,
   input              app_af_afull,
   output reg [30:0]  app_af_addr,
   output reg         app_af_read,

   output reg         app_wdf_wren,
   input              app_wdf_afull,
   output reg [127:0] app_wdf_data,
   output reg [15:0]  app_wdf_mask_data,

   input              rd_data_valid,
   input [127:0]      rd_data_fifo_out
   );

`define SW 4
   localparam s_idle  = `SW'd1;
   localparam s_word1 = `SW'd2;
   localparam s_word2 = `SW'd4;
   localparam s_wait_init = `SW'd8;
   
   (* MAX_FANOUT = "10" *)
   (* SIGNAL_ENCODING = "user" *)
   reg [`SW-1:0] state;
`undef SW
   
   reg [127:0]               next_word;
   reg [15:0]                next_mask;

   // assign ack = state == s_word1 && req;
   assign ack = state[1] && req;

   assign valid = rd_data_valid;
   assign data_o = rd_data_fifo_out;

   // assign app_af_wren
   //   = ack;

   always @(posedge CLK or negedge RST)
     if (!RST) begin
        app_af_wren <= 1'b0;
     end else begin
        app_af_wren <= ack;
     end

   // assign app_af_addr
   //   = addr;

   always @(posedge CLK)
     app_af_addr <= addr;

   // assign app_af_read
   //   = read;

   always @(posedge CLK)
     app_af_read <= read;

//    assign app_wdf_wren
//      = (state[1] || state[2]) && !read;
// //     = (state == s_word1 || state == s_word2) && !read;

   always @(posedge CLK or negedge RST)
     if (!RST) begin
        app_wdf_wren <= 1'b0;
     end else begin
        app_wdf_wren <= (state[1] || state[2]) && !read;
     end
   
//    assign app_wdf_data
// //     = state == s_word1 ? data_i[255:128] :
//      = state[1] ? data_i[255:128] :
//        next_word;

   always @(posedge CLK)
     app_wdf_data <= state[1] ? 
                     data_i[255:128] : 
                     next_word;

//    assign app_wdf_mask_data
// //     = state == s_word1 ? mask[31:16] :
//      = state[1] ? mask[31:16] :
//        next_mask;

   always @(posedge CLK)
     app_wdf_mask_data <= state[1] ?
                          mask[31:16] :
                          next_mask;

   always @(posedge CLK or negedge RST)
     if (!RST) begin
        state <= s_wait_init;
     end else begin
        case (state)
          s_wait_init:
            if (phy_init_done)
              state <= s_idle;

          s_idle:
            if (req && !app_af_afull && !app_wdf_afull)
              state <= s_word1;
          
          s_word1: 
            if (!read)
              state <= s_word2;
            else if (!req)
              state <= s_idle;

          s_word2:
            if (!req)
              state <= s_idle;
            else 
              state <= s_word1;

          default: ;
        endcase
     end

   always @(posedge CLK or negedge RST)
     if (!RST) begin
        next_word <= 128'h0;
     end else begin
        next_word <= data_i[127:0];
     end // else: !if(!RST)

   always @(posedge CLK or negedge RST)
     if (!RST) begin
        next_mask <= 16'h0;
     end else begin
        next_mask <= mask[15:0];
     end

   
endmodule
