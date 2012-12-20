
#include <iostream>
#include <vector>
#include <iomanip>
#include "Viqmap_16qam.h"

class testbench
{
    int index;

    vector<int> testin[4];

    int eindex;

    vector<int> expected_out_r;
    vector<int> expected_out_i;

    int rindex;
    vector<int> rawout;

public:
    testbench();
    void set_input(Viqmap_16qam *top);
    void verify_output(Viqmap_16qam *top);
};

int main(int argc, char *argv[])
{
    Viqmap_16qam *top = new Viqmap_16qam();
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
        int a;
        int p3 = 6;
        int p1 = 2;
        int m1 = -2;
        int m3 = -6;
        int nsym = 8;

        for (int k=0; k<4; k++) {
            a = testin[k][i];
            for (int j=0; j<nsym; j++) {
                rawout.push_back(a&0x0f);
                switch (a & 0xf) {
                case 0:
                    expected_out_r.push_back(m1);
                    expected_out_i.push_back(m1);
                    break;

                case 1:
                    expected_out_r.push_back(m1);
                    expected_out_i.push_back(m3);
                    break;

                case 2:
                    expected_out_r.push_back(m3);
                    expected_out_i.push_back(m1);
                    break;

                case 3:
                    expected_out_r.push_back(m3);
                    expected_out_i.push_back(m3);
                    break;

                case 4:
                    expected_out_r.push_back(m1);
                    expected_out_i.push_back(p1);
                    break;

                case 5:
                    expected_out_r.push_back(m1);
                    expected_out_i.push_back(p3);
                    break;

                case 6:
                    expected_out_r.push_back(m3);
                    expected_out_i.push_back(p1);
                    break;

                case 7:
                    expected_out_r.push_back(m3);
                    expected_out_i.push_back(p3);
                    break;

                case 8:
                    expected_out_r.push_back(p1);
                    expected_out_i.push_back(m1);
                    break;

                case 9:
                    expected_out_r.push_back(p1);
                    expected_out_i.push_back(m3);
                    break;

                case 10:
                    expected_out_r.push_back(p3);
                    expected_out_i.push_back(m1);
                    break;

                case 11:
                    expected_out_r.push_back(p3);
                    expected_out_i.push_back(m3);
                    break;

                case 12:
                    expected_out_r.push_back(p1);
                    expected_out_i.push_back(p1);
                    break;

                case 13:
                    expected_out_r.push_back(p1);
                    expected_out_i.push_back(p3);
                    break;

                case 14:
                    expected_out_r.push_back(p3);
                    expected_out_i.push_back(p1);
                    break;

                case 15:
                    expected_out_r.push_back(p3);
                    expected_out_i.push_back(p3);
                    break;
                }

                a >>= 4;
            }
        }
    }
    index = 0;
    eindex = 0;
    rindex = 0;
}

void testbench::set_input(Viqmap_16qam *top)
{
    // top->ce = random() & 1;
    // top->valid_i |= (random() % 200 > 198);
    top->ce = 1;
    top->valid_i = 1;

    if (top->ce) {
        if (top->valid_i) {
            top->reader_data[0] = testin[0][index];
            top->reader_data[1] = testin[1][index];
            top->reader_data[2] = testin[2][index];
            top->reader_data[3] = testin[3][index];
        }
    }
}

void testbench::verify_output(Viqmap_16qam *top)
{
    int txr = top->xr;
    int txi = top->xi;
    if (txr > 1024)
        txr -= 2048;
    if (txi > 1024)
        txi -= 2048;

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
             << txi << "\t"
             << (int)top->valid_o << "\n";
        if (top->valid_o) {
            if (txr != expected_out_r[eindex]) {
                cout << "xr expected " << expected_out_r[eindex] << ", got " << txr << "\n";
                exit(EXIT_FAILURE);
            }
            if (txi != expected_out_i[eindex]) {
                cout << "xi expected " << expected_out_i[eindex] << ", got " << txi << "\n";
                exit(EXIT_FAILURE);
            }

            eindex++;
            if (eindex >= expected_out_r.size()) {
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
