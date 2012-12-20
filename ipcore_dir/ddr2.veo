//*****************************************************************************
// DISCLAIMER OF LIABILITY
//
// This file contains proprietary and confidential information of
// Xilinx, Inc. ("Xilinx"), that is distributed under a license
// from Xilinx, and may be used, copied and/or disclosed only
// pursuant to the terms of a valid license agreement with Xilinx.
//
// XILINX IS PROVIDING THIS DESIGN, CODE, OR INFORMATION
// ("MATERIALS") "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
// EXPRESSED, IMPLIED, OR STATUTORY, INCLUDING WITHOUT
// LIMITATION, ANY WARRANTY WITH RESPECT TO NONINFRINGEMENT,
// MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE. Xilinx
// does not warrant that functions included in the Materials will
// meet the requirements of Licensee, or that the operation of the
// Materials will be uninterrupted or error-free, or that defects
// in the Materials will be corrected. Furthermore, Xilinx does
// not warrant or make any representations regarding use, or the
// results of the use, of the Materials in terms of correctness,
// accuracy, reliability or otherwise.
//
// Xilinx products are not designed or intended to be fail-safe,
// or for use in any application requiring fail-safe performance,
// such as life-support or safety devices or systems, Class III
// medical devices, nuclear facilities, applications related to
// the deployment of airbags, or any other applications that could
// lead to death, personal injury or severe property or
// environmental damage (individually and collectively, "critical
// applications"). Customer assumes the sole risk and liability
// of any use of Xilinx products in critical applications,
// subject only to applicable laws and regulations governing
// limitations on product liability.
//
// Copyright 2007, 2008 Xilinx, Inc.
// All rights reserved.
//
// This disclaimer and copyright notice must be retained as part
// of this file at all times.
//*****************************************************************************
//   ____  ____
//  /   /\/   /
// /___/  \  /   Vendor             : Xilinx
// \   \   \/    Version            : 3.3
//  \   \        Application        : MIG
//  /   /        Filename           : ddr2.veo
// /___/   /\    Date Last Modified : $Date: 2009/08/17 16:10:43 $
// \   \  /  \   Date Created       : Wed May 2 2007
//  \___\/\___\
//
// Purpose     : Template file containing code that can be used as a model
//               for instantiating a CORE Generator module in a HDL design.
// Revision History:
//*****************************************************************************

// The following must be inserted into your Verilog file for this
// core to be instantiated. Change the instance name and port connections
// (in parentheses) to your own signal names.

