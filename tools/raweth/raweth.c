
#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <errno.h>

#include "raweth.h"

int get_if_index(int sockfd, const char *ethname)
{
    struct ifreq ifreq;

    memset(&ifreq, 0, sizeof(struct ifreq));
    strcpy(ifreq.ifr_name, ethname);
    if (ioctl(sockfd, SIOCGIFINDEX, &ifreq) < 0) {
        fprintf(stderr, "SIOCGIFINDEX: %s: %s\n", ethname, strerror(errno));
        exit(EXIT_FAILURE);
    }

    return ifreq.ifr_ifindex;
}

uint8_t *get_mac_addr(int sockfd, const char *ethname)
{
    struct ifreq ifreq;
    uint8_t *addr;

    memset(&ifreq, 0, sizeof(struct ifreq));
    strcpy(ifreq.ifr_name, ethname);
    if (ioctl(sockfd, SIOCGIFHWADDR, &ifreq) < 0) {
        perror("SIOCGIFHWADDR");
        exit(EXIT_FAILURE);
    }

    addr = malloc(6);
    memcpy(addr, (uint8_t*)ifreq.ifr_hwaddr.sa_data, 6);

    return addr;
}

struct sockaddr_ll mk_sockaddr(int ifindex, 
                               const uint8_t *dest_addr)
{
    struct sockaddr_ll s;

    s.sll_family = AF_PACKET;
    memcpy(s.sll_addr, dest_addr, 6);
    s.sll_halen = ETH_ALEN;
    s.sll_ifindex = ifindex;

    return s;
}

struct ether_header mk_ether_header(const uint8_t *src_addr, const uint8_t *dest_addr, uint16_t type)
{
    struct ether_header h;

    memcpy(h.ether_dhost, dest_addr, 6);
    memcpy(h.ether_shost, src_addr, 6);
    h.ether_type = type;

    return h;
}

struct sysele alloc_sysele(size_t data_size)
{
    struct sysele r;
    void *buf;

    r.size = sizeof(struct ether_header) + sizeof(uint16_t) + data_size;
    buf = malloc(r.size);
    r.header = (struct ether_header*)buf;
    r.counter = (uint16_t *)(buf + sizeof(struct ether_header));
    r.data_array = (uint8_t *)(buf + sizeof(struct ether_header) + sizeof(uint16_t));
    r.data_size = 0;
    return r;
}

struct sysele tpacket_sysele(struct tpacket_hdr *h)
{
    struct sysele s;
    void *addr;

    addr = (void *)h;
    addr += TPACKET_ALIGN(sizeof(struct tpacket_hdr))
        + TPACKET_ALIGN(sizeof(struct sockaddr_ll));
    addr += 2;                  /* ? */

    s.header = (struct ether_header *)addr;
    s.counter = (uint16_t *)(addr + sizeof(struct ether_header));
    s.data_array = (uint8_t *)(addr + sizeof(struct ether_header) + sizeof(uint16_t));
    s.size = h->tp_len;
    s.data_size = h->tp_len - sizeof(uint16_t);
    s.socklen = sizeof(struct sockaddr_ll);
    s.sockaddr = *(struct sockaddr_ll *)(addr + TPACKET_ALIGN(sizeof(*h)));

    return s;
}

void print_sysele(const struct sysele *s)
{
    int i, j, k;
    uint8_t *ptr;

    printf("dest=%02X:%02X:%02X:%02X:%02X:%02X, src=%02X:%02X:%02X:%02X:%02X:%02X\n"
           "counter=%d\n",
           s->header->ether_dhost[0],
           s->header->ether_dhost[1],
           s->header->ether_dhost[2],
           s->header->ether_dhost[3],
           s->header->ether_dhost[4],
           s->header->ether_dhost[5],
           s->header->ether_shost[0],
           s->header->ether_shost[1],
           s->header->ether_shost[2],
           s->header->ether_shost[3],
           s->header->ether_shost[4],
           s->header->ether_shost[5],
           *s->counter);

    
    ptr = s->data_array;
    for (k=0; k<3; k++) {
        for (i=0; i<2; i++) {
            for (j=0; j<8; j++) {
                printf("%02x ", *ptr++);
            }
            printf(" ");
        }
        printf("\n");
    }
}

ssize_t sysele_recv(struct sysele *s, int sockfd)
{
    ssize_t r;
    if ((r = recvfrom(sockfd, s->header, s->size, 0, (struct sockaddr *)&(s->sockaddr), &(s->socklen))) < 0) {
        perror("recvfrom");
        exit(EXIT_FAILURE);
    }
    s->data_size = r - sizeof(struct ether_header) - sizeof(uint16_t);
    return s->data_size;
}

ssize_t sysele_send(struct sysele *s, int sockfd)
{
    ssize_t r;
    if ((r = sendto(sockfd, s->header, s->data_size + 0x10, 0, (struct sockaddr*)&(s->sockaddr), sizeof(struct sockaddr_ll))) < 0) {
        perror("sendto");
        exit(EXIT_FAILURE);
    }
    return r - 0x10;
}
