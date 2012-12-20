
module spi 
  (input CLK,
   input            RST,

   inout            SDIO,
   output           SCLK,
   output           CSB,
     
   input [12:0]     addr_i,
   input [7:0]      data_i,
   input            read_i,
   input            start_i,
   output reg [7:0] data_o,
   output           finish_o,
   output           busy_o
   );

   reg [2:0]        state;
   parameter s_idle    = 3'b000;
   parameter s_header1 = 3'b001;
   parameter s_header2 = 3'b010;
   parameter s_data    = 3'b100;

   reg [12:0]   addr_r;
   reg [7:0]    data_r;
   reg          read_r;

   reg [7:0]    sc_data;
   reg          sc_read;
   reg          sc_start;
   wire [7:0]   sc_data_o;
   wire         sc_busy;
   wire         sc_finish;

   assign busy_o = state != s_idle || start_i;
   assign finish_o = state == s_data && !sc_busy;
   
   spi_chunk sc_inst
     (.CLK(CLK),
      .RST(RST),

      .SDIO(SDIO),
      .SCLK(SCLK),
      .CSB(CSB),

      .data_i(sc_data),
      .read_i(sc_read),
      .start_i(sc_start),
      .data_o(sc_data_o),
      .busy_o(sc_busy),
      .finish_o(sc_finish));
   
   always @(posedge CLK or negedge RST)
     if (!RST) begin
        state <= s_idle;
     end else begin
        case (state)
          s_idle: 
            if (start_i)
              state <= s_header1;

          s_header1:
            if (!sc_busy)
              state <= s_header2;

          s_header2:
            if (!sc_busy)
              state <= s_data;

          s_data:
            if (!sc_busy)
              state <= s_idle;

          default: ;
        endcase
     end

   always @(posedge CLK or negedge RST)
     if (!RST) begin
        data_r <= 8'h0;
        addr_r <= 13'h0;
        read_r <= 1'h0;
     end else begin
        if (start_i) begin
           data_r <= data_i;
           addr_r <= addr_i;
           read_r <= read_i;
        end           
     end

   always @(posedge CLK or negedge RST)
     if (!RST) begin
        sc_data <= 8'h0;
     end else begin
        case (state)
          s_idle: 
            sc_data <= {read_i, // read (not write)
                        2'b00,  // 1-bit 
                        addr_i[12:8] // address; addr_r is not loaded yet
                        };

          s_header1:
            if (!sc_busy)
              sc_data <= {addr_r[7:0]}; // next data

          s_header2:
            if (!sc_busy)
              sc_data <= data_r; // next data; ignored when read
          
          default: ;
        endcase
     end

   always @(posedge CLK or negedge RST)
     if (!RST) begin
        sc_read <= 1'b0;
     end else begin
        case (state)
          s_idle:
            sc_read <= 1'b0;    // addr1

          s_header1:
            if (!sc_busy)
              sc_read <= 1'b0;  // addr2

          s_header2:
            if (!sc_busy)
              sc_read <= read_r; // data

          default: ;
        endcase
     end

   always @(posedge CLK or negedge RST)
     if (!RST) begin
        sc_start <= 1'b0;
     end else begin
        case (state)
          s_idle:
             if (start_i)
               sc_start <= 1'b1; // start header1

          s_header1:
            sc_start <= !sc_busy; // start header2

          s_header2:
            sc_start <= !sc_busy; // start data

          s_data:
            sc_start <= 1'b0;   // nothing to do
               
          default: ;
        endcase
     end

   always @(posedge CLK or negedge RST)
     if (!RST) begin
        data_o <= 8'h00;
     end else begin
        if (sc_finish)
          data_o <= sc_data_o;        
     end


endmodule
