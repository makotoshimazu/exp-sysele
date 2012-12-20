
module iqmap_16qam
  (
   input             CLK,
   input             RST,

   input             ce,
   
   input             valid_i,
   input [127:0]     reader_data,
   output            reader_en,

   output reg [10:0] xr,
   output reg [10:0] xi,
   output reg        valid_o,

   output            valid_raw,
   output reg [3:0]  raw
   );
   
`define SW 2
   localparam s_idle = `SW'b01;
   localparam s_active = `SW'b10;
   reg [`SW-1:0] state;
`undef SW

   reg [127:0]   d;

   localparam counter_top = 5'd31;
   reg [4:0]     counter;

   reg           reader_en_r;

   assign reader_en = reader_en_r & ce;
   
   localparam p3 =  11'sd6;
   localparam p1 =  11'sd2;
   localparam m1 = -11'sd2;
   localparam m3 = -11'sd6;

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
             d <= {4'b0, d[127:4]};
         
         default: ;
       endcase

   always @(posedge CLK or negedge RST)
     if (!RST) begin
        counter <= 5'd0;
     end else begin
        if (ce)
          case (state)
            s_idle:
              counter <= 5'd0;
            
            s_active: 
              counter <= counter + 5'd1;

            default: ;
          endcase
     end // else: !if(!RST)

   always @(posedge CLK)
     if (ce)
       raw <= d[3:0];

   always @(posedge CLK)
     if (ce)
       case (d[3:0])
         4'd0: begin
            xr <= m1;
            xi <= m1;
         end
         4'd1: begin
            xr <= m1;
            xi <= m3;
         end
         4'd2: begin
            xr <= m3;
            xi <= m1;
         end
         4'd3: begin
            xr <= m3;
            xi <= m3;
         end
         4'd4: begin
            xr <= m1;
            xi <= p1;
         end
         4'd5: begin
            xr <= m1;
            xi <= p3;
         end
         4'd6: begin
            xr <= m3;
            xi <= p1;
         end
         4'd7: begin
            xr <= m3;
            xi <= p3;
         end
         4'd8: begin
            xr <= p1;
            xi <= m1;
         end
         4'd9: begin
            xr <= p1;
            xi <= m3;
         end
         4'd10: begin
            xr <= p3;
            xi <= m1;
         end
         4'd11: begin
            xr <= p3;
            xi <= m3;
         end
         4'd12: begin
            xr <= p1;
            xi <= p1;
         end
         4'd13: begin
            xr <= p1;
            xi <= p3;
         end
         4'd14: begin
            xr <= p3;
            xi <= p1;
         end
         4'd15: begin
            xr <= p3;
            xi <= p3;
         end
         default:
           ;
       endcase // case (d[1:0])
              
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
