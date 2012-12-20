
module switch
  #(
    parameter counter_bits = 17,
    parameter sync_bits = 3,

    parameter counter_bits_1 = counter_bits - 1,
    parameter samples_bits   = sync_bits + 2,
    parameter samples_bits_1 = samples_bits - 1,
    parameter samples_bits_2 = samples_bits_1 - 1
    )
  (
   input  CLK,
   input  RST,
   
   input  sw, 

   output reg pos,
   output reg neg,
   output d
   );

   reg [counter_bits_1:0] counter;
   reg [samples_bits_1:0]  samples;

   always @(posedge CLK or negedge RST)
     begin
        if (!RST)
          counter <= {counter_bits{1'b0}};
        else
          counter <= counter + {{counter_bits_1{1'b0}}, 1'b1};
     end

   always @(posedge CLK or negedge RST)
     begin
        if (!RST)
          samples <= {samples_bits{1'b0}};
        else
          if (counter == {counter_bits{1'b0}})
            samples <= {samples[samples_bits_2:0], sw};
     end

   always @(posedge CLK or negedge RST)
     if (!RST) begin
        pos <= 1'b0;
        neg <= 1'b0;
     end else begin
        if (counter == {counter_bits{1'b0}}) begin
           pos <= samples[samples_bits_2] & ~samples[samples_bits_1];
           neg <= samples[samples_bits_1] & ~samples[samples_bits_2];
        end else begin
           pos <= 1'b0;
           neg <= 1'b0;
        end
     end


endmodule // switch

