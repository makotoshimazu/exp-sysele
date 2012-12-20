
module iqmap_bpsk
  (
   input             CLK,
   input             RST,

   input             ce,
   
   input             valid_i,
   input [127:0]     reader_data,
   output            reader_en,

   output reg [10:0] xr,
   output [10:0]     xi,
   output reg        valid_o,

   output            valid_raw,
   output reg        raw
   );
   
`define SW 2
   localparam s_idle = `SW'b01;
   localparam s_active = `SW'b10;
   reg [`SW-1:0] state;
`undef SW

   reg [127:0]   d;

   localparam counter_top = 7'h7f;
   reg [6:0]     counter;

   reg           reader_en_r;

   assign reader_en = reader_en_r & ce;
   
   localparam high = 11'sd8;
   localparam low  = -11'sd8;

   assign xi = 11'd0;

   wire          fin = counter == counter_top && !valid_i;
   wire          next_chunk = counter == counter_top && valid_i;

   assign valid_raw = valid_o;

   always @(posedge CLK or negedge RST)
     if (!RST) begin
        state <= s_idle;
     end else begin
        if (ce)
          case (state)
            s_idle: 
              if (valid_i)
                state <= s_active;

            s_active:
              if (fin)
                state <= s_idle;

            default:;
          endcase
     end

   always @(posedge CLK)
     if (ce)
       case (state)
         s_idle:
           if (valid_i)
             d <= reader_data;

         s_active:
           if (next_chunk)
             d <= reader_data;
           else
             d <= {1'b0, d[127:1]};
         
         default: ;
       endcase

   always @(posedge CLK or negedge RST)
     if (!RST) begin
        counter <= 7'd0;
     end else begin
        if (ce)
          case (state)
            s_idle:
              counter <= 7'd0;
            
            s_active: 
              counter <= counter + 7'd1;

            default: ;
          endcase
     end // else: !if(!RST)

   always @(posedge CLK)
     if (ce)
       raw <= d[0];

   always @(posedge CLK)
     if (ce)
       if (d[0])
         xr <= high;
       else
         xr <= low;

   always @(posedge CLK or negedge RST)
     if (!RST) begin
        valid_o <= 1'b0;
     end else begin
        if (ce)
          case (state)
            s_idle: 
              valid_o <= 1'b0;

            s_active:
              valid_o <= 1'b1;
            
            default: ;
          endcase
     end // else: !if(!RST)

   always @(posedge CLK or negedge RST)
     if (!RST) begin
        reader_en_r <= 1'b0;
     end else begin
        if (ce)
          case (state)
            s_idle: 
              if (valid_i)
                reader_en_r <= 1'b1;
              else
                reader_en_r <= 1'b0;

            s_active:
              if (next_chunk)
                reader_en_r <= 1'b1;
              else
                reader_en_r <= 1'b0;

            default: ;
          endcase
     end

endmodule
