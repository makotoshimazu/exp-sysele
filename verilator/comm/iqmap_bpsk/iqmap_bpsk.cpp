
#include <iostream>
#include <vector>
#include <iomanip>
#include "Viqmap_bpsk.h"

class testbench
{
    int index;

    vector<int> testin0;
    vector<int> testin1;
    vector<int> testin2;
    vector<int> testin3;

    int eindex;

    vector<int> expected_out;

    vector<int> rawout;

    int rindex;

public:
    testbench();
    void set_input(Viqmap_bpsk *top);
    void verify_output(Viqmap_bpsk *top);
};

int main(int argc, char *argv[])
{
    Viqmap_bpsk *top = new Viqmap_bpsk();
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
        testin0.push_back(random());
        testin1.push_back(random());
        testin2.push_back(random());
        testin3.push_back(random());
    }

    for (int i=0; i<ntests; i++) {
        int a;
        int h = 8;
        int l = -8;

        a = testin0[i];
        for (int j=0; j<32; j++) {
            rawout.push_back(a&1);
            if (a & 1) 
                expected_out.push_back(h);
            else
                expected_out.push_back(l);
            a >>= 1;
        }

        a = testin1[i];
        for (int j=0; j<32; j++) {
            rawout.push_back(a&1);
            if (a & 1)
                expected_out.push_back(h);
            else
                expected_out.push_back(l);
            a >>= 1;
        }

        a = testin2[i];
        for (int j=0; j<32; j++) {
            rawout.push_back(a&1);
            if (a & 1) 
                expected_out.push_back(h);
            else
                expected_out.push_back(l);
            a >>= 1;
        }

        a = testin3[i];
        for (int j=0; j<32; j++) {
            rawout.push_back(a&1);
            if (a & 1) 
                expected_out.push_back(h);
            else
                expected_out.push_back(l);
            a >>= 1;
        }
    }
    index = 0;
    eindex = 0;
    rindex = 0;
}

void testbench::set_input(Viqmap_bpsk *top)
{
    top->ce = random() & 1;
    top->valid_i |= (random() % 200 > 198);

    if (top->ce) {
        if (top->valid_i) {
            top->reader_data[0] = testin0[index];
            top->reader_data[1] = testin1[index];
            top->reader_data[2] = testin2[index];
            top->reader_data[3] = testin3[index];
        }
    }
}

void testbench::verify_output(Viqmap_bpsk *top)
{
    int txr = top->xr;
    if (txr > 1024)
        txr -= 2048;


    if (!top->ce) {
        if (top->reader_en) {
            cout << "reader_en asserted when !ce\n";
            exit(EXIT_FAILURE);
        }
    }

    if (top->ce) {
        cout << std::dec
             << index << "\t"
             << eindex << "\t"
             << (int)top->ce << "\t" 
             << (int)top->valid_i << "\t" 
            // << top->reader_data[0] << "\t"
            // << top->reader_data[1] << "\t"
            // << top->reader_data[2] << "\t"
            // << top->reader_data[3] << "\t"
             << std::hex
             << top->v__DOT__d[0] << "\t" 
             << top->v__DOT__d[1] << "\t" 
            // << top->v__DOT__d[2] << "\t" 
            // << top->v__DOT__d[3] << "\t" 
             << dec
             << (int)top->reader_en << "\t" 
             << txr << "\t" 
             << (int)top->valid_o << "\n";
        if (top->valid_o) {
            if (top->xi != 0) {
                cout << "xi nonzero\n";
                exit(EXIT_FAILURE);
            }
            if (txr != expected_out[eindex]) {
                cout << "xr expected " << expected_out[eindex] << ", got " << txr << "\n";
                exit(EXIT_FAILURE);
            }
            eindex++;
            if (eindex >= expected_out.size()) {
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
