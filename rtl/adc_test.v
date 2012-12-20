
module adc_test 
  (
   input        CLK, // 240MHz
   input        RST,
   
   inout        SDIO,
   output       SCLK,
   output       CSB,

   output [7:0] recvdata,

   input        button);

   reg [4:0]    state;
   parameter s_idle          = 5'b00000;
   parameter s_write         = 5'b00001;
   parameter s_transfer      = 5'b00010;
   parameter s_read_transfer = 5'b00100;
   parameter s_read          = 5'b01000;
   parameter s_finish        = 5'b10000;

   reg          clk_low_freq;         // 40MHz
   reg [4:0]    clkdivide;
   parameter clkdivide_count = 5'd8;

   reg [12:0] spi_addr;
   reg [7:0]  senddata;
   reg        spi_read;
   reg        spi_start;
   wire       spi_finish;
   wire       spi_busy;

   wire       transfer_done;

   parameter addr_transfer  = 13'h0ff;
   parameter addr_test_mode = 13'h00d;

   wire       button_pos;

   parameter mode_run          = 8'b0000_0000;
   parameter mode_plus_fs      = 8'b0000_0010;
   parameter mode_minus_fs     = 8'b0000_0011;
   parameter mode_midscale     = 8'b0000_0001;
   parameter mode_checkerboard = 8'b0000_0100;
   parameter mode_one_zero     = 8'b0000_0111;

   reg [7:0]  test_mode;

   spi spi1(.CLK(clk_low_freq),
            .RST(RST),

            .SDIO(SDIO),
            .SCLK(SCLK),
            .CSB(CSB),

            .addr_i(spi_addr),
            .data_i(senddata),
            .read_i(spi_read),
            .start_i(spi_start),
            .data_o(recvdata),
            .finish_o(spi_finish),
            .busy_o(spi_busy)
            );

   switch sw_button
     (.CLK(clk_low_freq),
      .RST(RST),

      .sw(button),

      .pos(button_pos),
      .neg(),
      .d());

   assign transfer_done = !spi_busy && !recvdata[0];

   always @(posedge clk_low_freq or negedge RST)
     if (!RST) begin
        state <= s_idle;
     end else begin
        case (state)
          s_idle: 
            state <= s_write;

          s_write:
            if (!spi_busy)
              state <= s_transfer;

          s_transfer:
            if (!spi_busy)
              state <= s_read_transfer;

          s_read_transfer:
            if (transfer_done)
              state <= s_read;
          
          s_read:
            if (!spi_busy)
              state <= s_finish;

          s_finish:
            if (button_pos)
              state <= s_idle;

          default: ;
        endcase
     end

   always @(posedge clk_low_freq or negedge RST)
     if (!RST) begin
        spi_start <= 1'b0;
     end else begin
        case (state)
          s_idle:
            spi_start <= 1'b1;

          s_write, s_transfer, s_read_transfer:
            spi_start <= !spi_busy;

          default: 
            spi_start <= 1'b0;
        endcase
     end // else: !if(!RST)

   always @(posedge clk_low_freq or negedge RST)
     if (!RST) begin
        spi_read <= 1'b0;
     end else begin
        case (state)
          s_idle: 
            spi_read <= 1'b0;

          s_write:
             if (!spi_busy)
               spi_read <= 1'b0;

          s_transfer:
            if (!spi_busy)
              spi_read <= 1'b1;

          s_read_transfer:
            if (!spi_busy)
              spi_read <= 1'b1;

          default: ;
        endcase
     end


   always @(posedge clk_low_freq or negedge RST)
     if (!RST) begin
        spi_addr <= 13'h0;
     end else begin
        case (state)
          s_idle:
            spi_addr <= addr_test_mode;
          
          s_write:
            if (!spi_busy)
              spi_addr <= addr_transfer;

          s_transfer:
            if (!spi_busy)
              spi_addr <= addr_transfer;

          s_read_transfer:
            if (!transfer_done)
              spi_addr <= addr_test_mode;

          default:
            ;
        endcase
     end

   always @(posedge clk_low_freq or negedge RST)
     if (!RST) begin
        senddata <= 8'h0;
     end else begin
        case (state)
          s_idle: 
            senddata <= test_mode;

          s_write:
            if (!spi_busy)
              senddata <= 8'b0000_0001;

          default: ;
        endcase
     end

   always @(posedge clk_low_freq or negedge RST)
     if (!RST) begin
        test_mode <= mode_run;
     end else begin
        if (state == s_finish && button_pos)
          case (test_mode)
            mode_run:
              test_mode <= mode_plus_fs;
            mode_plus_fs:
              test_mode <= mode_minus_fs;
            mode_minus_fs:
              test_mode <= mode_midscale;
            mode_midscale:
              test_mode <= mode_checkerboard;
            mode_checkerboard:
              test_mode <= mode_one_zero;
            mode_one_zero:
              test_mode <= mode_run;
          endcase
     end


   always @(posedge CLK or negedge RST)
     if (!RST) begin
        clkdivide <= 5'h0;
     end else begin
        if (clkdivide == clkdivide_count - 1)
          clkdivide <= 5'd0;
        else
          clkdivide <= clkdivide + 5'd1;
     end

   always @(posedge CLK or negedge RST)
     if (!RST) begin
        clk_low_freq <= 1'b0;
     end else begin
        if (clkdivide == clkdivide_count - 1)
          clk_low_freq <= ~clk_low_freq;
     end

endmodule
