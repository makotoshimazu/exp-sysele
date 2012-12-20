   
module lcd
  #(parameter clk_mhz = 240,
    parameter clk_mhz_width = 8
    )
  (
   input       CLK,
   input       RST,

   inout [3:0] LCD_DATA,
   output      RS,
   output      RW,
   output      EN,

   input       row,
   input [3:0] col,
   input [7:0] char,
   input       we,

   input       update,
   output      busy
   );

`define SW 5
   parameter s_idle              = `SW'd0;
   parameter s_init_ram          = `SW'd1;
   parameter s_wait_init         = `SW'd2;
   parameter s_set_nf            = `SW'd3;
   parameter s_set_display_off   = `SW'd4;
   parameter s_set_display_clear = `SW'd5;
   parameter s_set_entry_mode    = `SW'd6;
   parameter s_set_display_on    = `SW'd7;
   parameter s_read_mem          = `SW'd8;
   parameter s_wait_writing      = `SW'd9;
   parameter s_return_home       = `SW'd10;
   parameter s_wait_idle         = `SW'd11;
   parameter s_next_line         = `SW'd12;

   reg [`SW-1:0]    state;
`undef SW

   assign state_o = state;
   
   wire [4:0]              waddr;
   reg [4:0]               waddr_init;
   wire [7:0]              wdata;
   wire                    wen;

   reg [4:0]               raddr;
   wire [7:0]              rdata;

   reg                     lc_start;
   reg [7:0]               lc_data_w;
   wire                    lc_write;
   wire                    lc_busy;
   reg                     lc_system;

   assign waddr = state == s_init_ram ? waddr_init : {row, col};
   assign busy = state != s_idle;
   assign lc_write = 1'b1;
   assign wen = state == s_init_ram ? 1'b1 : we;
   assign wdata = state == s_init_ram ? 8'h20 : char;

   lcd_memory mem
     (.CLK(CLK),
      
      .raddr(raddr),
      .rdata(rdata),

      .waddr(waddr),
      .wdata(wdata),
      .wen(wen));

   lcd_comm
     #(.clk_mhz(clk_mhz),
       .clk_mhz_width(clk_mhz_width)
       )
   inst
     (
      .CLK(CLK),
      .RST(RST),

      .start(lc_start),
      .data_w(lc_data_w),
      .write(lc_write),
      .system(lc_system),
      .data_r(),

      .busy(lc_busy),

      .rs(RS),
      .rw(RW),
      .e(EN),
      .LCD_DATA(LCD_DATA));

   always @(posedge CLK or negedge RST)
     if (!RST) begin
        state <= s_init_ram;
     end else begin
        case (state)
          s_init_ram:
            if (waddr_init == 5'h1f)
              state <= s_wait_init;
          
          s_wait_init: 
            if (!lc_busy)
              state <= s_set_nf;

          s_set_nf:
            if (!lc_busy)
              state <= s_set_display_off;

          s_set_display_off:
            if (!lc_busy)
              state <= s_set_display_clear;

          s_set_display_clear:
            if (!lc_busy)
              state <= s_set_entry_mode;
          
          s_set_entry_mode:
            if (!lc_busy)
              state <= s_set_display_on;

          s_set_display_on:
            if (!lc_busy)
              state <= s_wait_idle;

          s_wait_idle:
            if (!lc_busy)
              state <= s_idle;

          s_idle:
            if (update)
              state <= s_return_home;

          s_return_home:
            if (!lc_busy)
              state <= s_read_mem;

          s_read_mem:
            state <= s_wait_writing;

          s_next_line:
            if (!lc_busy)
              state <= s_read_mem;

          s_wait_writing:
            if (!lc_busy) begin
               if (raddr == 5'h00)
                 state <= s_wait_idle;
               else if (raddr == 5'h10)
                 state <= s_next_line;
               else
                 state <= s_read_mem;
            end

          default: ;
        endcase
     end

   always @(posedge CLK or negedge RST)
     if (!RST) begin
        waddr_init <= 5'h0;
     end else begin
        case (state)
          s_init_ram:
            waddr_init <= waddr_init + 5'd1;

          default: ;
        endcase
     end

   always @(posedge CLK or negedge RST)
     if (!RST) begin
        lc_start <= 1'b0;
     end else begin
        // default
        lc_start <= 1'b0;
        
        if (!lc_busy)
          case (state)
            s_wait_init, s_set_nf, s_set_display_off, s_set_display_clear, s_set_entry_mode: 
              lc_start <= 1'b1;

            s_idle:
              if (update)
                lc_start <= 1'b1;

            s_wait_writing:
              if (!lc_busy && raddr != 5'h00)
                lc_start <= 1'b1;

            s_return_home, s_next_line:
              if (!lc_busy)
                lc_start <= 1'b1;

            default: ;
          endcase
     end

   always @(posedge CLK or negedge RST)
     if (!RST) begin
        lc_data_w <= 8'h0;
     end else begin
        if (!lc_busy)
          case (state)
            s_wait_init: 
              lc_data_w <= 8'b0010_1000;     // 4-bit, two-lines, 5x7 font

            s_set_nf:
              lc_data_w <= 8'b0000_1000; // display, cursor, cursor blinking OFF

            s_set_display_off:
              lc_data_w <= 8'b0000_0001; // clear display

            s_set_display_clear:
              lc_data_w <= 8'b0000_0110; // increment, no shift
             
            s_set_entry_mode:
              lc_data_w <= 8'b0000_1111; // display, cursor, cursor blinking ON
            
            s_idle:
              if (update)
                lc_data_w <= 8'b0000_0010;

            s_return_home:
              if (!lc_busy)
                lc_data_w <= rdata;

            s_wait_writing:
              if (!lc_busy) begin
                 if (raddr == 5'h10)
                   lc_data_w <= 8'b1100_0000;
                 else
                   lc_data_w <= rdata;
              end

            s_next_line:
              if (!lc_busy)
                 lc_data_w <= rdata;
            
            default: ;
          endcase
     end

   always @(posedge CLK or negedge RST)
     if (!RST) begin
        lc_system <= 1'b1;
     end else begin
        case (state)
          s_wait_init, s_set_nf, s_set_display_off, s_set_display_clear, s_set_entry_mode: 
            lc_system <= 1'b1;

          s_idle:
            if (update)
              lc_system <= 1'b1;

          s_return_home, s_next_line:
            if (!lc_busy)
              lc_system <= 1'b0;

          s_wait_writing:
            if (!lc_busy) begin
               if (raddr == 5'h10)
                 lc_system <= 1'b1;
               else
                 lc_system <= 1'b0;
            end
          default: ;
        endcase
     end

   always @(posedge CLK or negedge RST)
     if (!RST) begin
        raddr <= 5'h0;
     end else begin
        case (state)
          s_read_mem: 
            raddr <= raddr + 5'd1;

          s_wait_writing:
            ;

          s_next_line:
            ;
          
          s_return_home:
            ;

          default: 
            raddr <= 5'd0;
        endcase
     end // else: !if(!RST)

endmodule
