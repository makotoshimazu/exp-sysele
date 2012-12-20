
module lcd_comm 
  #(
    parameter clk_mhz = 240,
    parameter clk_mhz_width = 8,

    parameter divider_width = clk_mhz_width + 4,
    parameter divider_top = clk_mhz * 10 - 1
    )
  (
   input            CLK,
   input            RST,

   input            start,
   input [7:0]      data_w,
   output reg [7:0] data_r,
   input            write,
   input            system,

   output           busy,

   output reg       rs,
   output reg       rw,
   output reg       e,
   inout [3:0]      LCD_DATA
   );
   
`define SW 5
   parameter s_idle         = `SW'd0;
   parameter s_wait_15      = `SW'd1;
   parameter s_set_8bit_1   = `SW'd2;
   parameter s_wait_4_1     = `SW'd3;
   parameter s_set_8bit_2   = `SW'd4;
   parameter s_wait_0_1     = `SW'd5;
   parameter s_set_8bit_3   = `SW'd6;
   parameter s_set_4bit     = `SW'd7;
   parameter s_wait_fire    = `SW'd8;
   parameter s_byte_1       = `SW'd9;
   parameter s_byte_2       = `SW'd10;
   parameter s_wait_busy_1  = `SW'd11;
   parameter s_wait_busy_2  = `SW'd12;
   parameter s_wait_0_1_2   = `SW'd13;
   reg [`SW-1:0]        state;
