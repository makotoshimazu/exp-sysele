
module sysace_sram_bridge
  (
   input             CLK80,
   input             CLK33,
   input             RST,
   
   output reg [27:0] sysace_mpulba,
   output [7:0]      sysace_nsectors,
   output reg        sysace_start,
   input             sysace_busy,

   input [15:0]      sysace_read_data,
   input             sysace_read_avail,

   output [21:1]     data_w_address,
   output [31:0]     data_w,
   input             data_w_full,
   output            data_w_we, 

   input             start,
   output            busy
   );

   reg [8:0]     col;
   reg [7:0]     row;
   reg           again;
   wire          incr_address;
   reg [21:1]    data_w_address_r;

   wire [15:0]   fifo_dout;
   wire          fifo_full;
   wire          fifo_empty;
   wire          rd_en;

   reg [23:0]    fifo_out_r;
   reg [7:0]     fifo_out_reserved;

   reg           sysace_start_80;
   reg           sysace_start_80_33;
   reg           sysace_start_ack_33;
   reg           sysace_start_ack_33_80;

   reg           sysace_busy_80;

   reg [1:0]     readcounter;

`define W 3
   reg [`W-1:0]  state;
   parameter ssb_init = `W'b001;
   parameter ssb_idle = `W'b010;
   parameter ssb_read = `W'b100;
`undef W

`define W 8
   reg [`W-1:0]  readstate;

   parameter byte1_wait  = `W'b00000001;
   parameter byte1       = `W'b00000010;
   parameter byte2_wait  = `W'b00000100;
   parameter byte2       = `W'b00001000;
   parameter byte2_write = `W'b00010000;
   parameter byte3_wait  = `W'b00100000;
   parameter byte3       = `W'b01000000;
   parameter byte3_write = `W'b10000000;
