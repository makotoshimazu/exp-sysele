
module ber
  #(
    parameter update_period = 32'd240_000_000
    )
  (
   input             CLK,
   input             RST,

   input             valid_i,
   input [7:0]       sent_data,
   input [7:0]       recv_data,

   output reg        valid_o, 
   output reg [31:0] error_rate
   );
   
   reg [31:0]        hamm_dist;
   reg [7:0]         xr;
   reg               valid_i_d;
   reg               valid_i_dd;
   reg [31:0]        counter;
   localparam counter_top = update_period;
   
   always @(posedge CLK or negedge RST)
     if (!RST) begin
        counter <= 32'd0;
     end else begin
        if (valid_i_d) begin
          if (counter == counter_top)
            counter <= 32'd0;
          else
            counter <= counter + 32'd1;
        end        
     end

   always @(posedge CLK or negedge RST)
     if (!RST) begin
        valid_i_d <= 1'b0;
     end else begin
        valid_i_d <= valid_i;
     end

   always @(posedge CLK or negedge RST)
     if (!RST) begin
        valid_i_dd <= 1'b0;
     end else begin
        valid_i_dd <= valid_i_d;
     end

   always @(posedge CLK) begin
      xr <= sent_data ^ recv_data;
   end

   always @(posedge CLK or negedge RST)
     if (!RST) begin
        hamm_dist <= 32'h0;
     end else begin
        case (xr)
          /* (progn
           (forward-line 3)
           (flet ((count1 (a)
           (let* ((tmp1 (+ (logand a    #x55) (lsh (logand a    #xaa) -1)))
           (tmp2 (+ (logand tmp1 #x33) (lsh (logand tmp1 #xcc) -2)))
           (tmp3 (+ (logand tmp2 #x0f) (lsh (logand tmp2 #xf0) -4))))
           tmp3)))
           (dotimes (i 256) (insert (format "          32'h%02x: hamm_dist <= 4'd%d;\n" i (count1 i))))))
           
           */

          32'h00: hamm_dist <= 4'd0;
          32'h01: hamm_dist <= 4'd1;
          32'h02: hamm_dist <= 4'd1;
          32'h03: hamm_dist <= 4'd2;
          32'h04: hamm_dist <= 4'd1;
          32'h05: hamm_dist <= 4'd2;
          32'h06: hamm_dist <= 4'd2;
          32'h07: hamm_dist <= 4'd3;
          32'h08: hamm_dist <= 4'd1;
          32'h09: hamm_dist <= 4'd2;
          32'h0a: hamm_dist <= 4'd2;
          32'h0b: hamm_dist <= 4'd3;
          32'h0c: hamm_dist <= 4'd2;
          32'h0d: hamm_dist <= 4'd3;
          32'h0e: hamm_dist <= 4'd3;
          32'h0f: hamm_dist <= 4'd4;
          32'h10: hamm_dist <= 4'd1;
          32'h11: hamm_dist <= 4'd2;
          32'h12: hamm_dist <= 4'd2;
          32'h13: hamm_dist <= 4'd3;
          32'h14: hamm_dist <= 4'd2;
          32'h15: hamm_dist <= 4'd3;
          32'h16: hamm_dist <= 4'd3;
          32'h17: hamm_dist <= 4'd4;
          32'h18: hamm_dist <= 4'd2;
          32'h19: hamm_dist <= 4'd3;
          32'h1a: hamm_dist <= 4'd3;
          32'h1b: hamm_dist <= 4'd4;
          32'h1c: hamm_dist <= 4'd3;
          32'h1d: hamm_dist <= 4'd4;
          32'h1e: hamm_dist <= 4'd4;
          32'h1f: hamm_dist <= 4'd5;
          32'h20: hamm_dist <= 4'd1;
          32'h21: hamm_dist <= 4'd2;
          32'h22: hamm_dist <= 4'd2;
          32'h23: hamm_dist <= 4'd3;
          32'h24: hamm_dist <= 4'd2;
          32'h25: hamm_dist <= 4'd3;
          32'h26: hamm_dist <= 4'd3;
          32'h27: hamm_dist <= 4'd4;
          32'h28: hamm_dist <= 4'd2;
          32'h29: hamm_dist <= 4'd3;
          32'h2a: hamm_dist <= 4'd3;
          32'h2b: hamm_dist <= 4'd4;
          32'h2c: hamm_dist <= 4'd3;
          32'h2d: hamm_dist <= 4'd4;
          32'h2e: hamm_dist <= 4'd4;
          32'h2f: hamm_dist <= 4'd5;
          32'h30: hamm_dist <= 4'd2;
          32'h31: hamm_dist <= 4'd3;
          32'h32: hamm_dist <= 4'd3;
          32'h33: hamm_dist <= 4'd4;
          32'h34: hamm_dist <= 4'd3;
          32'h35: hamm_dist <= 4'd4;
          32'h36: hamm_dist <= 4'd4;
          32'h37: hamm_dist <= 4'd5;
          32'h38: hamm_dist <= 4'd3;
          32'h39: hamm_dist <= 4'd4;
          32'h3a: hamm_dist <= 4'd4;
          32'h3b: hamm_dist <= 4'd5;
          32'h3c: hamm_dist <= 4'd4;
          32'h3d: hamm_dist <= 4'd5;
          32'h3e: hamm_dist <= 4'd5;
          32'h3f: hamm_dist <= 4'd6;
          32'h40: hamm_dist <= 4'd1;
          32'h41: hamm_dist <= 4'd2;
          32'h42: hamm_dist <= 4'd2;
          32'h43: hamm_dist <= 4'd3;
          32'h44: hamm_dist <= 4'd2;
          32'h45: hamm_dist <= 4'd3;
          32'h46: hamm_dist <= 4'd3;
          32'h47: hamm_dist <= 4'd4;
          32'h48: hamm_dist <= 4'd2;
          32'h49: hamm_dist <= 4'd3;
          32'h4a: hamm_dist <= 4'd3;
          32'h4b: hamm_dist <= 4'd4;
          32'h4c: hamm_dist <= 4'd3;
          32'h4d: hamm_dist <= 4'd4;
          32'h4e: hamm_dist <= 4'd4;
          32'h4f: hamm_dist <= 4'd5;
          32'h50: hamm_dist <= 4'd2;
          32'h51: hamm_dist <= 4'd3;
          32'h52: hamm_dist <= 4'd3;
          32'h53: hamm_dist <= 4'd4;
          32'h54: hamm_dist <= 4'd3;
          32'h55: hamm_dist <= 4'd4;
          32'h56: hamm_dist <= 4'd4;
          32'h57: hamm_dist <= 4'd5;
          32'h58: hamm_dist <= 4'd3;
          32'h59: hamm_dist <= 4'd4;
          32'h5a: hamm_dist <= 4'd4;
          32'h5b: hamm_dist <= 4'd5;
          32'h5c: hamm_dist <= 4'd4;
          32'h5d: hamm_dist <= 4'd5;
          32'h5e: hamm_dist <= 4'd5;
          32'h5f: hamm_dist <= 4'd6;
          32'h60: hamm_dist <= 4'd2;
          32'h61: hamm_dist <= 4'd3;
          32'h62: hamm_dist <= 4'd3;
          32'h63: hamm_dist <= 4'd4;
          32'h64: hamm_dist <= 4'd3;
          32'h65: hamm_dist <= 4'd4;
          32'h66: hamm_dist <= 4'd4;
          32'h67: hamm_dist <= 4'd5;
          32'h68: hamm_dist <= 4'd3;
          32'h69: hamm_dist <= 4'd4;
          32'h6a: hamm_dist <= 4'd4;
          32'h6b: hamm_dist <= 4'd5;
          32'h6c: hamm_dist <= 4'd4;
          32'h6d: hamm_dist <= 4'd5;
          32'h6e: hamm_dist <= 4'd5;
          32'h6f: hamm_dist <= 4'd6;
          32'h70: hamm_dist <= 4'd3;
          32'h71: hamm_dist <= 4'd4;
          32'h72: hamm_dist <= 4'd4;
          32'h73: hamm_dist <= 4'd5;
          32'h74: hamm_dist <= 4'd4;
          32'h75: hamm_dist <= 4'd5;
          32'h76: hamm_dist <= 4'd5;
          32'h77: hamm_dist <= 4'd6;
          32'h78: hamm_dist <= 4'd4;
          32'h79: hamm_dist <= 4'd5;
          32'h7a: hamm_dist <= 4'd5;
          32'h7b: hamm_dist <= 4'd6;
          32'h7c: hamm_dist <= 4'd5;
          32'h7d: hamm_dist <= 4'd6;
          32'h7e: hamm_dist <= 4'd6;
          32'h7f: hamm_dist <= 4'd7;
          32'h80: hamm_dist <= 4'd1;
          32'h81: hamm_dist <= 4'd2;
          32'h82: hamm_dist <= 4'd2;
          32'h83: hamm_dist <= 4'd3;
          32'h84: hamm_dist <= 4'd2;
          32'h85: hamm_dist <= 4'd3;
          32'h86: hamm_dist <= 4'd3;
          32'h87: hamm_dist <= 4'd4;
          32'h88: hamm_dist <= 4'd2;
          32'h89: hamm_dist <= 4'd3;
          32'h8a: hamm_dist <= 4'd3;
          32'h8b: hamm_dist <= 4'd4;
          32'h8c: hamm_dist <= 4'd3;
          32'h8d: hamm_dist <= 4'd4;
          32'h8e: hamm_dist <= 4'd4;
          32'h8f: hamm_dist <= 4'd5;
          32'h90: hamm_dist <= 4'd2;
          32'h91: hamm_dist <= 4'd3;
          32'h92: hamm_dist <= 4'd3;
          32'h93: hamm_dist <= 4'd4;
          32'h94: hamm_dist <= 4'd3;
          32'h95: hamm_dist <= 4'd4;
          32'h96: hamm_dist <= 4'd4;
          32'h97: hamm_dist <= 4'd5;
          32'h98: hamm_dist <= 4'd3;
          32'h99: hamm_dist <= 4'd4;
          32'h9a: hamm_dist <= 4'd4;
          32'h9b: hamm_dist <= 4'd5;
          32'h9c: hamm_dist <= 4'd4;
          32'h9d: hamm_dist <= 4'd5;
          32'h9e: hamm_dist <= 4'd5;
          32'h9f: hamm_dist <= 4'd6;
          32'ha0: hamm_dist <= 4'd2;
          32'ha1: hamm_dist <= 4'd3;
          32'ha2: hamm_dist <= 4'd3;
          32'ha3: hamm_dist <= 4'd4;
          32'ha4: hamm_dist <= 4'd3;
          32'ha5: hamm_dist <= 4'd4;
          32'ha6: hamm_dist <= 4'd4;
          32'ha7: hamm_dist <= 4'd5;
          32'ha8: hamm_dist <= 4'd3;
          32'ha9: hamm_dist <= 4'd4;
          32'haa: hamm_dist <= 4'd4;
          32'hab: hamm_dist <= 4'd5;
          32'hac: hamm_dist <= 4'd4;
          32'had: hamm_dist <= 4'd5;
          32'hae: hamm_dist <= 4'd5;
          32'haf: hamm_dist <= 4'd6;
          32'hb0: hamm_dist <= 4'd3;
          32'hb1: hamm_dist <= 4'd4;
          32'hb2: hamm_dist <= 4'd4;
          32'hb3: hamm_dist <= 4'd5;
          32'hb4: hamm_dist <= 4'd4;
          32'hb5: hamm_dist <= 4'd5;
          32'hb6: hamm_dist <= 4'd5;
          32'hb7: hamm_dist <= 4'd6;
          32'hb8: hamm_dist <= 4'd4;
          32'hb9: hamm_dist <= 4'd5;
          32'hba: hamm_dist <= 4'd5;
          32'hbb: hamm_dist <= 4'd6;
          32'hbc: hamm_dist <= 4'd5;
          32'hbd: hamm_dist <= 4'd6;
          32'hbe: hamm_dist <= 4'd6;
          32'hbf: hamm_dist <= 4'd7;
          32'hc0: hamm_dist <= 4'd2;
          32'hc1: hamm_dist <= 4'd3;
          32'hc2: hamm_dist <= 4'd3;
          32'hc3: hamm_dist <= 4'd4;
          32'hc4: hamm_dist <= 4'd3;
          32'hc5: hamm_dist <= 4'd4;
          32'hc6: hamm_dist <= 4'd4;
          32'hc7: hamm_dist <= 4'd5;
          32'hc8: hamm_dist <= 4'd3;
          32'hc9: hamm_dist <= 4'd4;
          32'hca: hamm_dist <= 4'd4;
          32'hcb: hamm_dist <= 4'd5;
          32'hcc: hamm_dist <= 4'd4;
          32'hcd: hamm_dist <= 4'd5;
          32'hce: hamm_dist <= 4'd5;
          32'hcf: hamm_dist <= 4'd6;
          32'hd0: hamm_dist <= 4'd3;
          32'hd1: hamm_dist <= 4'd4;
          32'hd2: hamm_dist <= 4'd4;
          32'hd3: hamm_dist <= 4'd5;
          32'hd4: hamm_dist <= 4'd4;
          32'hd5: hamm_dist <= 4'd5;
          32'hd6: hamm_dist <= 4'd5;
          32'hd7: hamm_dist <= 4'd6;
          32'hd8: hamm_dist <= 4'd4;
          32'hd9: hamm_dist <= 4'd5;
          32'hda: hamm_dist <= 4'd5;
          32'hdb: hamm_dist <= 4'd6;
          32'hdc: hamm_dist <= 4'd5;
          32'hdd: hamm_dist <= 4'd6;
          32'hde: hamm_dist <= 4'd6;
          32'hdf: hamm_dist <= 4'd7;
          32'he0: hamm_dist <= 4'd3;
          32'he1: hamm_dist <= 4'd4;
          32'he2: hamm_dist <= 4'd4;
          32'he3: hamm_dist <= 4'd5;
          32'he4: hamm_dist <= 4'd4;
          32'he5: hamm_dist <= 4'd5;
          32'he6: hamm_dist <= 4'd5;
          32'he7: hamm_dist <= 4'd6;
          32'he8: hamm_dist <= 4'd4;
          32'he9: hamm_dist <= 4'd5;
          32'hea: hamm_dist <= 4'd5;
          32'heb: hamm_dist <= 4'd6;
          32'hec: hamm_dist <= 4'd5;
          32'hed: hamm_dist <= 4'd6;
          32'hee: hamm_dist <= 4'd6;
          32'hef: hamm_dist <= 4'd7;
          32'hf0: hamm_dist <= 4'd4;
          32'hf1: hamm_dist <= 4'd5;
          32'hf2: hamm_dist <= 4'd5;
          32'hf3: hamm_dist <= 4'd6;
          32'hf4: hamm_dist <= 4'd5;
          32'hf5: hamm_dist <= 4'd6;
          32'hf6: hamm_dist <= 4'd6;
          32'hf7: hamm_dist <= 4'd7;
          32'hf8: hamm_dist <= 4'd5;
          32'hf9: hamm_dist <= 4'd6;
          32'hfa: hamm_dist <= 4'd6;
          32'hfb: hamm_dist <= 4'd7;
          32'hfc: hamm_dist <= 4'd6;
          32'hfd: hamm_dist <= 4'd7;
          32'hfe: hamm_dist <= 4'd7;
          32'hff: hamm_dist <= 4'd8;

        endcase
     end


   always @(posedge CLK or negedge RST)
     if (!RST) begin
        error_rate <= 32'h0;
     end else begin
        if (valid_o) begin
           // INITIALIZE
           if (valid_i_dd)
             error_rate <= hamm_dist;
           else
             error_rate <= 32'h0;
        end
        else if (valid_i_dd)
          error_rate <= error_rate + hamm_dist;
     end

   always @(posedge CLK or negedge RST)
     if (!RST) begin
        valid_o <= 1'b0;
     end else begin
        if (valid_i_d && counter == 32'd0)
          valid_o <= 1'b1;
        else
          valid_o <= 1'b0;
     end

endmodule
