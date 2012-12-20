#!/bin/sh

set -e

verilogs='../../../rtl/datop.v'

verilator -Mdir test -cc ${verilogs} --exe datop.cpp
make -C test -f Vdatop.mk Vdatop
./test/Vdatop