`undef W

`define W 3
   reg [`W-1:0]  sysacestate80;

   parameter ss80_before_busy = `W'b001;
   parameter ss80_busy = `W'b001;
   parameter ss80_after_busy  = `W'b001;
`undef W
   
   assign sysace_nsectors = 8'h0; // 256
   // assign sysace_nsectors = 8'h1;

   async_fifo fifo
     (.rst(!RST),
      .wr_clk(CLK33),
      .rd_clk(CLK80),
      .din(sysace_read_data),
      .wr_en(sysace_read_avail),
      .rd_en(rd_en),
      .dout(fifo_dout),
      .full(fifo_full),
      .empty(fifo_empty));

   assign data_w_address 
     = {row, col};

   assign data_w
     = state == ssb_init ? {row, col[8:1], row}
       : fifo_out_r;

   assign busy = state != ssb_idle;

   assign data_w_we
     = state == ssb_init
       || state == ssb_read && (readstate == byte2_write
                                || readstate == byte3_write);

   assign incr_address
     = state == ssb_read
       && (readstate == byte2_write
           || readstate == byte3_write)
         && !data_w_full;

   assign rd_en
     = !fifo_empty
       && state == ssb_read
       && (readstate == byte1_wait
           || readstate == byte2_wait
           || readstate == byte3_wait);

   // ==================================================
   // State Machine
   // ==================================================
   always @(posedge CLK80 or negedge RST)
     begin
        if (!RST)
          state <= ssb_init;
        else
          case (state)
            ssb_init:
              if (col == 9'h1ff && row == 8'hff && !data_w_full)
                state <= ssb_idle;

            ssb_idle:
              if (sysace_start_ack_33_80)
                state <= ssb_read;

            ssb_read:
              ;
              // if (!)
              //   state <= ssb_idle;
            
            default:
              ;
          endcase
     end // always @ (posedge CLK80 or negedge RST)

   // ==================================================
   // Read states
   // ==================================================
   always @(posedge CLK80 or negedge RST)
     begin
        if (!RST)
          readstate <= byte1_wait;
        else
          case (state)
            ssb_read:
              case (readstate)
                byte1_wait:
                  if (rd_en)
                    readstate <= byte1;
                byte1:
                  readstate <= byte2_wait;
                byte2_wait:
                  if (rd_en)
                    readstate <= byte2;
                byte2:
                  readstate <= byte2_write;
                byte2_write:
                  if (!data_w_full)
                    readstate <= byte3_wait;
                byte3_wait:
                  if (rd_en)
                    readstate <= byte3;
                byte3:
                  readstate <= byte3_write;
                byte3_write:
                  if (!data_w_full)
                    readstate <= byte1_wait;
              endcase
            default:
              readstate <= byte1_wait;
          endcase // case (state)
     end // always @ (posedge CLK80 or negedge RST)

   // ==================================================
   // Sysace state reader
   // ==================================================
   always @(posedge CLK80 or negedge RST)
     begin
        if (!RST)
          sysacestate80 <= ss80_before_busy;
        else begin
           case (state)
             ssb_read:
               case (sysacestate80)
                 ss80_before_busy:
                   if (sysace_busy_80)
                     sysacestate80 <= ss80_busy;
                 ss80_busy:
                   if (!sysace_busy_80)
                     sysacestate80 <= ss80_after_busy;

                 ss80_after_busy:
                   sysacestate80 <= ss80_before_busy;
               endcase // case (sysacestate80)
             default:
               sysacestate80 <= ss80_before_busy;
           endcase // case (state)
        end
     end // always @ (posedge CLK or negedge RST)

   always @(posedge CLK80 or negedge RST)
     begin
        if (!RST)
          readcounter <= 2'd0;
        else begin
           case (state)
             ssb_read:
               if (sysacestate80 == ss80_after_busy)
                 readcounter <= readcounter + 2'd1;

             default:
               readcounter <= 2'd0;
           endcase
        end
     end
   
   // ==================================================
   // Write address control
   // ==================================================
   always @(posedge CLK80 or negedge RST)
     begin
        if (!RST)
          col <= 9'h0;
        else
          case (state)
            ssb_init:
              if (!data_w_full)
                 col <= col + 9'h1;
            ssb_read:
              if (incr_address) begin
                 if (col == 9'h1ff)
                   col <= 9'h000;
                 else
                   col <= col + 9'h1;
              end
            default:
              col <= 9'h0;
          endcase
     end // always @ (posedge CLK80 or negedge RST)

   always @(posedge CLK80 or negedge RST)
     begin
        if (!RST)
          row <= 8'h0;
        else
          case (state)
            ssb_init:
              if (!data_w_full && col == 9'h1ff)
                row <= row + 8'h1;
            ssb_read:
              if (incr_address && col == 9'h1ff) begin
                 if (row == 8'hff)
                   row <= 8'h00;
                 else
                   row <= row + 8'h1;
              end
            default:
              row <= 8'h0;
          endcase // case (state)
     end // always @ (posedge CLK80 or negedge RST)

   // ==================================================
   // FIFO output -> SRAM
   // ==================================================

   always @(posedge CLK80 or negedge RST)
     begin
        if (!RST) begin
           fifo_out_r <= 24'h0;
           fifo_out_reserved <= 8'h0;
        end else begin
           case (readstate)
             byte1: 
               fifo_out_r[23:8] <= {fifo_dout[7:0], fifo_dout[15:8]};
             byte2: 
               {fifo_out_r[7:0], fifo_out_reserved} <= {fifo_dout[7:0], fifo_dout[15:8]};
             byte3: 
               fifo_out_r <= {fifo_out_reserved, fifo_dout[7:0], fifo_dout[15:8]};
           endcase
        end
     end

   // Failure
   always @(posedge CLK80 or negedge RST)
     begin
        if (!RST)
          again <= 1'b0;
        else begin
           if (data_w_we && data_w_full) // Tried to write, but failed
             again <= 1'b1;
           else
             again <= 1'b0;
        end              
     end

   // ==================================================
   // Synchronization : sysace_start
   // ==================================================
   always @(posedge CLK80 or negedge RST)
     begin
        if (!RST)
          sysace_start_80 <= 1'b0;
        else begin
           if ((state == ssb_init && start)
               || (state == ssb_read && sysacestate80 == ss80_after_busy && readcounter != 2'd2))
             sysace_start_80 <= 1'b1;
           else if (sysace_start_ack_33_80)
             sysace_start_80 <= 1'b0;
        end          
     end // always @ (posedge CLK80 or negedge RST)

   always @(posedge CLK33 or negedge RST)
     begin
        if (!RST)
          sysace_start_80_33 <= 1'b0;
        else 
          sysace_start_80_33 <= sysace_start_80;
     end

   always @(posedge CLK33 or negedge RST)
     begin
        if (!RST)
          sysace_start_ack_33 <= 1'b0;
        else begin
          if (sysace_start_80_33)
            sysace_start_ack_33 <= 1'b1;
          else
            sysace_start_ack_33 <= 1'b0;
        end
     end // always @ (posedge CLK33 or negedge RST)

   always @(posedge CLK80 or negedge RST)
     begin
        if (!RST)
          sysace_start_ack_33_80 <= 1'b0;
        else
          sysace_start_ack_33_80 <= sysace_start_ack_33;
     end

   always @(posedge CLK33 or negedge RST)
     begin
        if (!RST)
          sysace_start <= 1'b0;
        else
          sysace_start <= sysace_start_80_33;
     end

   always @(posedge CLK33 or negedge RST)
     begin
        if (!RST)
          sysace_mpulba <= 28'h0;
        else begin
           if (sysace_start)
             sysace_mpulba <= sysace_mpulba + 28'd256;
        end
     end
   always @(posedge CLK80 or negedge RST)
     begin
        if (!RST)
          sysace_busy_80 <= 1'b0;
        else
          sysace_busy_80 <= sysace_busy;
     end
endmodule // sysace_sram_bridge
