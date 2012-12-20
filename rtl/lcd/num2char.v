
module num2char
  (
   input        CLK,
   input        RST,

   input        start_update,
   input [31:0] error_rate,

   output [7:0] char,
   output       valid_o
   );

   localparam s_idle = 2'd0;
   localparam s_wait = 2'd1;
   localparam s_char = 2'd2;
   reg [1:0]    state;

   wire [3:0]   bcd[0:9];
   reg [3:0]    bcdreg[0:9];
   wire         en;
   wire         fin;
   localparam counter_top = 4'd9;
   reg [3:0]    counter;

   assign en = state == s_idle && start_update;
   assign valid_o = state == s_char;
   assign char = bcdreg[9] + "0";

   always @(posedge CLK or negedge RST)
     if (!RST) begin
        state <= s_idle;
     end else begin
        case (state)
          s_idle:
            if (start_update)
              state <= s_wait;

          s_wait:
            if (fin)
              state <= s_char;

          s_char:
            if (counter == counter_top)
              state <= s_idle;
          
          default: ;
        endcase
     end // else: !if(!RST)
   generate
      genvar    g;

      for (g=0; g<=9; g=g+1) begin : GENERATE_BCD
         always @(posedge CLK) begin
            if (fin)
              bcdreg[g] <= bcd[g];
            else
              if (g == 0)
                bcdreg[g] <= 4'd0;
              else
                bcdreg[g] <= bcdreg[g-1];
         end
      end
   endgenerate

   always @(posedge CLK or negedge RST)
     if (!RST) begin
        counter <= 4'd0;
     end else begin
        case (state)
          s_char: 
            counter <= counter + 4'd1;
          
          default: 
            counter <= 4'd0;
        endcase
     end

   bin2bcd32 bin2bcd_inst
     (
      .CLK(CLK),
      .RST(RST),

      .en(en),
      .bin(error_rate),

      .bcd0(bcd[0]),
      .bcd1(bcd[1]),
      .bcd2(bcd[2]),
      .bcd3(bcd[3]),
      .bcd4(bcd[4]),
      .bcd5(bcd[5]),
      .bcd6(bcd[6]),
      .bcd7(bcd[7]),
      .bcd8(bcd[8]),
      .bcd9(bcd[9]),

      .busy(busy),
      .fin(fin)
      );
   
endmodule
