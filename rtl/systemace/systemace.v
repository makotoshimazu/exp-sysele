
`define ADDR_BUSMODEREG_7_0     7'h00
`define ADDR_BUSMODEREG_15_8    7'h01
`define ADDR_STATUSREG_7_0      7'h04
`define ADDR_STATUSREG_15_8     7'h05
`define ADDR_STATUSREG_23_16    7'h06
`define ADDR_STATUSREG_31_24    7'h07
`define ADDR_ERRORREG_7_0       7'h08
`define ADDR_ERRORREG_15_8      7'h09
`define ADDR_ERRORREG_23_16     7'h0A
`define ADDR_ERRORREG_31_24     7'h0B
`define ADDR_CFGLBAREG_7_0      7'h0C
`define ADDR_CFGLBAREG_15_8     7'h0D
`define ADDR_CFGLBAREG_23_16    7'h0E
`define ADDR_CFGLBAREG_31_24    7'h0F
`define ADDR_MPULBAREG_7_0      7'h10
`define ADDR_MPULBAREG_15_8     7'h11
`define ADDR_MPULBAREG_23_16    7'h12
`define ADDR_MPULBAREG_31_24    7'h13
`define ADDR_SECCNTCMDREG_7_0   7'h14
`define ADDR_SECCNTCMDREG_15_8  7'h15
`define ADDR_VERSIONREG_7_0     7'h16
`define ADDR_VERSIONREG_15_8    7'h17
`define ADDR_CONTROLREG_7_0     7'h18
`define ADDR_CONTROLREG_15_8    7'h19
`define ADDR_CONTROLREG_23_16   7'h1A
`define ADDR_CONTROLREG_31_24   7'h1B
`define ADDR_FATSTATREG_7_0     7'h1C
`define ADDR_FATSTATREG_15_8    7'h1D
`define ADDR_DATABUFREG_7_0     7'h40
`define ADDR_DATABUFREG_15_8    7'h41

