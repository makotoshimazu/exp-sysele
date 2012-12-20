
module sysace_top
  #(parameter mpulba_top = 28'd65536 - 28'd256)
  (
   input              CLK,
   input              RST,

   output reg [27:0]  mpulba,
   output [7:0]       nsectors,

   output             sysace_start,
   input              sysace_busy,

   input [15:0]       sysace_read_data,
   input              sysace_read_avail,

   output reg         wr_en,
   output reg [127:0] dout,
   input              fifo_full,

   input              start,
   output             busy
   );

`define SW 2
   localparam s_idle = `SW'd0;
   localparam s_start = `SW'd1;
   localparam s_wait = `SW'd2;
   localparam s_incr = `SW'd3;
   reg [`SW-1:0]     state;
   
`undef SW

   localparam counter_top = 3'd7;
   reg [2:0]         counter;

   wire [15:0]       read_data;
   assign read_data[7:0] = sysace_read_data[15:8];
   assign read_data[15:8] = sysace_read_data[7:0];

   assign nsectors = 8'h0;
   assign sysace_start = state == s_start;
   assign busy = state != s_idle;

   always @(posedge CLK or negedge RST)
     if (!RST) begin
        state <= s_idle;
     end else begin
        case (state)
          s_idle:
            if (start)
              state <= s_start;

          s_start:
            state <= s_wait;

          s_wait:
            if (!sysace_busy) begin
               if (mpulba == mpulba_top)
                 state <= s_idle;
               else
                 state <= s_incr;
            end

          s_incr:
            state <= s_start;

          default: ;
        endcase
     end


   always @(posedge CLK or negedge RST)
     if (!RST) begin
        mpulba <= 28'd0;
     end else begin
        case (state)
          s_incr:
            if (mpulba == mpulba_top)
              mpulba <= 28'd0;
            else
              mpulba <= mpulba + 28'd256;

          default: ;
        endcase
     end

   always @(posedge CLK) begin
      if (sysace_read_avail)
        dout <= {dout[111:0], read_data};
   end

   always @(posedge CLK or negedge RST)
     if (!RST) begin
        counter <= 3'd0;
     end else begin
        if (sysace_read_avail)
          counter <= counter + 3'd1;
     end

   always @(posedge CLK or negedge RST)
     if (!RST) begin
        wr_en <= 1'b0;
     end else begin
        if (counter == counter_top && sysace_read_avail)
          wr_en <= 1'b1;
        else
          wr_en <= 1'b0;
     end

endmodule
