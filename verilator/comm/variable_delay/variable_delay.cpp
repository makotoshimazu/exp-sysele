
#include <iostream>
#include <deque>
#include <iomanip>
#include "Vvariable_delay.h"

using namespace std;


class testbench
{
    int delay;
    deque<int> values;
    int count;

public:

    testbench(int delay);
    void set_input(Vvariable_delay *top);
    bool verify_output(Vvariable_delay *top);
};

int main(int argc, char *argv[])
{
    Vvariable_delay *top = new Vvariable_delay();
    Verilated::commandArgs(argc-1, argv+1);

    for (int delay = 24; delay < 40; delay++) {
        testbench tb(delay);
        cout << "-------------------------------------------------\n"
             << "delay = " << delay << "\n";
        top->CLK = 0;
        top->RST = 1;

        top->CLK = 0;
        // reset
        top->RST = 1;
        top->eval();
        top->RST = 0;
        top->eval();
        top->RST = 1;
        top->eval();
        top->sel = delay - 24;

        while (!Verilated::gotFinish()) {
            if (top->CLK) {
                tb.set_input(top);
            }

            top->CLK = !top->CLK;
            top->eval();

            if (!top->CLK) {
                if (!tb.verify_output(top))
                    break;
            }
        }

        top->final();
    }

    return 0;
}

testbench::testbench(int delay_)
    : delay(delay_), count(0)
{

}

void testbench::set_input(Vvariable_delay *top)
{
    top->ce = random() & 1;
    
    if (top->ce) {
        top->din = random();
        values.push_back(top->din);
    }
}

bool testbench::verify_output(Vvariable_delay *top)
{

    if (top->ce) {
        cout << std::dec
             << count << "\t"
             << (int)top->ce << "\t"
             << (int)top->sel << "\t"
             << (int)top->din << "\t"
             << (int)top->dout << "\t"
             << (int)top->v__DOT__dl[39] << "\t"
             << "\n";

        if (values.size() > delay) {
            int e = values[0];
            values.pop_front();
            if (e != top->dout) {
                cout << "expected" << e << ", got " << (int)(top->dout) << endl;
                exit(EXIT_FAILURE);
            }
        }
        count++;
        if (count >= 1024) {
            return false;
        }
        return true;
    }
    return true;
}
