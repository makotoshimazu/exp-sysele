
/*
 * copied from: https://gist.github.com/1922600
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 */

#include <unistd.h>
#include <arpa/inet.h>
#include <linux/if_packet.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <sys/ioctl.h>
#include <sys/socket.h>
#include <net/if.h>
#include <netinet/ether.h>

#define MY_DEST_MAC0 0xFF
#define MY_DEST_MAC1 0xFF
#define MY_DEST_MAC2 0xFF
#define MY_DEST_MAC3 0xFF
#define MY_DEST_MAC4 0xFF
#define MY_DEST_MAC5 0xFF

#define DEFAULT_IF "eth1"
#define BUF_SIZ 0x05e0

int main(int argc, char *argv[])
{
    int sockfd;
    struct ifreq if_idx;
    struct ifreq if_mac;
    int tx_len = 0;
    char *sendbuf = malloc(BUF_SIZ);
    struct ether_header *eh = (struct ether_header *) sendbuf;
    struct iphdr *iph = (struct iphdr *) (sendbuf + sizeof(struct ether_header));
    struct sockaddr_ll socket_address;
    char ifName[IFNAMSIZ];

/* Get interface name */
    if (argc > 1)
        strcpy(ifName, argv[1]);
    else
        strcpy(ifName, DEFAULT_IF);

/* Open RAW socket to send on */
    if ((sockfd = socket(AF_PACKET, SOCK_RAW, IPPROTO_RAW)) == -1) {
        perror("socket");
    }

/* Get the index of the interface to send on */
    memset(&if_idx, 0, sizeof(struct ifreq));
    strncpy(if_idx.ifr_name, ifName, IFNAMSIZ-1);
    if (ioctl(sockfd, SIOCGIFINDEX, &if_idx) < 0)
        perror("SIOCGIFINDEX");
/* Get the MAC address of the interface to send on */
    memset(&if_mac, 0, sizeof(struct ifreq));
    strncpy(if_mac.ifr_name, ifName, IFNAMSIZ-1);
    if (ioctl(sockfd, SIOCGIFHWADDR, &if_mac) < 0)
        perror("SIOCGIFHWADDR");

/* Construct the Ethernet header */
    memset(sendbuf, 0, BUF_SIZ);
/* Ethernet header */
    eh->ether_shost[0] = ((uint8_t *)&if_mac.ifr_hwaddr.sa_data)[0];
    eh->ether_shost[1] = ((uint8_t *)&if_mac.ifr_hwaddr.sa_data)[1];
    eh->ether_shost[2] = ((uint8_t *)&if_mac.ifr_hwaddr.sa_data)[2];
    eh->ether_shost[3] = ((uint8_t *)&if_mac.ifr_hwaddr.sa_data)[3];
    eh->ether_shost[4] = ((uint8_t *)&if_mac.ifr_hwaddr.sa_data)[4];
    eh->ether_shost[5] = ((uint8_t *)&if_mac.ifr_hwaddr.sa_data)[5];
    eh->ether_dhost[0] = MY_DEST_MAC0;
    eh->ether_dhost[1] = MY_DEST_MAC1;
    eh->ether_dhost[2] = MY_DEST_MAC2;
    eh->ether_dhost[3] = MY_DEST_MAC3;
    eh->ether_dhost[4] = MY_DEST_MAC4;
    eh->ether_dhost[5] = MY_DEST_MAC5;
/* Ethertype field */
    eh->ether_type = 0x0060; // htons(ETH_P_ALL);
    tx_len += sizeof(struct ether_header);

/* Packet data */
    int i;
    FILE *file;
    file = fopen("test.dat", "r");

/* Index of the network device */
    socket_address.sll_ifindex = if_idx.ifr_ifindex;
/* Address length*/
    socket_address.sll_halen = ETH_ALEN;
/* Destination MAC */
    socket_address.sll_addr[0] = MY_DEST_MAC0;
    socket_address.sll_addr[1] = MY_DEST_MAC1;
    socket_address.sll_addr[2] = MY_DEST_MAC2;
    socket_address.sll_addr[3] = MY_DEST_MAC3;
    socket_address.sll_addr[4] = MY_DEST_MAC4;
    socket_address.sll_addr[5] = MY_DEST_MAC5;

/* Send packet */
    long long size = 256LL*1024LL*1024LL;
    long long sent = 0;
    long long thistime;
    while (size > 0) {
        long long send_size;
        
        if (size > BUF_SIZ - 0x10)
            send_size = BUF_SIZ;
        else
            send_size = size + 0x10;

        fread(sendbuf+0x10, 1, BUF_SIZ-0x10, file);
        if ((thistime = sendto(sockfd, sendbuf, send_size, 0, (struct sockaddr*)&socket_address, sizeof(struct sockaddr_ll))) < 0)
            perror("Send failed\n");
        size -= thistime - 0x10;
        sent += thistime - 0x10;
    }

    printf("sent 0x%08llx bytes\n", sent);

    return 0;
}
