
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#include <inttypes.h>
#include "raweth.h"

const uint8_t my_dest_addr[] = {0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF};
const int num_capacity = 1488;

int64_t send_file(int sockfd, const char *ethname, const char *filename)
{
    FILE* file;
    struct sysele sysele;
    uint8_t *src_addr;
    int64_t sum_sent;
    int ifindex;

    if ((file = fopen(filename, "r")) == NULL) {
        perror("fopen");
        exit(EXIT_FAILURE);
    }

    ifindex = get_if_index(sockfd, ethname);
    src_addr = get_mac_addr(sockfd, ethname);

    sysele = alloc_sysele(num_capacity);
    *(sysele.header) = mk_ether_header(src_addr, my_dest_addr, 0x0060);
    *(sysele.counter) = 0;
    sysele.sockaddr = mk_sockaddr(ifindex, my_dest_addr);
    sum_sent = 0;

    while (!feof(file)) {
        int64_t s;
        sysele.data_size = fread(sysele.data_array, 1, sysele.size - 0x10, file);
        if ((s = sysele_send(&sysele, sockfd)) < 0) {
            perror("sendto");
            exit(EXIT_FAILURE);
        }
        sum_sent += s;
    }
    return sum_sent;
}

int main(int __attribute__((unused)) argc, char __attribute__((unused)) **argv)
{
    int sockfd;
    const char *ethname = "eth1";
    ssize_t sent;

    if ((sockfd = socket(AF_PACKET, SOCK_RAW, IPPROTO_RAW)) < 0) {
        perror("socket");
        exit(EXIT_FAILURE);
    }

    sent = send_file(sockfd, ethname, "test.dat");
    printf("sent 0x%08lx bytes\n", sent);

    return 0;
}