`undef SW
   
   reg [divider_width-1:0] divider;         
   reg [10:0]              counter;
   reg                     fire;

   reg [7:0]               data_w_r;
   reg                     write_r;
   reg                     system_r;

   reg [3:0]               lcddata;
   reg                     lcddata_en;

   reg                     device_busy;
   reg [6:0]               device_addr;

   assign busy = (state != s_idle || start);
   assign LCD_DATA = lcddata_en ?
                     lcddata :
                     4'bzzzz;

   always @(posedge CLK or negedge RST)
     if (!RST) begin
        state <= s_wait_15;
     end else begin
        if (fire)
          case (state)
            s_wait_15:
              // wait for 15ms
              if (counter == 11'd1500)
                state <= s_set_8bit_1;

            s_set_8bit_1:
              if (e)
                state <= s_wait_4_1;

            s_wait_4_1:
              // wait for 4.1ms
              if (counter == 11'd410)
                state <= s_set_8bit_2;

            s_set_8bit_2:
              if (e)
                state <= s_wait_0_1;
            
            s_wait_0_1:
              // wait for 0.1ms -> 1ms
              if (counter == 11'd100)
                state <= s_set_8bit_3;
            
            s_set_8bit_3:
              if (e)
                state <= s_wait_0_1_2;

            s_wait_0_1_2:
              if (counter == 11'd100)
                state <= s_set_4bit;

            s_set_4bit:
              if (e)
                state <= s_wait_busy_1;

            s_wait_fire:
              state <= s_byte_1;

            s_byte_1:
              if (e)
                state <= s_byte_2;

            s_byte_2:
              if (e)
                state <= s_wait_busy_1;

            s_wait_busy_1:
              if (e)
                state <= s_wait_busy_2;

            s_wait_busy_2:
              if (e) begin
                if (device_busy)
                  state <= s_wait_busy_1;
                else
                  state <= s_idle;
              end
            
            default: ;
          endcase // case (state)
        else
          case (state)
            s_idle:
              if (start)
                state <= s_wait_fire;
            default: ;
          endcase

     end

   always @(posedge CLK or negedge RST)
     if (!RST) begin
        data_w_r <= 8'h00;
     end else begin
        if (state == s_idle)
          if (start)
            data_w_r <= data_w;
     end

   always @(posedge CLK or negedge RST)
     if (!RST) begin
        write_r <= 1'b0;
        system_r <= 1'b0;
     end else begin
        if (state == s_idle) begin
          if (start) begin
             write_r <= write;
             system_r <= system;
          end
        end
     end

   always @(posedge CLK or negedge RST)
     if (!RST) begin
        lcddata <= 4'h0;
     end else begin
        if (fire)
          case (state)
            s_wait_15, s_set_8bit_1, s_set_8bit_2, s_set_8bit_3:
              lcddata <= 4'b0011;
            s_set_4bit:
              lcddata <= 4'b0010;
            s_byte_1:
              lcddata <= data_w_r[7:4];
            s_byte_2:
              lcddata <= data_w_r[3:0];
            default: ;
          endcase
     end

   always @(posedge CLK or negedge RST)
     if (!RST) begin
        lcddata_en <= 1'b0;
     end else begin
        if (fire)
          case (state)
            s_wait_15: 
              lcddata_en <= 1'b1;
            s_wait_busy_1, s_wait_busy_2:
              lcddata_en <= 1'b0;
            s_byte_1, s_byte_2:
              lcddata_en <= write;
            default: ;
          endcase // case (state)
     end

   always @(posedge CLK or negedge RST)
     if (!RST) begin
        data_r <= 8'h0;
     end else begin
        if (fire)
          case (state)
            s_byte_1:
              data_r[7:4] <= LCD_DATA;
            s_byte_2:
              data_r[3:0] <= LCD_DATA;
          endcase
     end

   always @(posedge CLK or negedge RST)
     if (!RST) begin
        {device_busy, device_addr} <= 8'h0;
     end else begin
        if (fire)
          case (state)
            s_wait_busy_1:
              if (e)
                {device_busy, device_addr[6:4]} <= LCD_DATA;
            s_wait_busy_2:
              if (e)
                device_addr[3:0] <= LCD_DATA;
            default: ;
          endcase
     end


   always @(posedge CLK or negedge RST)
     if (!RST) begin
        e <= 1'b0;
     end else begin
        if (fire)
          case (state)
            s_set_8bit_1, s_set_8bit_2, s_set_8bit_3, s_set_4bit, s_byte_1, s_byte_2,
            s_wait_busy_1, s_wait_busy_2:
              e <= ~e;
            default: ;
          endcase
     end

   always @(posedge CLK or negedge RST)
     if (!RST) begin
        counter <= 11'd0;
     end else begin
        if (fire)
          case (state)
            s_wait_15, s_wait_4_1, s_wait_0_1, s_wait_0_1_2:
              counter <= counter + 11'd1;

            default: 
              counter <= 11'd0;
          endcase
     end // else: !if(!RST)

   always @(posedge CLK or negedge RST)
     if (!RST) begin
        rs <= 1'b0;
     end else begin
        if (fire)
          case (state)
            s_set_8bit_1, s_set_8bit_2, s_set_8bit_3, s_set_4bit: 
              rs <= 1'b0;
            s_byte_1, s_byte_2:
              rs <= !system_r;
            default: 
              rs <= 1'b0;
          endcase
     end

   always @(posedge CLK or negedge RST)
     if (!RST) begin
        rw <= 1'b0;
     end else begin
        if (fire)
          case (state)
            s_set_8bit_1, s_set_8bit_2, s_set_8bit_3, s_set_4bit:
              rw <= 1'b0;
            
            s_wait_busy_1, s_wait_busy_2:
              rw <= 1'b1;

            s_byte_1, s_byte_2:
              if (write)
                rw <= 1'b0;
              else
                rw <= 1'b1;

            default: 
              rw <= 1'b0;
          endcase
            
     end


`define DIVIDER_ZERO {divider_width{1'b0}}
`define DIVIDER_ONE  {{(divider_width-1){1'b0}}, 1'b1}
   always @(posedge CLK or negedge RST)
     if (!RST) begin
        divider <= `DIVIDER_ZERO;
     end else begin
        if (divider == divider_top)
          divider <= `DIVIDER_ZERO;
        else
          divider <= divider + `DIVIDER_ONE;
     end

   always @(posedge CLK or negedge RST)
     if (!RST) begin
        fire <= 1'b0;
     end else begin
        if (divider == divider_top)
          fire <= 1'b1;
        else
          fire <= 1'b0;
     end

endmodule
