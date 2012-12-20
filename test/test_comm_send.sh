#!/bin/sh

ncverilog +gui +ncaccess+rwc test_comm_send.v ../rtl/comm/{comm_send.v,iqmap_bpsk.v,fftfifo.v} \
../rtl/comm/fft/{fft64_top_w_fifo.v,fft64_top.v,fft64.v,fft32.v,fft16.v,delay.v,cross_switch.v,twiddle4.v,butterfly2.v,fifo_2w1r_fwft.v,interlace.v,fft_reorder.v} \
../rtl/comm/fftgen/{twiddle*.v,twiddle_rom_*_b.v} \
../rtl/comm/compmult/compmult.v \
../ipcore_dir/fft_feed_fifo.v \
-y ${XILINX}/verilog/src/unisims -y ${XILINX}/verilog/src/XilinxCoreLib +incdir+${XILINX}/verilog/src \
 +libext+.v
