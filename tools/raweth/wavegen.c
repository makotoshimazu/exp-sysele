
#include <stdio.h>
#include <stdlib.h>
#include <inttypes.h>

#include <math.h>

int main(int argc, char **argv)
{
    uint8_t val1, val2;
    int i;
    FILE *file;

    file = fopen("wave.dat", "w");
    for (i=0; i<128*1024*1024; i++) {
        val1 = 127 * sin(2*M_PI*i/240) + 128;
        val2 = 127 * cos(2*M_PI*i/240) + 128;
        fwrite(&val1, 1, 1, file);
        fwrite(&val2, 1, 1, file);
    }

    fclose(file);

    return 0;
}