`define ADDR_BUSMODEREG_15_0    7'h00
`define ADDR_STATUSREG_15_0     7'h04
`define ADDR_STATUSREG_31_16    7'h06
`define ADDR_ERRORREG_15_0      7'h08
`define ADDR_ERRORREG_31_16     7'h0A
`define ADDR_CFGLBAREG_15_0     7'h0C
`define ADDR_CFGLBAREG_31_16    7'h0E
`define ADDR_MPULBAREG_15_0     7'h10
`define ADDR_MPULBAREG_31_16    7'h12
`define ADDR_SECCNTCMDREG_15_0  7'h14
`define ADDR_VERSIONREG_15_0    7'h16
`define ADDR_CONTROLREG_15_0    7'h18
`define ADDR_CONTROLREG_31_16   7'h1A
`define ADDR_FATSTATREG_15_0    7'h1C
`define ADDR_DATABUFREG_15_0    7'h40

module wait_for_buffer_ready
  (input CLK,
   input         RST,

   input         start,
   output        llread,
   output        llwrite,
   output [15:0] llwritedata,
   input [15:0]  llreaddata, 
   output [6:0]  lladdr,
   input         llavail,
   input         llbusy,
   output        llreq,
   output        ll_isbuffer,
   
   output        ready,
   output        busy
   );

`define W 3
   reg [`W-1:0]  state;
   
   parameter state_idle            = `W'b000;
   parameter state_databufrdy      = `W'b001;
   parameter state_wait_databufrdy = `W'b010;

`undef W

   assign lladdr = state == state_databufrdy ? `ADDR_STATUSREG_15_0
                   : 7'h00;
   
   assign llread = state == state_databufrdy;
   assign llwrite = 1'b0;
   assign ready  = (state == state_wait_databufrdy) && llavail && llreaddata[5];
   assign ll_isbuffer = 1'b0;

   assign llwritedata = 16'h0;

   assign busy = state != state_idle;

   assign llreq = state != state_idle;
   
   always @(posedge CLK or negedge RST)
     begin
        if (!RST)
          state <= state_idle;
        else
          if (!llbusy) begin
             case (state)
               state_idle:
                 if (start)
                   state <= state_databufrdy;

               state_databufrdy:
                 state <= state_wait_databufrdy;

               state_wait_databufrdy:
                 if (llavail && llreaddata[5]) // Data buffer ready!
                   state <= state_idle;
                 else if (llavail)
                   state <= state_databufrdy; // Data buffer not ready...
               default:;                           // impossible
             endcase // case (state)
          end
     end // always @ (posedge CLK or negedge RST)
endmodule // wait_for_buffer_ready

module read_data_buffer
  (input CLK,
   input         RST,

   input         start,
   output        llread,
   output        llwrite,
   output [15:0] llwritedata,
   input [15:0]  llreaddata, 
   output [6:0]  lladdr,
   input         llavail,
   input         llbusy,
   output        llreq,
   output        ll_isbuffer,
   
   output        start_buffer_ready,
   input         buffer_ready,
   input         buffer_ready_busy,

   output        sysace_read_avail,

   output        busy
   );

`define W 7
   reg [`W-1:0]  state;
   
   parameter state_idle                  = `W'b000_0001;
   parameter state_wait_for_buffer_ready = `W'b000_0010;
   parameter state_consume               = `W'b000_0100;
   parameter state_transfer              = `W'b000_1000;
   parameter state_last_word             = `W'b001_0000;
   parameter state_blank_read            = `W'b010_0000;
   parameter state_blank                 = `W'b100_0000;
`undef W

   reg [7:0] counter;
   parameter max_counter = 8'd255;

   reg [3:0] w_counter;
   parameter max_w_counter = 4'd10;

   assign llwrite = 1'b0;
   assign llread = state == state_consume || state == state_transfer || state == state_blank_read;
   assign llwritedata = 16'h0000;
   assign lladdr = state == state_blank_read ? `ADDR_STATUSREG_15_0 : 
                   `ADDR_DATABUFREG_15_0;
   assign ll_isbuffer = state != state_blank && state != state_blank_read;

   assign busy = state != state_idle;
   assign llreq = state != state_idle
                  && state != state_wait_for_buffer_ready;

   assign start_buffer_ready = state == state_wait_for_buffer_ready;

   assign sysace_read_avail
     = (state == state_transfer || state == state_last_word) && llavail;

   always @(posedge CLK or negedge RST)
     begin
        if (!RST)
          state <= state_idle;
        else
          case (state)
            state_idle:
              if (start)
                state <= state_wait_for_buffer_ready;

            state_wait_for_buffer_ready:
              if (buffer_ready)
                state <= state_consume;

            state_consume:
              if (llavail)
                state <= state_transfer;
            
            state_transfer:
              if (counter == max_counter)
                state <= state_last_word;

            state_last_word:
              if (llavail)
                state <= state_blank_read;

            state_blank_read:
              if (w_counter == max_w_counter)
                state <= state_blank;

            state_blank:
              if (w_counter == max_w_counter)
                state <= state_idle;
          endcase // case (state)
     end // always @ (posedge CLK or negedge RST)

   always @(posedge CLK or negedge RST)
     begin
        if (!RST)
          counter <= 8'h00;
        else begin
           case (state)
             state_transfer:
               if (llavail)
                 counter <= counter + 1;

             default:
               counter <= 8'h00;
           endcase // case (state)
        end // else: !if(!RST)
     end // always @ (posedge CLK or negedge RST)

   always @(posedge CLK or negedge RST)
     begin
        if (!RST)
          w_counter <= 4'd0;
        else
          case (state)
            state_blank, state_blank_read:
              if (w_counter == max_w_counter)
                w_counter <= 4'd0;
              else
                w_counter <= w_counter + 4'd1;
            default:
              w_counter <= 4'd0;
          endcase // case (state)
     end
endmodule // read_data_buffer

module get_cf_lock
  (input CLK,
   input         RST,

   input         start,
   output        llread,
   output        llwrite,
   output [15:0] llwritedata,
   input [15:0]  llreaddata, 
   output [6:0]  lladdr,
   input         llavail,
   input         llbusy,
   output        llreq,
   output        ll_isbuffer,

   output        busy
   );

`define W 3
   reg [`W-1:0] state;

   parameter state_idle         = `W'b000;
   parameter state_lockreq      = `W'b001;
   parameter state_mpulock      = `W'b010;
   parameter state_wait_mpulock = `W'b100;
