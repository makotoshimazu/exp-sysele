
module systemace_ll
  (input CLK,
   input             RST,

   output reg [6:0]  MPA,
   inout [15:0]      MPD,
   output            nMPCE,
   output reg        nMPWE,
   output reg        nMPOE,
   input             MPBRDY,
   input             MPIRQ,

   input             llread,
   input             llwrite,
   input [15:0]      llwritedata,
   input [6:0]       lladdr,
   output reg [15:0] llreaddata,
   output reg        llavail,
   output            llbusy,
   input             ll_isbuffer            
   );
   
`define W 5
   reg [`W-1:0] llstate;
   reg [`W-1:0] prev_state;
   
   parameter ll_idle     = `W'b0_0000;
   parameter llr_address = `W'b0_0001;
   parameter llr_oe      = `W'b0_0010;
   parameter llr_wait    = `W'b0_0100;
   parameter llw_address = `W'b0_1000;
   parameter llw_data_we = `W'b1_0000;
`undef W

   reg [15:0]    MPD_r;
   wire          llfinal;

   reg [15:0]    llwritedata_r;
   reg [6:0]     lladdr_r;

   reg           MPBRDY_z;

   wire          genuine_ready = MPBRDY || MPBRDY_z;

   assign llfinal = llstate == llw_data_we
                    || (llstate == llr_oe && (MPBRDY_z || !ll_isbuffer));
   assign llbusy = llstate != ll_idle && !llfinal;

   assign MPD = nMPWE ? 16'hzz : MPD_r;

   assign nMPCE = 1'b0;

   always @(posedge CLK or negedge RST)
     begin
        if (!RST)
          llstate <= ll_idle;
        else begin
           case (llstate)
             ll_idle:
               if (llread)
                 llstate <= llr_address;
               else if (llwrite)
                 llstate <= llw_address;
               else
                 llstate <= ll_idle;
             
             llr_address:
               llstate <= llr_oe;

             llr_oe:
              if ((genuine_ready || !ll_isbuffer)) begin
                  if (llread)
                    llstate <= llr_address;
                  else if (llwrite)
                    llstate <= llw_address;
                  else
                    llstate <= ll_idle;
              end else begin
                 llstate <= llr_wait;
              end

             llr_wait:
               llstate <= llr_oe;

             llw_address:
               llstate <= llw_data_we;

             llw_data_we:
               if (llread)
                 llstate <= llr_address;
               else if (llwrite)
                 llstate <= llw_address;
               else
                 llstate <= ll_idle;
             default:
               ;                // impossible
           endcase // case (llstate)
        end
     end // always @ (posedge CLK or negedge RST)

   always @(posedge CLK or negedge RST)
     if (!RST)
       prev_state <= ll_idle;
     else 
       prev_state <= llstate;

   always @(posedge CLK or negedge RST)
     begin
        if (!RST) begin
           lladdr_r <= 7'h00;
           llwritedata_r <= 16'h0000;
        end else begin
           case (llstate)
             ll_idle, llw_data_we:
               if (llread || llwrite) begin
                  lladdr_r <= lladdr;
                  llwritedata_r <= llwritedata;
               end
             llr_oe:
               if ((genuine_ready || !ll_isbuffer) && (llread || llwrite)) begin
                  lladdr_r <= lladdr;
                  llwritedata_r <= llwritedata;
               end
             default:
               ;
           endcase
        end
     end // always @ (posedge CLK or negedge RST)

   always @(posedge CLK or negedge RST)
     begin
        if (!RST)
          MPA <= 7'h00;
        else begin
           case (llstate)
             llr_address, llw_address:
               MPA <= lladdr_r;
             default:
               ;
           endcase // case (llstate)
        end
     end // always @ (posedge CLK or negedge RST)

   always @(posedge CLK or negedge RST)
     begin
        if (!RST)
          MPD_r <= 16'h00;
        else begin
           case (llstate)
             llw_data_we:
               MPD_r <= llwritedata_r;
             default:
               ;
           endcase
        end
     end

   always @(posedge CLK or negedge RST)
     begin
        if (!RST)
          nMPWE <= 1'b1;
        else begin
           case (llstate)
             llw_data_we:
               nMPWE <= 1'b0;
             default:
               nMPWE <= 1'b1;
           endcase // case (llstate)
        end
     end // always @ (posedge CLK or negedge RST)

   always @(posedge CLK or negedge RST)
     begin
        if (!RST)
          nMPOE <= 1'b1;
        else begin
           case (llstate)
             llr_oe:
               nMPOE <= 1'b0;
             default:
               nMPOE <= 1'b1;
           endcase // case (llstate)
        end
     end // always @ (posedge CLK or negedge RST)

   // assign llreaddata = MPD;
   // assign llavail = prev_state == llr_oe && (MPBRDY || !ll_isbuffer);

   always @(posedge CLK or negedge RST)
     begin
        if (!RST) begin
           llreaddata <= 16'h0000;
           llavail <= 1'b0;
        end else begin
//           if (!nMPOE && (MPBRDY || !ll_isbuffer)) begin
           if (!nMPOE) begin
              llreaddata <= MPD;
              if (genuine_ready || !ll_isbuffer) 
                llavail <= 1'b1;
           end else begin
              llavail <= 1'b0;
           end
        end
     end // always @ (posedge CLK or negedge RST)

   always @(posedge CLK or negedge RST)
     begin
        if (!RST)
          MPBRDY_z <= 1'b0;
        else
          MPBRDY_z <= MPBRDY;
     end

endmodule // systemace_ll

  
