From: David Ahern <dsahern@kernel.org>
Date: Sat, 20 May 2023 03:50:34 +0000
Subject: Re: [PATCH 1/1] net: ioctl: Use kernel memory on protocol ioctl callbacks
Message-Id: <e5a3b404-b958-c833-1032-70c78e159940@kernel.org>
List-Id: <dccp.vger.kernel.org>
References: <20230519135821.922326-2-leitao@debian.org>
In-Reply-To: <20230519135821.922326-2-leitao@debian.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 5/19/23 7:58 AM, Breno Leitao wrote:
> diff --git a/net/core/sock.c b/net/core/sock.c
> index 5440e67bcfe3..47567909baf2 100644
> --- a/net/core/sock.c
> +++ b/net/core/sock.c
> @@ -4106,3 +4109,107 @@ int sock_bind_add(struct sock *sk, struct sockaddr *addr, int addr_len)
>  	return sk->sk_prot->bind_add(sk, addr, addr_len);
>  }
>  EXPORT_SYMBOL(sock_bind_add);
> +
> +/* Copy 'size' bytes from userspace and do not copy anything back */
> +int sock_skproto_ioctl_in(struct sock *sk, unsigned int cmd,
> +			  void __user *arg)

Unless I missed a reference, this one, the _inout, and the _out below
can be marked static - they are not need outside of sock.c.


> +{
> +	int karg;
> +
> +	if (get_user(karg, (u32 __user *)arg))
> +		return -EFAULT;
> +
> +	return sk->sk_prot->ioctl(sk, cmd, &karg);
> +}
> +
> +/* Copy 'size' bytes from userspace and return `size` back to userspace */
> +int sock_skproto_ioctl_inout(struct sock *sk, unsigned int cmd,
> +			     void __user *arg, size_t size)
> +{
> +	void *ptr;
> +	int ret;
> +
> +	ptr = kmalloc(size, GFP_KERNEL);
> +	if (!ptr)
> +		return -ENOMEM;
> +
> +	if (copy_from_user(ptr, arg, size)) {
> +		ret = -EFAULT;
> +		goto out;
> +	}
> +
> +	ret = sk->sk_prot->ioctl(sk, cmd, ptr);
> +	if (ret)
> +		goto out;
> +
> +	if (copy_to_user(arg, ptr, size))
> +		ret = -EFAULT;
> +
> +out:
> +	kfree(ptr);
> +	return ret;
> +}
> +
> +/* This is the most common ioctl prep function, where the result (4 bytes) is
> + * copied back to userspace if the ioctl() returns successfully. No input is
> + * copied from userspace as input argument.
> + */
> +int sock_skproto_ioctl_out(struct sock *sk, unsigned int cmd,
> +			   void __user *arg)
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
> + * protocol ioctl callsback, instead of userspace memory.
> + */
> +int sock_skprot_ioctl(struct sock *sk, unsigned int cmd,
> +		      void __user *arg)
> +{
> +#ifdef CONFIG_IP_MROUTE
> +	if (!strcmp(sk->sk_prot->name, "RAW")) {
> +		switch (cmd) {
> +		/* These userspace buffers will be consumed by ipmr_ioctl() */
> +		case SIOCGETVIFCNT:
> +			return sock_skproto_ioctl_inout(sk, cmd,
> +				arg, sizeof(struct sioc_vif_req));
> +		case SIOCGETSGCNT:
> +			return sock_skproto_ioctl_inout(sk, cmd,
> +				arg, sizeof(struct sioc_sg_req));
> +		}
> +	}
> +#endif
> +#ifdef CONFIG_IPV6_MROUTE
> +	if (!strcmp(sk->sk_prot->name, "RAW6")) {
> +		switch (cmd) {
> +		/* These userspace buffers will be consumed by ip6mr_ioctl() */
> +		case SIOCGETMIFCNT_IN6:
> +			return sock_skproto_ioctl_inout(sk, cmd,
> +				arg, sizeof(struct sioc_mif_req6));
> +		case SIOCGETSGCNT_IN6:
> +			return sock_skproto_ioctl_inout(sk, cmd,
> +				arg, sizeof(struct sioc_sg_req6));
> +		}
> +	}
> +#endif
> +#ifdef CONFIG_PHONET
> +	if (!strcmp(sk->sk_prot->name, "PHONET")) {
> +		/* This userspace buffers will be consumed by pn_ioctl() */
> +		switch (cmd) {
> +		case SIOCPNADDRESOURCE:
> +		case SIOCPNDELRESOURCE:
> +			return sock_skproto_ioctl_in(sk, cmd, arg);
> +		}
> +	}
> +#endif
> +
> +	return sock_skproto_ioctl_out(sk, cmd, arg);
> +}

