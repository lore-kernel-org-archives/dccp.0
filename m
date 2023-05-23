From: David Ahern <dsahern@kernel.org>
Date: Tue, 23 May 2023 14:49:14 +0000
Subject: Re: [PATCH v2] net: ioctl: Use kernel memory on protocol ioctl callbacks
Message-Id: <2f02c9b6-1115-791d-cdaf-049c9eeaee0c@kernel.org>
List-Id: <dccp.vger.kernel.org>
References: <20230522134735.2810070-1-leitao@debian.org>
In-Reply-To: <20230522134735.2810070-1-leitao@debian.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 5/22/23 7:47 AM, Breno Leitao wrote:
> diff --git a/net/core/sock.c b/net/core/sock.c
> index 5440e67bcfe3..a2cea95aec99 100644
> --- a/net/core/sock.c
> +++ b/net/core/sock.c
> @@ -114,6 +114,8 @@
>  #include <linux/memcontrol.h>
>  #include <linux/prefetch.h>
>  #include <linux/compat.h>
> +#include <linux/mroute.h>
> +#include <linux/mroute6.h>
>  
>  #include <linux/uaccess.h>
>  
> @@ -138,6 +140,7 @@
>  
>  #include <net/tcp.h>
>  #include <net/busy_poll.h>
> +#include <net/phonet/phonet.h>
>  
>  #include <linux/ethtool.h>
>  
> @@ -4106,3 +4109,112 @@ int sock_bind_add(struct sock *sk, struct sockaddr *addr, int addr_len)
>  	return sk->sk_prot->bind_add(sk, addr, addr_len);
>  }
>  EXPORT_SYMBOL(sock_bind_add);
> +
> +#ifdef CONFIG_PHONET
> +/* Copy u32 value from userspace and do not return anything back */
> +static int sk_ioctl_in(struct sock *sk, unsigned int cmd, void __user *arg)
> +{
> +	int karg;
> +
> +	if (get_user(karg, (u32 __user *)arg))
> +		return -EFAULT;
> +
> +	return sk->sk_prot->ioctl(sk, cmd, &karg);
> +}
> +#endif
> +
> +#if defined(CONFIG_IP_MROUTE) || defined(CONFIG_IPV6_MROUTE)
> +/* Copy 'size' bytes from userspace and return `size` back to userspace */
> +static int sk_ioctl_inout(struct sock *sk, unsigned int cmd,
> +			  void __user *arg, void *karg, size_t size)
> +{
> +	int ret;
> +
> +	if (copy_from_user(karg, arg, size))
> +		return -EFAULT;
> +
> +	ret = sk->sk_prot->ioctl(sk, cmd, karg);
> +	if (ret)
> +		return ret;
> +
> +	if (copy_to_user(arg, karg, size))
> +		return -EFAULT;
> +
> +	return 0;
> +}
> +#endif
> +
> +/* This is the most common ioctl prep function, where the result (4 bytes) is
> + * copied back to userspace if the ioctl() returns successfully. No input is
> + * copied from userspace as input argument.
> + */
> +static int sk_ioctl_out(struct sock *sk, unsigned int cmd, void __user *arg)
> +{
> +	int ret, karg = 0;
> +
> +	ret = sk->sk_prot->ioctl(sk, cmd, &karg);
> +	if (ret)
> +		return ret;
> +
> +	return put_user(karg, (int __user *)arg);
> +}
> +
> +/* A wrapper around sock ioctls, which copies the data from userspace
> + * (depending on the protocol/ioctl), and copies back the result to userspace.
> + * The main motivation for this function is to pass kernel memory to the
> + * protocol ioctl callbacks, instead of userspace memory.
> + */
> +int sk_ioctl(struct sock *sk, unsigned int cmd, void __user *arg)
> +{
> +#ifdef CONFIG_IP_MROUTE
> +	if (sk->sk_family = PF_INET && sk->sk_protocol = IPPROTO_RAW) {
> +		switch (cmd) {
> +		/* These userspace buffers will be consumed by ipmr_ioctl() */
> +		case SIOCGETVIFCNT: {
> +			struct sioc_vif_req buffer;
> +
> +			return sk_ioctl_inout(sk, cmd, arg, &buffer,
> +					      sizeof(buffer));
> +			}
> +		case SIOCGETSGCNT: {
> +			struct sioc_sg_req buffer;
> +
> +			return sk_ioctl_inout(sk, cmd, arg, &buffer,
> +					      sizeof(buffer));
> +			}
> +		}
> +	}
> +#endif
> +#ifdef CONFIG_IPV6_MROUTE
> +	if (sk->sk_family = PF_INET6 && sk->sk_protocol = IPPROTO_RAW) {
> +		switch (cmd) {
> +		/* These userspace buffers will be consumed by ip6mr_ioctl() */
> +		case SIOCGETMIFCNT_IN6: {
> +			struct sioc_mif_req6 buffer;
> +
> +			return sk_ioctl_inout(sk, cmd, arg, &buffer,
> +					      sizeof(buffer));
> +			}
> +		case SIOCGETSGCNT_IN6: {
> +			struct sioc_mif_req6 buffer;
> +
> +			return sk_ioctl_inout(sk, cmd, arg, &buffer,
> +					      sizeof(buffer));
> +			}
> +		}
> +	}
> +#endif
> +#ifdef CONFIG_PHONET
> +	if (sk->sk_family = PF_PHONET && sk->sk_protocol = PN_PROTO_PHONET) {
> +		/* This userspace buffers will be consumed by pn_ioctl() */
> +		switch (cmd) {
> +		case SIOCPNADDRESOURCE:
> +		case SIOCPNDELRESOURCE:
> +			return sk_ioctl_in(sk, cmd, arg);
> +		}
> +	}
> +#endif

Rather than bleed some of these protocol specific details into core
code, how about something like this in include net/phonet/phonet.h

static inline bool sk_is_phonet(struct sock *sk)
{
	return sk->sk_family = PF_PHONET && \
		sk->sk_protocol = PN_PROTO_PHONET;
}

And then in net/core/sock.c:

	if (sk_is_phonet(sk)) {
		rc = phonet_sk_ioctl(...);
		if (rc <= 0)
			return rc;
	}

where < 0 means error, = 0 means handled and > 0 means (keep going).
Similarly for the other 2 above.
