From: Christoph Hellwig <hch@lst.de>
Date: Mon, 20 Jul 2020 12:47:13 +0000
Subject: get rid of the address_space override in setsockopt
Message-Id: <20200720124737.118617-1-hch@lst.de>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hi Dave,

setsockopt is the last place in architecture-independ code that still
uses set_fs to force the uaccess routines to operate on kernel pointers.

This series adds a new sockptr_t type that can contained either a kernel
or user pointer, and which has accessors that do the right thing, and
then uses it for setsockopt, starting by refactoring some low-level
helpers and moving them over to it before finally doing the main
setsockopt method.

Note that I could not get the eBPF selftests to work, so this has been
tested with a testing patch that always copies the data first and passes
a kernel pointer.  This is something that works for most common sockopts
(and is something that the ePBF support relies on), but unfortunately
in various corner cases we either don't use the passed in length, or in
one case actually copy data back from setsockopt, so we unfortunately
can't just always do the copy in the highlevel code, which would have
been much nicer.


Diffstt:
 crypto/af_alg.c                           |    7 
 drivers/crypto/chelsio/chtls/chtls_main.c |   18 -
 drivers/isdn/mISDN/socket.c               |    4 
 include/linux/bpfilter.h                  |    6 
 include/linux/filter.h                    |    3 
 include/linux/mroute.h                    |    5 
 include/linux/mroute6.h                   |    8 
 include/linux/net.h                       |    4 
 include/linux/netfilter.h                 |    6 
 include/linux/netfilter/x_tables.h        |    4 
 include/linux/sockptr.h                   |  121 +++++++++++
 include/net/inet_connection_sock.h        |    3 
 include/net/ip.h                          |    7 
 include/net/ipv6.h                        |    6 
 include/net/sctp/structs.h                |    2 
 include/net/sock.h                        |    7 
 include/net/tcp.h                         |    6 
 include/net/udp.h                         |    2 
 include/net/xfrm.h                        |    8 
 net/atm/common.c                          |    6 
 net/atm/common.h                          |    2 
 net/atm/pvc.c                             |    2 
 net/atm/svc.c                             |    6 
 net/ax25/af_ax25.c                        |    6 
 net/bluetooth/hci_sock.c                  |    8 
 net/bluetooth/l2cap_sock.c                |   22 +-
 net/bluetooth/rfcomm/sock.c               |   12 -
 net/bluetooth/sco.c                       |    6 
 net/bpfilter/bpfilter_kern.c              |   11 -
 net/bridge/netfilter/ebtables.c           |   46 +---
 net/caif/caif_socket.c                    |    8 
 net/can/j1939/socket.c                    |   12 -
 net/can/raw.c                             |   16 -
 net/core/filter.c                         |    6 
 net/core/sock.c                           |   36 +--
 net/dccp/dccp.h                           |    2 
 net/dccp/proto.c                          |   20 -
 net/decnet/af_decnet.c                    |   13 -
 net/ieee802154/socket.c                   |    6 
 net/ipv4/bpfilter/sockopt.c               |    8 
 net/ipv4/ip_options.c                     |   43 +---
 net/ipv4/ip_sockglue.c                    |   66 +++---
 net/ipv4/ipmr.c                           |   14 -
 net/ipv4/netfilter/arp_tables.c           |   33 +--
 net/ipv4/netfilter/ip_tables.c            |   29 +-
 net/ipv4/raw.c                            |    8 
 net/ipv4/tcp.c                            |   30 +-
 net/ipv4/tcp_ipv4.c                       |    4 
 net/ipv4/udp.c                            |   11 -
 net/ipv4/udp_impl.h                       |    4 
 net/ipv6/ip6_flowlabel.c                  |  317 ++++++++++++++++--------------
 net/ipv6/ip6mr.c                          |   17 -
 net/ipv6/ipv6_sockglue.c                  |  203 +++++++++----------
 net/ipv6/netfilter/ip6_tables.c           |   28 +-
 net/ipv6/raw.c                            |   10 
 net/ipv6/tcp_ipv6.c                       |    4 
 net/ipv6/udp.c                            |    7 
 net/ipv6/udp_impl.h                       |    4 
 net/iucv/af_iucv.c                        |    4 
 net/kcm/kcmsock.c                         |    6 
 net/l2tp/l2tp_ppp.c                       |    4 
 net/llc/af_llc.c                          |    4 
 net/mptcp/protocol.c                      |   12 -
 net/netfilter/ipvs/ip_vs_ctl.c            |    4 
 net/netfilter/nf_sockopt.c                |    2 
 net/netfilter/x_tables.c                  |   20 -
 net/netlink/af_netlink.c                  |    4 
 net/netrom/af_netrom.c                    |    4 
 net/nfc/llcp_sock.c                       |    6 
 net/packet/af_packet.c                    |   39 +--
 net/phonet/pep.c                          |    4 
 net/rds/af_rds.c                          |   30 +-
 net/rds/rdma.c                            |   14 -
 net/rds/rds.h                             |    6 
 net/rose/af_rose.c                        |    4 
 net/rxrpc/af_rxrpc.c                      |    8 
 net/rxrpc/ar-internal.h                   |    4 
 net/rxrpc/key.c                           |    9 
 net/sctp/socket.c                         |    4 
 net/smc/af_smc.c                          |    4 
 net/socket.c                              |   20 -
 net/tipc/socket.c                         |    8 
 net/tls/tls_main.c                        |   17 -
 net/vmw_vsock/af_vsock.c                  |    4 
 net/x25/af_x25.c                          |    4 
 net/xdp/xsk.c                             |    8 
 net/xfrm/xfrm_state.c                     |    6 
 87 files changed, 855 insertions(+), 721 deletions(-)
