
module spi_chunk 
  (input CLK,
   input            RST,

   inout            SDIO,
   output reg       SCLK,
   output reg       CSB,

   input [7:0]      data_i,
   input            read_i,
   input            start_i,
   output reg [7:0] data_o,
   output           busy_o,
   output           finish_o
   );

   reg [1:0]   state;
   parameter s_idle    = 2'b00;
   parameter s_waitcsb = 2'b01;
   parameter s_sending = 2'b10;

   reg [3:0]   bitcounter;
   
   wire        sdio_reg;
   wire        sdio_en;

   reg [7:0]   data;
   reg         read;

   assign SDIO = sdio_en ? sdio_reg : 1'bz;

   assign sdio_en = (!read && state == s_sending);
   assign sdio_reg = data[7];
   assign busy_o = state != s_idle || start_i;
   assign finish_o = state == s_sending && bitcounter == 4'h7 && SCLK;

   always @(posedge CLK or negedge RST)
     if (!RST) begin
        state <= s_idle;
     end else begin
        case (state)
          s_idle: 
            if (start_i)
              state <= s_waitcsb;

          s_waitcsb:
            state <= s_sending;

          s_sending:
            if (bitcounter == 4'd7 && SCLK)
              state <= s_idle;
          default: ;
        endcase
     end

   always @(posedge CLK or negedge RST)
     if (!RST) begin
        bitcounter <= 4'd0;
     end else begin
        case (state)
          s_sending:
             if (SCLK)
               bitcounter <= bitcounter + 4'd1;
          
          default:
            bitcounter <= 4'd0;
        endcase
     end

   always @(posedge CLK or negedge RST)
     if (!RST) begin
        SCLK <= 1'b0;
     end else begin
        case (state)
          s_idle:
            SCLK <= 1'b0;

          s_sending:
            SCLK <= ~SCLK;
        endcase
     end

   always @(posedge CLK or negedge RST)
     if (!RST) begin
        CSB <= 1'b1;
     end else begin
        case (state)
          s_idle:
             if (start_i)
               CSB <= 1'b0;
             else
               CSB <= 1'b1;

          default: ;
        endcase
     end

   always @(posedge CLK or negedge RST)
     if (!RST) begin
        data <= 8'h0;
     end else begin
        case (state)
          s_idle:
            if (start_i)
              data <= data_i;

          s_sending:
            if (SCLK)
              data <= {data[6:0], 1'b0};
        endcase
     end


   always @(posedge CLK or negedge RST)
     if (!RST) begin
        read <= 1'b0;
     end else begin
        if (start_i) begin
           read <= read_i;
        end
     end

   always @(posedge CLK or negedge RST)
     if (!RST) begin
        data_o <= 8'h0;
     end else begin
        case (state)
          s_sending: 
            if (!SCLK)
              data_o <= {data_o[6:0], SDIO};
          default: ;
        endcase
     end


endmodule