//----------- Begin Cut here for INSTANTIATION Template ---// INST_TAG

 ddr2 # (
    .BANK_WIDTH(2),   
                                       // # of memory bank addr bits.
    .CKE_WIDTH(1),   
                                       // # of memory clock enable outputs.
    .CLK_WIDTH(2),   
                                       // # of clock outputs.
    .COL_WIDTH(10),   
                                       // # of memory column bits.
    .CS_NUM(1),   
                                       // # of separate memory chip selects.
    .CS_WIDTH(1),   
                                       // # of total memory chip selects.
    .CS_BITS(0),   
                                       // set to log2(CS_NUM) (rounded up).
    .DM_WIDTH(8),   
                                       // # of data mask bits.
    .DQ_WIDTH(64),   
                                       // # of data width.
    .DQ_PER_DQS(8),   
                                       // # of DQ data bits per strobe.
    .DQS_WIDTH(8),   
                                       // # of DQS strobes.
    .DQ_BITS(6),   
                                       // set to log2(DQS_WIDTH*DQ_PER_DQS).
    .DQS_BITS(3),   
                                       // set to log2(DQS_WIDTH).
    .ODT_WIDTH(1),   
                                       // # of memory on-die term enables.
    .ROW_WIDTH(13),   
                                       // # of memory row and # of addr bits.
    .ADDITIVE_LAT(0),   
                                       // additive write latency.
    .BURST_LEN(4),   
                                       // burst length (in double words).
    .BURST_TYPE(0),   
                                       // burst type (=0 seq; =1 interleaved).
    .CAS_LAT(4),   
                                       // CAS latency.
    .ECC_ENABLE(0),   
                                       // enable ECC (=1 enable).
    .APPDATA_WIDTH(128),   
                                       // # of usr read/write data bus bits.
    .MULTI_BANK_EN(1),   
                                       // Keeps multiple banks open. (= 1 enable).
    .TWO_T_TIME_EN(1),   
                                       // 2t timing for unbuffered dimms.
    .ODT_TYPE(1),   
                                       // ODT (=0(none),=1(75),=2(150),=3(50)).
    .REDUCE_DRV(0),   
                                       // reduced strength mem I/O (=1 yes).
    .REG_ENABLE(0),   
                                       // registered addr/ctrl (=1 yes).
    .TREFI_NS(7800),   
                                       // auto refresh interval (ns).
    .TRAS(40000),   
                                       // active->precharge delay.
    .TRCD(15000),   
                                       // active->read/write delay.
    .TRFC(105000),   
                                       // refresh->refresh, refresh->active delay.
    .TRP(15000),   
                                       // precharge->command delay.
    .TRTP(7500),   
                                       // read->precharge delay.
    .TWR(15000),   
                                       // used to determine write->precharge.
    .TWTR(7500),   
                                       // write->read delay.
    .HIGH_PERFORMANCE_MODE("TRUE"),   
                              // # = TRUE, the IODELAY performance mode is set
                              // to high.
                              // # = FALSE, the IODELAY performance mode is set
                              // to low.
    .SIM_ONLY(0),   
                                       // = 1 to skip SDRAM power up delay.
    .DEBUG_EN(0),   
                                       // Enable debug signals/controls.
                                       // When this parameter is changed from 0 to 1,
                                       // make sure to uncomment the coregen commands
                                       // in ise_flow.bat or create_ise.bat files in
                                       // par folder.
    .CLK_PERIOD(3750),   
                                       // Core/Memory clock period (in ps).
    .RST_ACT_LOW(1)     
                                       // =1 for active low reset, =0 for active high.
)
u_ddr2 (
    .ddr2_dq                   (ddr2_dq),
    .ddr2_a                    (ddr2_a),
    .ddr2_ba                   (ddr2_ba),
    .ddr2_ras_n                (ddr2_ras_n),
    .ddr2_cas_n                (ddr2_cas_n),
    .ddr2_we_n                 (ddr2_we_n),
    .ddr2_cs_n                 (ddr2_cs_n),
    .ddr2_odt                  (ddr2_odt),
    .ddr2_cke                  (ddr2_cke),
    .ddr2_dm                   (ddr2_dm),
    .sys_rst_n                 (sys_rst_n),
    .phy_init_done             (phy_init_done),
    .locked                    (locked),
    .rst0_tb                   (rst0_tb),
    .clk0                      (clk0),
    .clk0_tb                   (clk0_tb),
    .clk90                     (clk90),
    .clkdiv0                   (clkdiv0),
    .clk200                    (clk200),
    .app_wdf_afull             (app_wdf_afull),
    .app_af_afull              (app_af_afull),
    .rd_data_valid             (rd_data_valid),
    .app_wdf_wren              (app_wdf_wren),
    .app_af_wren               (app_af_wren),
    .app_af_addr               (app_af_addr),
    .app_af_cmd                (app_af_cmd),
    .rd_data_fifo_out          (rd_data_fifo_out),
    .app_wdf_data              (app_wdf_data),
    .app_wdf_mask_data         (app_wdf_mask_data),
    .ddr2_dqs                  (ddr2_dqs),
    .ddr2_dqs_n                (ddr2_dqs_n),
    .ddr2_ck                   (ddr2_ck),
    .ddr2_ck_n                 (ddr2_ck_n)
);

// INST_TAG_END ------ End INSTANTIATION Template ---------

// You must compile the wrapper file ddr2.v when simulating
// the core, ddr2. When compiling the wrapper file, be sure to
// reference the XilinxCoreLib Verilog simulation library. For detailed
// instructions, please refer to the "CORE Generator Help".

