From: Christoph Hellwig <hch@lst.de>
Date: Fri, 17 Jul 2020 06:23:09 +0000
Subject: sockopt cleanups
Message-Id: <20200717062331.691152-1-hch@lst.de>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hi Dave,

this series cleans up various lose ends in the sockopt code, most
importantly removing the compat_{get,set}sockopt infrastructure in favor
of just using in_compat_syscall() in the few places that care.

Diffstat:
 arch/arm64/include/asm/unistd32.h                  |    4 
 arch/mips/kernel/syscalls/syscall_n32.tbl          |    4 
 arch/mips/kernel/syscalls/syscall_o32.tbl          |    4 
 arch/parisc/kernel/syscalls/syscall.tbl            |    4 
 arch/powerpc/kernel/syscalls/syscall.tbl           |    4 
 arch/s390/kernel/syscalls/syscall.tbl              |    4 
 arch/sparc/kernel/sys32.S                          |   12 
 arch/sparc/kernel/syscalls/syscall.tbl             |    4 
 arch/x86/entry/syscall_x32.c                       |    7 
 arch/x86/entry/syscalls/syscall_32.tbl             |    4 
 arch/x86/entry/syscalls/syscall_64.tbl             |    4 
 crypto/af_alg.c                                    |    1 
 crypto/algif_aead.c                                |    4 
 crypto/algif_hash.c                                |    4 
 crypto/algif_rng.c                                 |    2 
 crypto/algif_skcipher.c                            |    4 
 drivers/atm/eni.c                                  |   17 
 drivers/atm/firestream.c                           |    2 
 drivers/atm/fore200e.c                             |   27 -
 drivers/atm/horizon.c                              |   40 -
 drivers/atm/iphase.c                               |   16 
 drivers/atm/lanai.c                                |    2 
 drivers/atm/solos-pci.c                            |    2 
 drivers/atm/zatm.c                                 |   16 
 drivers/isdn/mISDN/socket.c                        |    2 
 drivers/net/ppp/pppoe.c                            |    2 
 drivers/net/ppp/pptp.c                             |    2 
 include/linux/atmdev.h                             |    9 
 include/linux/compat.h                             |    4 
 include/linux/filter.h                             |    4 
 include/linux/net.h                                |    6 
 include/linux/netfilter.h                          |   14 
 include/linux/netfilter/x_tables.h                 |    2 
 include/linux/syscalls.h                           |    4 
 include/net/compat.h                               |    1 
 include/net/inet_connection_sock.h                 |   13 
 include/net/ip.h                                   |    4 
 include/net/ipv6.h                                 |    4 
 include/net/sctp/structs.h                         |   10 
 include/net/sock.h                                 |   14 
 include/net/tcp.h                                  |    4 
 include/uapi/asm-generic/unistd.h                  |    4 
 net/appletalk/ddp.c                                |    2 
 net/atm/common.c                                   |   14 
 net/bluetooth/bnep/sock.c                          |    2 
 net/bluetooth/cmtp/sock.c                          |    2 
 net/bluetooth/hidp/sock.c                          |    2 
 net/bridge/netfilter/ebtables.c                    |  214 +++-----
 net/caif/caif_socket.c                             |    2 
 net/can/bcm.c                                      |    2 
 net/compat.c                                       |  122 ----
 net/core/filter.c                                  |   23 
 net/core/sock.c                                    |   72 --
 net/dccp/dccp.h                                    |    6 
 net/dccp/ipv4.c                                    |   12 
 net/dccp/ipv6.c                                    |   14 
 net/dccp/proto.c                                   |   26 -
 net/ieee802154/socket.c                            |    8 
 net/ipv4/af_inet.c                                 |    6 
 net/ipv4/inet_connection_sock.c                    |   28 -
 net/ipv4/ip_sockglue.c                             |  541 +++++++++------------
 net/ipv4/netfilter/arp_tables.c                    |   84 ---
 net/ipv4/netfilter/ip_tables.c                     |   85 ---
 net/ipv4/raw.c                                     |   22 
 net/ipv4/tcp.c                                     |   24 
 net/ipv4/tcp_ipv4.c                                |    8 
 net/ipv4/udp.c                                     |   24 
 net/ipv4/udp_impl.h                                |    6 
 net/ipv4/udplite.c                                 |    4 
 net/ipv6/af_inet6.c                                |    4 
 net/ipv6/ipv6_sockglue.c                           |  537 +++++++++-----------
 net/ipv6/netfilter/ip6_tables.c                    |   86 ---
 net/ipv6/raw.c                                     |   52 --
 net/ipv6/tcp_ipv6.c                                |   12 
 net/ipv6/udp.c                                     |   25 
 net/ipv6/udp_impl.h                                |    6 
 net/ipv6/udplite.c                                 |    4 
 net/key/af_key.c                                   |    2 
 net/l2tp/l2tp_ip.c                                 |    8 
 net/l2tp/l2tp_ip6.c                                |    6 
 net/mptcp/protocol.c                               |    6 
 net/netfilter/nf_sockopt.c                         |   60 --
 net/netfilter/x_tables.c                           |    9 
 net/nfc/llcp_sock.c                                |    2 
 net/nfc/rawsock.c                                  |    4 
 net/packet/af_packet.c                             |   35 -
 net/phonet/socket.c                                |   10 
 net/qrtr/qrtr.c                                    |    2 
 net/sctp/ipv6.c                                    |    6 
 net/sctp/protocol.c                                |    8 
 net/smc/af_smc.c                                   |    9 
 net/socket.c                                       |  103 ++-
 net/unix/af_unix.c                                 |    6 
 net/vmw_vsock/af_vsock.c                           |    2 
 tools/include/uapi/asm-generic/unistd.h            |    4 
 tools/perf/arch/powerpc/entry/syscalls/syscall.tbl |    4 
 tools/perf/arch/s390/entry/syscalls/syscall.tbl    |    4 
 tools/perf/arch/x86/entry/syscalls/syscall_64.tbl  |    4 
 98 files changed, 786 insertions(+), 1884 deletions(-)
