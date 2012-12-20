
#include <iostream>
#include <vector>
#include <iomanip>
#include "Vsimtop.h"

class testbench
{
    int index;

    vector<int> testin[4];

    int eindex;

    int rindex;
    vector<int> rawout;

public:
    testbench();
    void set_input(Vsimtop *top);
    void verify_output(Vsimtop *top);
};

int main(int argc, char *argv[])
{
    Vsimtop *top = new Vsimtop();
    testbench tb;
    Verilated::commandArgs(argc, argv);

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
            tb.verify_output(top);
        }
    }

    top->final();

    return 0;
}

testbench::testbench()
{
    int ntests = 100;

    for (int i=0; i<ntests; i++) {
        for (int j=0; j<4; j++) {
            testin[j].push_back(random());
        }
    }
    for (int i=0; i<ntests; i++) {
        for (int j=0; j<4; j++) {
            int a = testin[j][i];
            for (int k=0; k<16; k++) {
                rawout.push_back(a & 3);
                a >>= 2;
            }
        }
    }
    index = 0;
    eindex = 0;
    rindex = 0;
}

void testbench::set_input(Vsimtop *top)
{
    top->ce = random() & 1;
    top->valid_i |= (random() % 200 > 198);

    if (top->ce) {
        if (top->valid_i) {
            top->reader_data[0] = testin[0][index];
            top->reader_data[1] = testin[1][index];
            top->reader_data[2] = testin[2][index];
            top->reader_data[3] = testin[3][index];
        }
    }
}

void testbench::verify_output(Vsimtop *top)
{
    if (!top->ce) {
        if (top->reader_en) {
            cout << "reader_en asserted when !ce\n";
            exit(EXIT_FAILURE);
        }
    }

    if (top->ce) {
        int ar1 = top->v__DOT__ar1;
        if (ar1 > 1024)
            ar1 -= 2048;
        cout << std::dec
             << index << "\t"
             << eindex << "\t"
             << (int)top->ce << "\t" 
             << (int)top->valid_i << "\t" 
             << std::hex
             << top->reader_data[0] << "\t"
             << top->reader_data[1] << "\t"
             << top->reader_data[2] << "\t"
             << top->reader_data[3] << "\t"
             << std::hex
             << top->writer_data[0] << "\t"
             << top->writer_data[1] << "\t"
             << top->writer_data[2] << "\t"
             << top->writer_data[3] << "\t"
             << dec
             << ar1 << "\t"
             << (int)top->reader_en << "\t" 
             << (int)top->valid_o << "\n";
        if (top->valid_o) {
            if (!(testin[0][eindex] == top->writer_data[0] &&
                  testin[1][eindex] == top->writer_data[1] &&
                  testin[2][eindex] == top->writer_data[2] &&
                  testin[3][eindex] == top->writer_data[3])) {
                cout << "ERROR\n";
                exit(EXIT_FAILURE);
            }
            eindex++;
            if (eindex >= testin[0].size()) {
                cout << "OK" << endl;
                exit(EXIT_SUCCESS);
            }
        }
        if (top->valid_raw) {
            if (top->raw != rawout[rindex]) {
                cout << "raw error\n";
                exit(EXIT_FAILURE);
            }
            rindex++;
        }
    }
    if (top->reader_en) {
        top->valid_i = 0;
        cout << "renew\n";
        index++;
    }
}
