#!/bin/sh

set -e

verilogs='../../../rtl/comm/iqmap_qpsk.v'

verilator -Mdir test -cc ${verilogs} --exe iqmap_qpsk.cpp
make -C test -f Viqmap_qpsk.mk Viqmap_qpsk
./test/Viqmap_qpsk

