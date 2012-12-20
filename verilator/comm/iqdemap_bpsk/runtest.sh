#!/bin/sh

set -e

verilogs='simtop.v ../../../rtl/comm/iqmap_bpsk.v ../../../rtl/comm/iqdemap_bpsk.v'

verilator -Mdir test -cc ${verilogs} --exe iqdemap_bpsk.cpp
make -C test -f Vsimtop.mk Vsimtop
./test/Vsimtop

