
#include <iostream>
#include <vector>
#include <deque>
#include <iomanip>
#include "Vrescale.h"

using namespace std;


class testbench
{
    static const int delay = 1;
    deque<int> values1;
    deque<int> values2;
    int count;

public:
    testbench();
    void set_input(Vrescale *top);
    bool verify_output(Vrescale *top);
};

int main(int argc, char *argv[])
{
    Vrescale *top = new Vrescale();
    Verilated::commandArgs(argc-1, argv+1);

    testbench tb;

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

    return 0;
}

testbench::testbench()
    : count(0)
{

}

void testbench::set_input(Vrescale *top)
{
    top->ad1i = random() % 128 + 128;
    top->ad2i = random() % 128 + 128;

    int v1 = (unsigned int)top->ad1i;
    int v2 = (unsigned int)top->ad2i;

    int e1 = ((v1 - 128) * 16 - 1024) >> 6;
    int e2 = ((v2 - 128) * 16 - 1024) >> 6;
        
    values1.push_back(e1);
    values2.push_back(e2);
}

bool testbench::verify_output(Vrescale *top)
{
    int e1 = values1[0];
    values1.pop_front();
    int e2 = values2[0];
    values2.pop_front();

    int ad1o = top->ad1o;
    int ad2o = top->ad2o;
    if (ad1o >= 1024)
        ad1o -= 1024;
    if (ad2o >= 1024)
        ad2o -= 1024;

    cout << std::dec
         << count << "\t"
         << (int)top->ad1i << "\t"
         << (int)top->ad2i << "\t"
         << ad1o << "\t"
         << ad2o << "\t"
         << "\n";

    if (values1.size() > delay) {

        if (e1 != ad1o) {
            cout << "expected" << values1[0] << ", got " << ad1o << endl;
            exit(EXIT_FAILURE);
        }
        if (e2 != ad2o) {
            cout << "expected" << e2 << ", got " << ad2o << endl;
            exit(EXIT_FAILURE);
        }
    }
    count++;
    if (count >= 1024) {
        cout << "OK" << endl;
        return false;
    }
    return true;
}
