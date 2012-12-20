module ifft64
  #( parameter width = 11 )
    (
     input              CLK,
     input              RST,

     input              valid_a,
     input [width-1:0]  ar,
     input [width-1:0]  ai,

     output             valid_o,
     input              rd_en,
     output             full,
     output [width-1:0] xr,
     output [width-1:0] xi
     );

    wire [width-1:0] fft_xr, fft_xi;

    // 1/64 => 6bits left shift
    // assign xr = {6'b0, fft_xi[width-1:6]};
    // assign xi = {6'b0, fft_xr[width-1:6]};
    assign xr = fft_xi;
    assign xi = fft_xr;

    fft64 ifft_internal( /*AUTOINST*/
                         // Outputs
                         .valid_o        (valid_o),
                         .full           (full),
                         .xr             (fft_xr),
                         .xi             (fft_xi),
                         // Inputs
                         .CLK            (CLK),
                         .RST            (RST),
                         .valid_a        (valid_a),
                         .ar             (ai),
                         .ai             (ar),
                         .rd_en          (rd_en));

    
endmodule
