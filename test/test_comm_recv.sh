#!/bin/sh

romfiles=$(ls ../rtl/comm/fftgen/twiddle_rom_*.v | grep -v '_b\.v')
twiddles=$(ls ../rtl/comm/fftgen/twiddle*.v)

ncverilog +gui +ncaccess+rwc test_comm_recv.v ../rtl/comm/{comm_recv.v,iqdemap_bpsk.v,fftfifo.v,rescale.v} \
../rtl/comm/fft/{fft64_top_w_fifo.v,fft64_top.v,fft64.v,fft32.v,fft16.v,delay.v,cross_switch.v,twiddle4.v,butterfly2.v,fifo_2w1r_fwft.v,interlace.v,fft_reorder.v} \
${twiddles} \
${romfiles} \
../rtl/comm/compmult/compmult.v \
../ipcore_dir/fft_feed_fifo.v \
-y ${XILINX}/verilog/src/unisims -y ${XILINX}/verilog/src/XilinxCoreLib +incdir+${XILINX}/verilog/src \
 +libext+.v
