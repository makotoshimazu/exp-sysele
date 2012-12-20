
module datop
  (
   input            CLK,
   input            RST,

   output           rd_en,
   input [127:0]    din,
   input            empty,

   output reg [5:0] da1,
   output reg [5:0] da2,
   output reg       da_valid
   );

   localparam s_idle    = 1'd0;
   localparam s_running = 1'd1;
   reg           state;

   reg [127:0]   d;

   localparam index_top = 3'd7;
   reg [2:0]     index;

   wire          fin;
   wire          next_chunk;

   reg           rd_en_r;
   assign rd_en = rd_en_r;

   assign fin = index == index_top && empty;
   assign next_chunk = index == index_top && !empty;
   
   always @(posedge CLK or negedge RST)
     if (!RST) begin
        state <= s_idle;
     end else begin
        case (state)
          s_idle: 
            if (!empty)
              state <= s_running;

          s_running:
            if (fin)
              state <= s_idle;
          
          default: ;
        endcase
     end

   always @(posedge CLK) begin
      case (state)
        s_idle:
          if (!empty)
            d <= din;

        s_running:
          if (next_chunk)
            d <= din;
          else
            d <= {d[111:0], 16'h00};
        
        default: ;
      endcase
   end

   always @(posedge CLK or negedge RST) begin
      if (!RST) begin
         da1 <= 6'h0;
         da2 <= 6'h0;
      end else begin
         da1 <= d[127:122];
         da2 <= d[119:114];
      end
   end

   always @(posedge CLK or negedge RST)
     if (!RST) begin
        index <= 3'd0;
     end else begin
        case (state)
          s_idle: 
            index <= 3'd0;

          s_running:
            index <= index + 3'd1;

        endcase
     end // else: !if(!RST)

   always @(posedge CLK or negedge RST)
     if (!RST) begin
        da_valid <= 1'b0;
     end else begin
        case (state)
          s_idle:
            da_valid <= 1'b0;

          s_running:
            da_valid <= 1'b1;

          default: ;
        endcase
     end

   always @(posedge CLK or negedge RST)
     if (!RST) begin
        rd_en_r <= 1'b0;
     end else begin
        case (state)
          s_idle:
            if (!empty)
              rd_en_r <= 1'b1;
            else
              rd_en_r <= 1'b0;

          s_running:
            if (next_chunk)
              rd_en_r <= 1'b1;
            else
              rd_en_r <= 1'b0;

          default: ;
        endcase
     end

endmodule
