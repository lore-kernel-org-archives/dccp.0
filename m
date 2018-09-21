From: Stefan Schmidt <stefan@datenfreihafen.org>
Date: Fri, 21 Sep 2018 09:14:36 +0000
Subject: Re: [PATCH net-next 1/3] net: rework SIOCGSTAMP ioctl handling
Message-Id: <5cca03b6-8d3d-5f18-778f-a5d5e70c2218@datenfreihafen.org>
List-Id: <dccp.vger.kernel.org>
References: <20180829130308.3504560-1-arnd@arndb.de>
In-Reply-To: <20180829130308.3504560-1-arnd@arndb.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hello Arnd.

On 8/29/18 2:59 PM, Arnd Bergmann wrote:
> The SIOCGSTAMP/SIOCGSTAMPNS ioctl commands are implemented by many
> socket protocol handlers, and all of those end up calling the same
> sock_get_timestamp()/sock_get_timestampns() helper functions, which
> results in a lot of duplicate code.
> 
> With the introduction of 64-bit time_t on 32-bit architectures, this
> gets worse, as we then need four different ioctl commands in each
> socket protocol implementation.
> 
> To simplify that, let's add a new .gettstamp() operation in
> struct proto_ops, and move ioctl implementation into the common
> sock_ioctl()/compat_sock_ioctl_trans() functions that these all go
> through.
> 
> We can reuse the sock_get_timestamp() implementation, but generalize
> it so it can deal with both native and compat mode, as well as
> timeval and timespec structures.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> ---
>  include/linux/net.h          |  2 ++
>  include/net/compat.h         |  3 --
>  include/net/sock.h           |  4 +--
>  net/appletalk/ddp.c          |  7 +----
>  net/atm/ioctl.c              | 16 -----------
>  net/atm/pvc.c                |  1 +
>  net/atm/svc.c                |  1 +
>  net/ax25/af_ax25.c           |  9 +-----
>  net/bluetooth/af_bluetooth.c |  8 ------
>  net/bluetooth/l2cap_sock.c   |  1 +
>  net/bluetooth/rfcomm/sock.c  |  1 +
>  net/bluetooth/sco.c          |  1 +
>  net/can/af_can.c             |  6 ----
>  net/can/bcm.c                |  1 +
>  net/can/raw.c                |  1 +
>  net/compat.c                 | 54 ------------------------------------
>  net/core/sock.c              | 38 +++++++++++--------------
>  net/dccp/ipv4.c              |  1 +
>  net/dccp/ipv6.c              |  1 +
>  net/ieee802154/socket.c      |  6 ++--
>  net/ipv4/af_inet.c           |  9 ++----
>  net/ipv6/af_inet6.c          |  8 ++----
>  net/ipv6/raw.c               |  1 +
>  net/l2tp/l2tp_ip.c           |  1 +
>  net/l2tp/l2tp_ip6.c          |  1 +
>  net/netrom/af_netrom.c       | 14 +---------
>  net/packet/af_packet.c       |  7 ++---
>  net/qrtr/qrtr.c              |  4 +--
>  net/rose/af_rose.c           |  7 +----
>  net/sctp/ipv6.c              |  1 +
>  net/sctp/protocol.c          |  1 +
>  net/socket.c                 | 48 ++++++++++----------------------
>  net/x25/af_x25.c             | 27 +-----------------
>  33 files changed, 63 insertions(+), 228 deletions(-)

For the net/ieee802154/socket. part I am fine with this change.

Acked-by: Stefan Schmidt <stefan@datenfreihafen.org>

regards
Stefan Schmidt
