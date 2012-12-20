
#include <iostream>
#include <vector>
#include <iomanip>
#include "Vdatop.h"

class testbench
{
    int index;
    int time;

    vector<int> testin[4];

    int eindex;

    vector<int> da1;
    vector<int> da2;

public:
    testbench();
    void set_input(Vdatop *top);
    void verify_output(Vdatop *top);
};

int main(int argc, char *argv[])
{
    Vdatop *top = new Vdatop();
    testbench tb;
    Verilated::commandArgs(argc, argv);

    top->CLK = 0;
    top->RST = 1;

    top->empty = 1;
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
            tb.verify_output(top);
        }
    }

    top->final();

    return 0;
}

testbench::testbench()
{
    int ntests = 100;
    time = 0;
    for (int i=0; i<ntests; i++) {
        for (int j=0; j<4; j++) {
            testin[j].push_back(random());
        }
    }

    for (int i=0; i<ntests; i++) {
        int a;
        int p3 = 6;
        int p1 = 2;
        int m1 = -2;
        int m3 = -6;
        int nsym = 2;

        for (int k=0; k<4; k++) {
            a = testin[k][i];
            for (int j=0; j<nsym; j++) {
                da1.push_back((a & 0xff) >> 2);
                a >>= 8;
                da2.push_back((a & 0xff) >> 2);
                a >>= 8;
            }
        }
    }
    index = 0;
    eindex = 0;
}

void testbench::set_input(Vdatop *top)
{
    // top->ce = random() & 1;
    // top->empty |= (random() % 200 > 198);
    time++;
    if (time > 10)
        top->empty = 0;

    if (!top->empty) {
        top->din[0] = testin[0][index];
        top->din[1] = testin[1][index];
        top->din[2] = testin[2][index];
        top->din[3] = testin[3][index];
    }
}

void testbench::verify_output(Vdatop *top)
{
    cout << std::dec
         << index << "\t"
         << eindex << "\t"
         // << (int)top->ce << "\t" 
         << (int)top->empty << "\t" 
         << std::hex
         << top->din[0] << "\t"
         << top->din[1] << "\t"
         << top->din[2] << "\t"
         << top->din[3] << "\t"
         << (int)top->da1 << "\t"
         << (int)top->da2 << "\t"
         // << top->v__DOT__d[0] << "\t" 
         // << top->v__DOT__d[1] << "\t" 
        // << top->v__DOT__d[2] << "\t" 
        // << top->v__DOT__d[3] << "\t" 
         << dec
         << (int)top->rd_en << "\t" 
         << (int)top->da_valid << "\n"
         << hex;
    if (top->da_valid) {
        if (top->da1 != da1[eindex]) {
            cout << "xr expected " << da1[eindex] << ", got " << (int)top->da1 << "\n";
            exit(EXIT_FAILURE);
        }
        if (top->da2 != da2[eindex]) {
            cout << "xi expected " << da2[eindex] << ", got " << (int)top->da2 << "\n";
            exit(EXIT_FAILURE);
        }

        eindex++;
        if (eindex >= da1.size()) {
            cout << "OK" << endl;
            exit(EXIT_SUCCESS);
        }
    }
    if (top->rd_en) {
        top->empty = 0;
        cout << "renew\n";
        index++;
    }
}
