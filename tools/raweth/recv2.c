
#include "raweth.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/epoll.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/mman.h>

int main(int __attribute__((unused)) argc, char __attribute__((unused)) *argv[])
{
    int epollfd;
    int sockfd;
    void *map;
    struct sockaddr_ll addr;
    struct epoll_event ev;
    struct epoll_event events[1];
    struct tpacket_req req;
    struct iovec *ring;
    unsigned int i;
    const char *ethname = "eth1";
    FILE *file;

    epollfd = epoll_create(1);

    if ((sockfd = socket(PF_PACKET, SOCK_RAW, 0)) < 0) {
        perror("socket()");
        exit(EXIT_FAILURE);
    }

    req.tp_block_size = 4096;
    req.tp_frame_size = 1024;
    req.tp_block_nr = 64;
    req.tp_frame_nr = 4*64;
    if (setsockopt(sockfd,
                   SOL_PACKET,
                   PACKET_RX_RING,
                   (void *)&req,
                   sizeof(req)) != 0) {
        perror("setsockopt()");
        close(sockfd);
        exit(EXIT_FAILURE);
    }

    if ((map = mmap(NULL,
                    req.tp_block_size * req.tp_block_nr,
                    PROT_READ | PROT_WRITE | PROT_EXEC, 
                    MAP_SHARED,
                    sockfd,
                    0)) == MAP_FAILED) {
        perror("mmap()");
        close(sockfd);
        exit(EXIT_FAILURE);
    }

    ring = malloc(req.tp_frame_nr * sizeof(struct iovec));
    for (i=0; i<req.tp_frame_nr; i++) {
        ring[i].iov_base = map + (i * req.tp_frame_size);
        ring[i].iov_len = req.tp_frame_size;
    }

    int ifindex;
    ifindex = get_if_index(sockfd, ethname);

    memset(&addr, 0, sizeof(addr));
    addr.sll_family = AF_PACKET;
    addr.sll_protocol=htons(ETH_P_ALL);
    addr.sll_ifindex = ifindex;

    if (bind(sockfd, (struct sockaddr *)&addr, sizeof(addr)) != 0) {
        perror("bind()");
        munmap(map, req.tp_block_size * req.tp_block_nr);
        close(sockfd);
        exit(EXIT_FAILURE);
    }

    if (epollfd < 0) {
        perror("epoll_create");
        exit(EXIT_FAILURE);
    }

    ev.events = EPOLLIN;
    ev.data.fd = sockfd;
    if (epoll_ctl(epollfd, EPOLL_CTL_ADD, sockfd, &ev) < 0) {
        perror("epoll_ctl");
        exit(EXIT_FAILURE);
    }

    int nfds;
    ssize_t written;
    nfds = epoll_wait(epollfd, events, 1, -1);

    i = 0;
    written = 0;
    file = fopen("out.dat", "w");
    while (nfds > 0) {
        while (*(unsigned long*)ring[i].iov_base) {
            struct sysele s;
            struct tpacket_hdr *h = ring[i].iov_base;
			struct sockaddr_ll *sll=(void *)h + TPACKET_ALIGN(sizeof(*h));

            s = tpacket_sysele(h);
            written += fwrite(s.data_array, 1, s.data_size, file);

            /* printf("family=%04x, protocol=%04x, ifindex=%d, hatype=%04x, pkttype=%08x, halen=%d, addr=%02X:%02X:%02X:%02X:%02X:%02X\n", */
            /*        sll->sll_family, */
            /*        sll->sll_protocol, */
            /*        sll->sll_ifindex, */
            /*        sll->sll_hatype, */
            /*        sll->sll_pkttype, */
            /*        sll->sll_halen, */
            /*        sll->sll_addr[0], */
            /*        sll->sll_addr[1], */
            /*        sll->sll_addr[2], */
            /*        sll->sll_addr[3], */
            /*        sll->sll_addr[4], */
            /*        sll->sll_addr[5]); */


            /* printf("status=%d, len=%d, snaplen=%d, mac=%d, net=%d, sec=%d, usec=%d\n", */
            /*        h->tp_status, */
            /*        h->tp_len, */
            /*        h->tp_snaplen, */
            /*        h->tp_mac, */
            /*        h->tp_net, */
            /*        h->tp_sec, */
            /*        h->tp_usec); */

            /* print_sysele(&s); */

            /* int ii, jj, kk; */
            /* for (kk=0; kk<10; kk++) { */
            /*     for (ii = 0; ii < 2; ii++) { */
            /*         for (jj = 0; jj < 8; jj++) { */
            /*             printf("%02X ", *bp++); */
            /*         } */
            /*         printf(" "); */
            /*     } */
            /*     printf("\n"); */
            /* } */
            /* printf("\n"); */

            i += 1;
            i %= 256;
            h->tp_status = 0;
            __sync_synchronize();
        }

        nfds = epoll_wait(epollfd, events, 1, 1000);
    }

    printf("wrote %lls (0x%llx) bytes\n", written, written);

    struct tpacket_stats st;
    int len;

	if (!getsockopt(sockfd,SOL_PACKET,PACKET_STATISTICS,(char *)&st,&len)) {
        len = sizeof(st);
		fprintf(stderr, "recieved %u packets, dropped %u\n",
			st.tp_packets, st.tp_drops);
	}

    return 0;
}
