#define _GNU_SOURCE
#include <stdio.h>
#include <stddef.h>
#include <sys/socket.h>
#include <sys/uio.h>
#include <netinet/in.h>

int main(void) {
    printf("=== Sizes ===\n");
    printf("iovec: %zu\n", sizeof(struct iovec));
    printf("msghdr: %zu\n", sizeof(struct msghdr));
    printf("cmsghdr: %zu\n", sizeof(struct cmsghdr));
    printf("in_pktinfo: %zu\n", sizeof(struct in_pktinfo));
    printf("in6_pktinfo: %zu\n", sizeof(struct in6_pktinfo));

    printf("\n=== msghdr offsets ===\n");
    printf("msg_name: %zu\n", offsetof(struct msghdr, msg_name));
    printf("msg_namelen: %zu\n", offsetof(struct msghdr, msg_namelen));
    printf("msg_iov: %zu\n", offsetof(struct msghdr, msg_iov));
    printf("msg_iovlen: %zu\n", offsetof(struct msghdr, msg_iovlen));
    printf("msg_control: %zu\n", offsetof(struct msghdr, msg_control));
    printf("msg_controllen: %zu\n", offsetof(struct msghdr, msg_controllen));
    printf("msg_flags: %zu\n", offsetof(struct msghdr, msg_flags));

    printf("\n=== in_pktinfo offsets ===\n");
    printf("ipi_ifindex: %zu\n", offsetof(struct in_pktinfo, ipi_ifindex));
    printf("ipi_spec_dst: %zu\n", offsetof(struct in_pktinfo, ipi_spec_dst));
    printf("ipi_addr: %zu\n", offsetof(struct in_pktinfo, ipi_addr));

    printf("\n=== in6_pktinfo offsets ===\n");
    printf("ipi6_addr: %zu\n", offsetof(struct in6_pktinfo, ipi6_addr));
    printf("ipi6_ifindex: %zu\n", offsetof(struct in6_pktinfo, ipi6_ifindex));

    return 0;
}
