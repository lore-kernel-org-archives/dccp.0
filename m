From: Hannes Reinecke <hare@suse.de>
Date: Wed, 29 Mar 2023 14:23:51 +0000
Subject: Re: [RFC PATCH v2 48/48] sock: Remove ->sendpage*() in favour of sendmsg(MSG_SPLICE_PAGES)
Message-Id: <e128356a-f56f-4c02-7437-dfea38e4194b@suse.de>
List-Id: <dccp.vger.kernel.org>
References: <20230329141354.516864-49-dhowells@redhat.com>
In-Reply-To: <20230329141354.516864-49-dhowells@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 3/29/23 16:13, David Howells wrote:
> [!] Note: This is a work in progress.  At the moment, some things won't
>      build if this patch is applied.  nvme, kcm, smc, tls.
> 
> Remove ->sendpage() and ->sendpage_locked().  sendmsg() with
> MSG_SPLICE_PAGES should be used instead.  This allows multiple pages and
> multipage folios to be passed through.
> 
> Signed-off-by: David Howells <dhowells@redhat.com>
> Acked-by: Marc Kleine-Budde <mkl@pengutronix.de> # for net/can
> cc: "David S. Miller" <davem@davemloft.net>
> cc: Eric Dumazet <edumazet@google.com>
> cc: Jakub Kicinski <kuba@kernel.org>
> cc: Paolo Abeni <pabeni@redhat.com>
> cc: Jens Axboe <axboe@kernel.dk>
> cc: Matthew Wilcox <willy@infradead.org>
> cc: bpf@vger.kernel.org
> cc: dccp@vger.kernel.org
> cc: linux-afs@lists.infradead.org
> cc: linux-arm-msm@vger.kernel.org
> cc: linux-can@vger.kernel.org
> cc: linux-crypto@vger.kernel.org
> cc: linux-doc@vger.kernel.org
> cc: linux-hams@vger.kernel.org
> cc: linux-kernel@vger.kernel.org
> cc: linux-rdma@vger.kernel.org
> cc: linux-sctp@vger.kernel.org
> cc: linux-wpan@vger.kernel.org
> cc: linux-x25@vger.kernel.org
> cc: mptcp@lists.linux.dev
> cc: netdev@vger.kernel.org
> cc: rds-devel@oss.oracle.com
> cc: tipc-discussion@lists.sourceforge.net
> cc: virtualization@lists.linux-foundation.org
> ---
>   Documentation/networking/scaling.rst |   4 +-
>   crypto/af_alg.c                      |  29 ------
>   crypto/algif_aead.c                  |  22 +----
>   crypto/algif_rng.c                   |   2 -
>   crypto/algif_skcipher.c              |  14 ---
>   include/linux/net.h                  |   8 --
>   include/net/inet_common.h            |   2 -
>   include/net/sock.h                   |   6 --
>   net/appletalk/ddp.c                  |   1 -
>   net/atm/pvc.c                        |   1 -
>   net/atm/svc.c                        |   1 -
>   net/ax25/af_ax25.c                   |   1 -
>   net/caif/caif_socket.c               |   2 -
>   net/can/bcm.c                        |   1 -
>   net/can/isotp.c                      |   1 -
>   net/can/j1939/socket.c               |   1 -
>   net/can/raw.c                        |   1 -
>   net/core/sock.c                      |  35 +------
>   net/dccp/ipv4.c                      |   1 -
>   net/dccp/ipv6.c                      |   1 -
>   net/ieee802154/socket.c              |   2 -
>   net/ipv4/af_inet.c                   |  21 ----
>   net/ipv4/tcp.c                       |  34 -------
>   net/ipv4/tcp_bpf.c                   |  21 +---
>   net/ipv4/tcp_ipv4.c                  |   1 -
>   net/ipv4/udp.c                       |  22 -----
>   net/ipv4/udp_impl.h                  |   2 -
>   net/ipv4/udplite.c                   |   1 -
>   net/ipv6/af_inet6.c                  |   3 -
>   net/ipv6/raw.c                       |   1 -
>   net/ipv6/tcp_ipv6.c                  |   1 -
>   net/key/af_key.c                     |   1 -
>   net/l2tp/l2tp_ip.c                   |   1 -
>   net/l2tp/l2tp_ip6.c                  |   1 -
>   net/llc/af_llc.c                     |   1 -
>   net/mctp/af_mctp.c                   |   1 -
>   net/mptcp/protocol.c                 |   2 -
>   net/netlink/af_netlink.c             |   1 -
>   net/netrom/af_netrom.c               |   1 -
>   net/packet/af_packet.c               |   2 -
>   net/phonet/socket.c                  |   2 -
>   net/qrtr/af_qrtr.c                   |   1 -
>   net/rds/af_rds.c                     |   1 -
>   net/rose/af_rose.c                   |   1 -
>   net/rxrpc/af_rxrpc.c                 |   1 -
>   net/sctp/protocol.c                  |   1 -
>   net/socket.c                         |  48 ---------
>   net/tipc/socket.c                    |   3 -
>   net/unix/af_unix.c                   | 139 ---------------------------
>   net/vmw_vsock/af_vsock.c             |   3 -
>   net/x25/af_x25.c                     |   1 -
>   net/xdp/xsk.c                        |   1 -
>   52 files changed, 9 insertions(+), 447 deletions(-)
> 
Weelll ... what happens to consumers of kernel_sendpage()?
(Let's call them nvme ...)
Should they be moved over, too?

Or what is the general consensus here?

(And what do we do with TLS? It does have a ->sendpage() version, too ...)

Cheers,

Hannes
