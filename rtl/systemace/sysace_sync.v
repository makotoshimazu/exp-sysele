
module sysace_sync
  (
   input             CLK80,
   input             CLK33,
   input             RST,
   
   output reg [27:0] sysace_mpulba_33,
   output reg [7:0]  sysace_nsectors_33,
   output reg        sysace_start_33,
   input             sysace_busy_33,

   input [15:0]      sysace_read_data_33,
   input             sysace_read_avail_33,

   output [15:0]     fifo_dout_80,
   output            fifo_full_33,
   output            fifo_empty_80,
   input             rd_en_80,

   input [27:0]      sysace_mpulba_80,
   input [7:0]       sysace_nsectors_80,

   input             sysace_start_80,
   output            sysace_busy_80
   );

   reg               sysace_start_r_80;
   reg               sysace_start_80_33;
   reg               sysace_busy_33_80;

   reg               sysace_start_ack_33;
   reg               sysace_start_ack_33_80;

   reg [27:0]        sysace_mpulba_r_80;
   reg [7:0]         sysace_nsectors_r_80;

   reg [2:0]         busy_buffer;

`define W 4
   reg [`W-1:0]      ssstate;

   parameter ss_idle       = `W'b0001;
   parameter ss_wait_busy  = `W'b0010;
   parameter ss_busy       = `W'b0100;
`undef W

   assign sysace_busy_80 = ssstate != ss_idle;
   
   async_fifo fifo
     (.rst(!RST),
      .wr_clk(CLK33),
      .rd_clk(CLK80),
      .din(sysace_read_data_33),
      .wr_en(sysace_read_avail_33),
      .rd_en(rd_en_80),
      .dout(fifo_dout_80),
      .full(fifo_full_33),
      .empty(fifo_empty_80));

   always @(posedge CLK80 or negedge RST)
     begin
        if (!RST)
          ssstate <= ss_idle;
        else
          case (ssstate)
            ss_idle:
              if (sysace_start_80)
                ssstate <= ss_wait_busy;
            ss_wait_busy:
              if (& busy_buffer)
                ssstate <= ss_busy;
            ss_busy:
              if (~| busy_buffer)
                ssstate <= ss_idle;
          endcase // case (ssstate)
     end // always @ (posedge CLK80 or negedge RST)

   // ==================================================
   // synchronization : sysace_start
   // ==================================================
   // Capture start in CLK80 region
   always @(posedge CLK80 or negedge RST)
     begin
        if (!RST)
          sysace_start_r_80 <= 1'b0;
        else 
          case (ssstate)
            ss_idle:
              if (sysace_start_80)
                sysace_start_r_80 <= 1'b1;
              else
                sysace_start_r_80 <= 1'b0;
            
            default:
              // Confirmed ACK.
              if (sysace_start_ack_33_80)
                sysace_start_r_80 <= 1'b0;
          endcase // case (ssstate)
     end

   // SYNC: 80 -> 33
   always @(posedge CLK33 or negedge RST)
     begin
        if (!RST)
          sysace_start_80_33 <= 1'b0;
        else 
          sysace_start_80_33 <= sysace_start_r_80;
     end

   // SYNC:ACK: 33 -> 80
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

   // Re-SYNC the ACK
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
          sysace_start_33 <= 1'b0;
        else
          sysace_start_33 <= sysace_start_80_33;
     end

   // ==================================================
   // Synchronization : sysace_busy
   // ==================================================
   always @(posedge CLK80 or negedge RST)
     begin
        if (!RST)
          sysace_busy_33_80 <= 1'b0;
        else
          sysace_busy_33_80 <= sysace_busy_33;
     end

   always @(posedge CLK80 or negedge RST)
     begin
        if (!RST)
          busy_buffer <= 3'b000;
        else
          busy_buffer <= {busy_buffer[1:0], sysace_busy_33_80};
     end

   // ==================================================
   // Synchronization : parameters
   // ==================================================
   always @(posedge CLK80 or negedge RST)
     begin
        if (!RST) begin
           sysace_mpulba_r_80 <= 28'h0;
           sysace_nsectors_r_80 <= 8'h0;
        end else 
          case (ssstate)
            ss_idle: begin
               sysace_mpulba_r_80 <= sysace_mpulba_80;
               sysace_nsectors_r_80 <= sysace_nsectors_80;
            end
          endcase
     end // always @ (posedge CLK80 or negedge RST)

   always @(posedge CLK33 or negedge RST)
     begin
        if (!RST) begin
           sysace_mpulba_33 <= 28'h0;
           sysace_nsectors_33 <= 8'h0;
        end else begin
           sysace_mpulba_33 <= sysace_mpulba_r_80;
           sysace_nsectors_33 <= sysace_nsectors_r_80;
        end
     end

endmodule // sysace_sync