`undef W
 
   assign llread = state == state_mpulock;
   assign llwrite = state == state_lockreq;
   assign llwritedata = 16'b0000_0000_0000_0010;
   assign lladdr = state == state_lockreq ? `ADDR_CONTROLREG_15_0 :
                   state == state_mpulock ? `ADDR_STATUSREG_15_0 :
                   7'h00;
   assign llreq = state != state_idle;
   assign ll_isbuffer = 1'b0;
   assign busy  = state != state_idle;
   
   always @(posedge CLK or negedge RST)
     begin
        if (!RST)
          state <= state_idle;
        else
          case (state)
            state_idle:
              if (start)
                state <= state_lockreq;

            state_lockreq:
              if (!llbusy)
                state <= state_mpulock;
            
            state_mpulock:
              if (!llbusy)
                state <= state_wait_mpulock;
            
            state_wait_mpulock:
              if (llavail && llreaddata[1])
                state <= state_idle;
              else if (llavail)
                state <= state_lockreq;
            
            default:
              ;
          endcase // case (state)
     end

endmodule // get_cf_lock

module check_if_ready_for_command
  (input CLK,
   input         RST,

   input         start,
   output        llread,
   output        llwrite,
   output [15:0] llwritedata,
   input [15:0]  llreaddata, 
   output [6:0]  lladdr,
   input         llavail,
   input         llbusy,
   output        llreq,
   output        ll_isbuffer,

   output        busy
   );

`define W 2
   reg [`W-1:0] state;

   parameter state_idle = `W'b00;
   parameter state_rdyforcmd = `W'b01;
   parameter state_wait_rdyforcmd = `W'b10;
`undef W

   assign llread = state == state_rdyforcmd;
   assign llwrite = 1'b0;
   assign llwritedata = 16'h0000;
   assign lladdr = `ADDR_STATUSREG_15_0;
   assign llreq = state != state_idle;
   assign ll_isbuffer = 1'b0;
   assign busy = state != state_idle;

   always @(posedge CLK or negedge RST)
     begin
        if (!RST)
          state <= state_idle;
        else
          case (state)
            state_idle:
              if (start)
                state <= state_rdyforcmd;

            state_rdyforcmd:
              state <= state_wait_rdyforcmd;

            state_wait_rdyforcmd:
              if (llavail && llreaddata[8])
                state <= state_idle;
              else if (llavail)
                state <= state_rdyforcmd;
            default:
              ;
          endcase // case (state)
     end
endmodule // check_if_ready_for_command

module read_sector_data   
  (input CLK,
   input         RST,

   input         start,
   output        llread,
   output        llwrite,
   output [15:0] llwritedata,
   input [15:0]  llreaddata, 
   output [6:0]  lladdr,
   input         llavail,
   input         llbusy,
   output        llreq,
   output        ll_isbuffer,

   output        start_get_lock,
   input         busy_get_lock,

   output        start_check_if_ready_for_command,
   input         busy_check_if_ready_for_command,

   output        start_read_data_buffer,
   input         busy_read_data_buffer, 

   output        busy,

   input [27:0]  mpulba,
   input [7:0]   nsectors
   );

`define W 14
   reg [`W-1:0]  state;

