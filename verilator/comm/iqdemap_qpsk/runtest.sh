#!/bin/sh

set -e

verilogs='simtop.v ../../../rtl/comm/iqmap_qpsk.v ../../../rtl/comm/iqdemap_qpsk.v'

verilator -Mdir test -cc ${verilogs} --exe iqdemap_qpsk.cpp
make -C test -f Vsimtop.mk Vsimtop
./test/Vsimtop

