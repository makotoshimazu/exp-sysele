#!/bin/sh

set -e

verilogs='../../../rtl/comm/iqmap_16qam.v'

verilator -Mdir test -cc ${verilogs} --exe iqmap_16qam.cpp
make -C test -f Viqmap_16qam.mk Viqmap_16qam
./test/Viqmap_16qam