//   parameter   state_wait_initial                    = `W'b1_0000_0000_0000;
   parameter   state_idle                            = `W'b00_0000_0000_0000;
   parameter   state_get_lock                        = `W'b00_0000_0000_0001;
   parameter   state_wait_busy_get_lock              = `W'b00_0000_0000_0010;
   parameter   state_check_if_ready_for_command      = `W'b00_0000_0000_0100;
   parameter   state_wait_check_if_ready_for_command = `W'b00_0000_0000_1000;
   parameter   state_set_mpu_lba_15_0                = `W'b00_0000_0001_0000;
   parameter   state_set_mpu_lba_27_16               = `W'b00_0000_0010_0000;
   parameter   state_set_sector_control              = `W'b00_0000_0100_0000;
   parameter   state_set_reset                       = `W'b00_0000_1000_0000;
   parameter   state_read_buffer                     = `W'b00_0001_0000_0000;
   parameter   state_wait_read_buffer                = `W'b00_0010_0000_0000;
   parameter   state_clear_config_reset              = `W'b00_0100_0000_0000;
   parameter   state_initial                         = `W'b00_1000_0000_0000;
   parameter   state_readback_init                   = `W'b01_0000_0000_0000;
   parameter   state_wait_readback_init              = `W'b10_0000_0000_0000;
`undef W

   parameter cmd_ResetMemCard     = 3'h1;
   parameter cmd_IdentifyMemCard  = 3'h2;
   parameter cmd_ReadMemCardData  = 3'h3;
   parameter cmd_WriteMemCardData = 3'h4;
   parameter cmd_Abort            = 3'h6;

   assign start_get_lock
     = state == state_get_lock;
   assign start_check_if_ready_for_command 
     = state == state_check_if_ready_for_command;
   assign start_read_data_buffer
     = state == state_read_buffer;
   assign llreq
     = state != state_idle
       && state != state_wait_readback_init
       // Other modules
       && state != state_get_lock
       && state != state_wait_busy_get_lock
       && state != state_check_if_ready_for_command
       && state != state_wait_check_if_ready_for_command
       && state != state_read_buffer
       && state != state_wait_read_buffer;
   assign llwrite 
     = llreq
       && state != state_readback_init;
   assign llread
     = state == state_readback_init;
   assign llwritedata 
     = state == state_initial ? 16'h0001 :
       state == state_set_mpu_lba_15_0 ? mpulba[15:0] :
       state == state_set_mpu_lba_27_16 ? {4'h0, mpulba[27:16]} :
       state == state_set_sector_control ? {5'd0, cmd_ReadMemCardData, nsectors} :
       state == state_set_reset ? 16'h0008 :
       state == state_clear_config_reset ?  16'h0000 :
       16'hxxxx;
   assign lladdr 
     = state == state_initial ? `ADDR_BUSMODEREG_15_0 :
       state == state_readback_init ? `ADDR_BUSMODEREG_15_0 :
       state == state_set_mpu_lba_15_0 ? `ADDR_MPULBAREG_15_0 :
       state == state_set_mpu_lba_27_16 ? `ADDR_MPULBAREG_31_16 :
       state == state_set_sector_control ? `ADDR_SECCNTCMDREG_15_0 :
       state == state_set_reset ? `ADDR_CONTROLREG_15_0 :
       state == state_clear_config_reset ? `ADDR_CONTROLREG_15_0 :
       7'hxx;
   assign ll_isbuffer = 1'b0;

   assign start_get_lock
     = state == state_get_lock;
   assign start_check_if_ready_for_command
     = state == state_check_if_ready_for_command;
   assign start_read_data_buffer
     = state == state_read_buffer;

   assign busy
     = state != state_idle;

   // assign sysace_read_data
   //   = llreaddata;
   // assign sysace_read_avail
   //   = state == state_wait_read_buffer && llavail;

   reg [7:0]     counter;

   always @(posedge CLK or negedge RST)
     begin
        if (!RST)
          state <= state_idle;
        else begin
           case (state)
             state_idle:
               if (start)
                 state <= state_initial;

             state_initial:
               if (!llbusy)
                 state <= state_readback_init;

             state_readback_init:
               if (!llbusy)
                 state <= state_wait_readback_init;

             state_wait_readback_init:
               if (llavail)
                 state <= state_get_lock;

             state_get_lock:
               state <= state_wait_busy_get_lock;

             state_wait_busy_get_lock:
               if (!busy_get_lock)
                 state <= state_check_if_ready_for_command;

             state_check_if_ready_for_command:
               state <= state_wait_check_if_ready_for_command;

             state_wait_check_if_ready_for_command:
               if (!busy_check_if_ready_for_command)
                 state <= state_set_mpu_lba_15_0;

             state_set_mpu_lba_15_0:
               if (!llbusy)
                 state <= state_set_mpu_lba_27_16;

             state_set_mpu_lba_27_16:
               if (!llbusy)
                 state <= state_set_sector_control;

             state_set_sector_control:
               if (!llbusy)
                 state <= state_set_reset;

             state_set_reset:
               if (!llbusy)
                 state <= state_read_buffer;

             state_read_buffer:
               state <= state_wait_read_buffer;

             state_wait_read_buffer:
               if (!busy_read_data_buffer) begin
                  if (counter == 8'd0)
                    state <= state_clear_config_reset;
                  else
                    state <= state_read_buffer;
               end

             state_clear_config_reset:
               if (!llbusy)
                 state <= state_idle;

           endcase
        end
     end // always @ (posedge CLK or negedge RST)

   always @(posedge CLK or negedge RST)
     begin
        if (!RST)
          counter <= 8'h00;
        else
          case (state)
            state_idle:
              counter <= nsectors;
            state_read_buffer:
              if (!busy_read_data_buffer)
                counter <= counter - 8'd1;
          endcase // case (state)
     end

endmodule // read_sector_data

module arbiter
  (input CLK,
   input         RST,

   input         req1,
   input         req2,
   input         req3,
   input         req4,
   input         req5,

   input [25:0]  data1,
   input [25:0]  data2,
   input [25:0]  data3,
   input [25:0]  data4,
   input [25:0]  data5,

   output [25:0] dataout);

   assign dataout
     = req1 ? data1 :
       req2 ? data2 :
       req3 ? data3 :
       req4 ? data4 :
       req5 ? data5 :
       26'h0;

endmodule // arbiter

module systemace
  (input CLK,                   // Up to 33MHz
   input         RST,

   output        llread,
   output        llwrite,
   output [15:0] llwritedata,
   output [6:0]  lladdr,
   input [15:0]  llreaddata,
   input         llavail,
   input         llbusy,
   output        ll_isbuffer,

   input [27:0]  mpulba,
   input [7:0]   nsectors,

   input         start,
   output        busy,

   output [15:0] sysace_read_data,
   output        sysace_read_avail
   );

   reg [27:0]    mpulba_r;
   reg [7:0]     nsectors_r;

   // --------------------------------------------------
   wire          start_wbr;
   wire          llread_wbr;
   wire          llwrite_wbr;
   wire [15:0]   llwritedata_wbr;
   wire [6:0]    lladdr_wbr;
   wire          llreq_wbr;
   wire          ll_isbuffer_wbr;

   wire [25:0]   bundle_wbr;

   wire          ready_wbr;
   wire          busy_wbr;
   
   // --------------------------------------------------
   wire          start_rdb;
   wire          llread_rdb;
   wire          llwrite_rdb;
   wire [15:0]   llwritedata_rdb;
   wire [6:0]    lladdr_rdb;
   wire          llreq_rdb;
   wire          ll_isbuffer_rdb;

   wire [25:0]   bundle_rdb;

   wire          busy_rdb;

   // --------------------------------------------------
   wire          start_gcl;
   wire          llread_gcl;
   wire          llwrite_gcl;
   wire [15:0]   llwritedata_gcl;
   wire [6:0]    lladdr_gcl;
   wire          llreq_gcl;
   wire          ll_isbuffer_gcl;

   wire [25:0]   bundle_gcl;

   wire          busy_gcl;

   // --------------------------------------------------
   wire          start_crc;
   wire          llread_crc;
   wire          llwrite_crc;
   wire [15:0]   llwritedata_crc;
   wire [6:0]    lladdr_crc;
   wire          llreq_crc;
   wire          ll_isbuffer_crc;

   wire [25:0]   bundle_crc;

   wire          busy_crc;

   // --------------------------------------------------
   wire          llread_rsd;
   wire          llwrite_rsd;
   wire [15:0]   llwritedata_rsd;
   wire [6:0]    lladdr_rsd;
   wire          llreq_rsd;
   wire          ll_isbuffer_rsd;

   wire [25:0]   bundle_rsd;

   wire [25:0]   bundle_all;

   assign bundle_wbr = {llread_wbr, llwrite_wbr, llwritedata_wbr, lladdr_wbr, ll_isbuffer_wbr};
   assign bundle_rdb = {llread_rdb, llwrite_rdb, llwritedata_rdb, lladdr_rdb, ll_isbuffer_rdb};
   assign bundle_gcl = {llread_gcl, llwrite_gcl, llwritedata_gcl, lladdr_gcl, ll_isbuffer_gcl};
   assign bundle_crc = {llread_crc, llwrite_crc, llwritedata_crc, lladdr_crc, ll_isbuffer_crc};
   assign bundle_rsd = {llread_rsd, llwrite_rsd, llwritedata_rsd, lladdr_rsd, ll_isbuffer_rsd};

   assign {llread, llwrite, llwritedata, lladdr, ll_isbuffer} = bundle_all;

   assign sysace_read_data = llreaddata;
   
   arbiter arbit
     (.CLK(CLK),
      .RST(RST),

      .req1(llreq_wbr),
      .req2(llreq_rdb),
      .req3(llreq_gcl),
      .req4(llreq_crc),
      .req5(llreq_rsd),

      .data1(bundle_wbr),
      .data2(bundle_rdb),
      .data3(bundle_gcl),
      .data4(bundle_crc),
      .data5(bundle_rsd),

      .dataout(bundle_all)
      );

   wait_for_buffer_ready wbr
     (.CLK(CLK),
      .RST(RST),
      
      .start(start_wbr),
      .llread(llread_wbr),
      .llwrite(llwrite_wbr),
      .llwritedata(llwritedata_wbr),
      .llreaddata(llreaddata),
      .lladdr(lladdr_wbr),
      .llavail(llavail),
      .llbusy(llbusy),
      .llreq(llreq_wbr),
      .ll_isbuffer(ll_isbuffer_wbr),

      .ready(ready_wbr),
      .busy(busy_wbr)
      );

   read_data_buffer rdb
     (.CLK(CLK),
      .RST(RST),

      .start(start_rdb),
      .llread(llread_rdb),
      .llwrite(llwrite_rdb),
      .llwritedata(llwritedata_rdb),
      .llreaddata(llreaddata),
      .lladdr(lladdr_rdb),
      .llavail(llavail),
      .llbusy(llbusy),
      .llreq(llreq_rdb),
      .ll_isbuffer(ll_isbuffer_rdb),

      .start_buffer_ready(start_wbr),
      .buffer_ready(ready_wbr),
      .buffer_ready_busy(busy_wbr),

      .sysace_read_avail(sysace_read_avail),

      .busy(busy_rdb)
      );

   get_cf_lock gcl
     (.CLK(CLK),
      .RST(RST),

      .start(start_gcl),
      .llread(llread_gcl),
      .llwrite(llwrite_gcl),
      .llwritedata(llwritedata_gcl),
      .llreaddata(llreaddata),
      .lladdr(lladdr_gcl),
      .llavail(llavail),
      .llbusy(llbusy),
      .llreq(llreq_gcl),
      .ll_isbuffer(ll_isbuffer_gcl),

      .busy(busy_gcl)
      );

   check_if_ready_for_command crc
     (.CLK(CLK),
      .RST(RST),

      .start(start_crc),
      .llread(llread_crc),
      .llwrite(llwrite_crc),
      .llwritedata(llwritedata_crc),
      .llreaddata(llreaddata),
      .lladdr(lladdr_crc),
      .llavail(llavail),
      .llbusy(llbusy),
      .llreq(llreq_crc),
      .ll_isbuffer(ll_isbuffer_crc),

      .busy(busy_crc)
      );

   read_sector_data rsd
     (.CLK(CLK),
      .RST(RST),

      .start(start),
      .llread(llread_rsd),
      .llwrite(llwrite_rsd),
      .llwritedata(llwritedata_rsd),
      .llreaddata(llreaddata),
      .lladdr(lladdr_rsd),
      .llavail(llavail),
      .llbusy(llbusy),
      .llreq(llreq_rsd),
      .ll_isbuffer(ll_isbuffer_rsd),

      .mpulba(mpulba),
      .nsectors(nsectors),

      .start_get_lock(start_gcl),
      .busy_get_lock(busy_gcl),

      .start_check_if_ready_for_command(start_crc),
      .busy_check_if_ready_for_command(busy_crc),

      .start_read_data_buffer(start_rdb),
      .busy_read_data_buffer(busy_rdb),

      .busy(busy)
      );

   always @(posedge CLK or negedge RST)
     begin
        if (!RST) begin
           mpulba_r <= 28'h0;
           nsectors_r <= 8'h0;
        end else begin
           if (!busy) begin
              mpulba_r <= mpulba;
              nsectors_r <= nsectors;
           end
        end
     end

endmodule // systemace
