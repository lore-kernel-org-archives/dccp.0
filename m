From: Pavel Begunkov <asml.silence@gmail.com>
Date: Tue, 11 Apr 2023 12:54:33 +0000
Subject: Re: [RFC PATCH 2/4] net: add uring_cmd callback to UDP
Message-Id: <75efd3a5-dc32-eb06-ed50-8ca0688747e0@gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <20230406144330.1932798-3-leitao@debian.org>
In-Reply-To: <20230406144330.1932798-3-leitao@debian.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 4/6/23 15:43, Breno Leitao wrote:
> This is the implementation of uring_cmd for the udp protocol. It
> basically encompasses SOCKET_URING_OP_SIOCOUTQ and
> SOCKET_URING_OP_SIOCINQ, which is similar to the SIOCOUTQ and SIOCINQ
> ioctls.
> 
> The return value is exactly the same as the regular ioctl (udp_ioctl()).
> 
> Signed-off-by: Breno Leitao <leitao@debian.org>
> ---
>   include/net/udp.h        |  2 ++
>   include/uapi/linux/net.h |  5 +++++
>   net/ipv4/udp.c           | 16 ++++++++++++++++
>   3 files changed, 23 insertions(+)
> 
> diff --git a/include/net/udp.h b/include/net/udp.h
> index de4b528522bb..c0e829dacc2f 100644
> --- a/include/net/udp.h
> +++ b/include/net/udp.h
> @@ -283,6 +283,8 @@ void udp_flush_pending_frames(struct sock *sk);
>   int udp_cmsg_send(struct sock *sk, struct msghdr *msg, u16 *gso_size);
>   void udp4_hwcsum(struct sk_buff *skb, __be32 src, __be32 dst);
>   int udp_rcv(struct sk_buff *skb);
> +int udp_uring_cmd(struct sock *sk, struct io_uring_cmd *cmd,
> +		  unsigned int issue_flags);
>   int udp_ioctl(struct sock *sk, int cmd, unsigned long arg);
>   int udp_init_sock(struct sock *sk);
>   int udp_pre_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len);
> diff --git a/include/uapi/linux/net.h b/include/uapi/linux/net.h
> index 4dabec6bd957..dd8e7ced7d24 100644
> --- a/include/uapi/linux/net.h
> +++ b/include/uapi/linux/net.h
> @@ -55,4 +55,9 @@ typedef enum {
>   
>   #define __SO_ACCEPTCON	(1 << 16)	/* performed a listen		*/
>   
> +enum {
> +	SOCKET_URING_OP_SIOCINQ		= 0,
> +	SOCKET_URING_OP_SIOCOUTQ,
> +};
> +
>   #endif /* _UAPI_LINUX_NET_H */
> diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
> index c605d171eb2d..d6d60600831b 100644
> --- a/net/ipv4/udp.c
> +++ b/net/ipv4/udp.c
> @@ -113,6 +113,7 @@
>   #include <net/sock_reuseport.h>
>   #include <net/addrconf.h>
>   #include <net/udp_tunnel.h>
> +#include <linux/io_uring.h>
>   #if IS_ENABLED(CONFIG_IPV6)
>   #include <net/ipv6_stubs.h>
>   #endif
> @@ -1711,6 +1712,20 @@ static int first_packet_length(struct sock *sk)
>   	return res;
>   }
>   
> +int udp_uring_cmd(struct sock *sk, struct io_uring_cmd *cmd,
> +		  unsigned int issue_flags)
> +{
> +	switch (cmd->sqe->cmd_op) {

Not particularly a problem of this series, but what bothers
me is the quite unfortunate placement of cmd_op in SQE.

struct io_uring_sqe {
	...
	union {
		__u64	d1;
		struct {
			__u32	cmd_op;
			__u32	__pad1;
		};
	};
	__u64	d2;
	__u32	d3;
	...
};

I'd much prefer it like this:

struct io_uring_sqe {
	...
	__u64 d1[2];
	__u32 cmd_op;
	...
};


We can't change it for NVMe, but at least new commands can have
a better layout. It's read in the generic cmd path, i.e.
io_uring_cmd_prep(), so will need some refactoring to make
the placement cmd specific.

-- 
Pavel Begunkov
