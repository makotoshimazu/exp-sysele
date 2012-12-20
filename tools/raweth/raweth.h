
#ifndef _RAWETH_H_
#define _RAWETH_H_

#include <inttypes.h>

#include <arpa/inet.h>
#include <linux/if_packet.h>
#include <sys/ioctl.h>
#include <sys/socket.h>
#include <net/if.h>
#include <netinet/ether.h>

struct sysele {
    struct ether_header *header;
    uint16_t *counter;
    uint8_t *data_array;

    /* size of header + counter + data */
    ssize_t size;
    /* valid after receive; size of received data */
    ssize_t data_size;
    /* valid after receive */
    socklen_t socklen;
    /* valid after receive */
    struct sockaddr_ll sockaddr;
};

int get_if_index(int sockfd, const char *ethname);
uint8_t *get_mac_addr(int sockfd, const char *ethname);
struct sockaddr_ll mk_sockaddr(int ifindex, const uint8_t *dest_addr);
struct ether_header mk_ether_header(const uint8_t *src_addr, const uint8_t *dest_addr, uint16_t type);
struct sysele alloc_sysele(size_t data_size);
struct sysele tpacket_sysele(struct tpacket_hdr *h);
void print_sysele(const struct sysele *s);
ssize_t sysele_recv(struct sysele *s, int sockfd);
ssize_t sysele_send(struct sysele *s, int sockfd);

#endif /* _RAWETH_H_ */
