
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#include "raweth.h"

const int num_packets = 180401;
const int num_capacity = 1500;

int main(int __attribute__((unused)) argc, char __attribute__((unused)) *argv[])
{
    int sockfd;
    int ifindex;
    uint8_t *src_addr;
    struct sysele *data;
    int i;
    ssize_t sum_recv;

    if ((sockfd = socket(PF_PACKET, SOCK_RAW, htons(ETH_P_ALL))) < 0) {
        perror("socket");
        exit(EXIT_FAILURE);
    }
    
    ifindex = get_if_index(sockfd, "eth1");
    src_addr = get_mac_addr(sockfd, "eth1");
    data = malloc(sizeof(struct sysele) * num_packets);

    for (i=0; i<num_packets; i++) {
        data[i] = alloc_sysele(num_capacity);
    }

    i = 0;
    sum_recv = 0;
    while (i < num_packets) {
        fd_set set;
        struct timeval tv;
        int r;
        ssize_t rc;

        FD_ZERO(&set);
        FD_SET(sockfd, &set);

        if (i==0)
            tv.tv_sec = 20;
        else
            tv.tv_sec = 1;
        tv.tv_usec = 0;

        r = select(sockfd+1, &set, NULL, NULL, &tv);

        if (r <= 0) {
            /* timeout */
            fprintf(stderr, "timeout\n");
            break;
        }

        rc = sysele_recv(&data[i], sockfd);

        /* check if valid */
        if (data[i].sockaddr.sll_ifindex != ifindex)
            continue;

        sum_recv += rc;
        i++;
    }

    fprintf(stderr, "received %d packets (0x%08lx bytes)\n", i, (size_t)sum_recv);

    int recv_packets = i;
    int index = *data[0].counter;
    FILE *file = fopen("out.dat", "w");

    for (i=0; i<recv_packets && data[i].data_size > 0; i++) {
        int missing = 0;
        int missing_start = index;
        int missing_end;

        while (((index & 0xffff) != *(data[i].counter)) && index < recv_packets) {
            uint8_t u = 0xff;
            int j;

            for (j=0; j<0x5d8; j++) {
                fwrite(&u, 1, 1, file);
            }

            missing = 1;
            missing_end = index;

            index++;
        }

        if (missing) {
            if (missing_start == missing_end)
                fprintf(stderr, "missing packet index=%d\n", missing_start);
            else
                fprintf(stderr, "missing packets from %d to %d\n", missing_start, missing_end);
        }
            
        fwrite(data[i].data_array, 1, data[i].data_size, file);
        
        index++;
    }
    fclose(file);

    return 0;
}
