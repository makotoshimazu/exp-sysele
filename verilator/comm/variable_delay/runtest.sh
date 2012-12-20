#!/bin/sh

set -e

verilogs='../../../rtl/comm/variable_delay.v'

verilator -Mdir test -cc ${verilogs} --exe variable_delay.cpp
make -C test -f Vvariable_delay.mk Vvariable_delay
./test/Vvariable_delay

