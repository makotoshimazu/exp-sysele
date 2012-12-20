
module picload
  (
   input             CLK,
   input             RST,

   output reg [27:0] mpulba,
   output [7:0]      nsectors,
   output            sysace_start,
   input             sysace_busy,

   input [15:0]      fifo_data,
   input             fifo_empty,
   output            rd_en,

   output [21:1]     data_w_address,
   output [31:0]     data_w,
   input             data_w_full,
   output            data_w_we,

   input             start,
   output            busy
   );
   
   reg [8:0]     col;
   reg [7:0]     row;
   wire          incr_address;

   reg [23:0]    fifo_out_r;
   reg [7:0]     fifo_out_reserved;

   reg [1:0]     counter;
   
`define W 4
   reg [`W-1:0]  state;
   parameter ssb_init    = `W'b0001;
   parameter ssb_idle    = `W'b0010;
   parameter ssb_read    = `W'b0100;
   parameter ssb_restart = `W'b1000;
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

   assign nsectors = 8'h0;
//   assign sysace_start = start;
   
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

   assign sysace_start
     = (state == ssb_idle && start)
       || state == ssb_restart;

   // ==================================================
   // State Machine
   // ==================================================
   always @(posedge CLK or negedge RST)
     begin
        if (!RST)
          state <= ssb_init;
        else
          case (state)
            ssb_init:
              if (col == 9'h1ff && row == 8'hff && !data_w_full)
                state <= ssb_idle;

            ssb_idle:
              if (start)
                state <= ssb_read;

            ssb_read:
              if (!sysace_busy) begin
                 if (counter == 2'd2)
                   state <= ssb_idle;
                 else
                   state <= ssb_restart;
              end
              // if (!)
              //   state <= ssb_idle;

            ssb_restart:
              state <= ssb_read;
            
            default:
              ;
          endcase
     end // always @ (posedge CLK or negedge RST)

   always @(posedge CLK or negedge RST)
     begin
        if (!RST)
          mpulba <= 28'h00;
        else
          case (state)
            ssb_idle:
              if (start)
                mpulba <= mpulba + 28'd256;
            ssb_restart:
              mpulba <= mpulba + 28'd256;
          endcase
     end

   always @(posedge CLK or negedge RST)
     begin
        if (!RST)
          counter <= 2'd0;
        else
          case (state)
            ssb_restart:
              counter <= counter + 2'd1;
            ssb_idle:
              counter <= 2'd0;
          endcase // case (state)
     end

   // ==================================================
   // Read states
   // ==================================================
   always @(posedge CLK or negedge RST)
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
              endcase // case (readstate)
            ssb_restart:
              ;
            default:
              readstate <= byte1_wait;
          endcase // case (state)
     end // always @ (posedge CLK or negedge RST)

   // ==================================================
   // Write address control
   // ==================================================
   always @(posedge CLK or negedge RST)
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
            ssb_restart:
              ;
            default:
              col <= 9'h0;
          endcase
     end // always @ (posedge CLK or negedge RST)

   always @(posedge CLK or negedge RST)
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
            ssb_restart:
              ;
            default:
              row <= 8'h0;
          endcase // case (state)
     end // always @ (posedge CLK or negedge RST)

   // ==================================================
   // FIFO output -> SRAM
   // ==================================================

   always @(posedge CLK or negedge RST)
     begin
        if (!RST) begin
           fifo_out_r <= 24'h0;
           fifo_out_reserved <= 8'h0;
        end else begin
           case (readstate)
             byte1: 
               fifo_out_r[23:8] <= {fifo_data[7:0], fifo_data[15:8]};
             byte2: 
               {fifo_out_r[7:0], fifo_out_reserved} <= {fifo_data[7:0], fifo_data[15:8]};
             byte3: 
               fifo_out_r <= {fifo_out_reserved, fifo_data[7:0], fifo_data[15:8]};
           endcase
        end
     end

endmodule