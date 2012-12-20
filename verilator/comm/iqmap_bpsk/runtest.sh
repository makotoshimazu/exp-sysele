#!/bin/sh

set -e

verilogs='../../../rtl/comm/iqmap_bpsk.v'

verilator -Mdir test -cc ${verilogs} --exe iqmap_bpsk.cpp
make -C test -f Viqmap_bpsk.mk Viqmap_bpsk
./test/Viqmap_bpsk

