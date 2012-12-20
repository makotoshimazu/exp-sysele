#!/bin/sh

set -e

verilogs='../../../rtl/comm/rescale.v'

verilator -Mdir test -cc ${verilogs} --exe rescale.cpp
make -C test -f Vrescale.mk Vrescale
./test/Vrescale

