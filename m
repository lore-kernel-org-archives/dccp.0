From: Martin KaFai Lau <kafai@fb.com>
Date: Fri, 08 May 2020 07:06:38 +0000
Subject: Re: [PATCH bpf-next 02/17] bpf: Introduce SK_LOOKUP program type with a dedicated attach point
Message-Id: <20200508070638.pqe73q4v3paxpkq5@kafai-mbp.dhcp.thefacebook.com>
List-Id: <dccp.vger.kernel.org>
References: <20200506125514.1020829-3-jakub@cloudflare.com>
In-Reply-To: <20200506125514.1020829-3-jakub@cloudflare.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Wed, May 06, 2020 at 02:54:58PM +0200, Jakub Sitnicki wrote:
> Add a new program type BPF_PROG_TYPE_SK_LOOKUP and a dedicated attach type
> called BPF_SK_LOOKUP. The new program kind is to be invoked by the
> transport layer when looking up a socket for a received packet.
> 
> When called, SK_LOOKUP program can select a socket that will receive the
> packet. This serves as a mechanism to overcome the limits of what bind()
> API allows to express. Two use-cases driving this work are:
> 
>  (1) steer packets destined to an IP range, fixed port to a socket
> 
>      192.0.2.0/24, port 80 -> NGINX socket
> 
>  (2) steer packets destined to an IP address, any port to a socket
> 
>      198.51.100.1, any port -> L7 proxy socket
> 
> In its run-time context, program receives information about the packet that
> triggered the socket lookup. Namely IP version, L4 protocol identifier, and
> address 4-tuple. Context can be further extended to include ingress
> interface identifier.
> 
> To select a socket BPF program fetches it from a map holding socket
> references, like SOCKMAP or SOCKHASH, and calls bpf_sk_assign(ctx, sk, ...)
> helper to record the selection. Transport layer then uses the selected
> socket as a result of socket lookup.
> 
> This patch only enables the user to attach an SK_LOOKUP program to a
> network namespace. Subsequent patches hook it up to run on local delivery
> path in ipv4 and ipv6 stacks.
> 
> Suggested-by: Marek Majkowski <marek@cloudflare.com>
> Reviewed-by: Lorenz Bauer <lmb@cloudflare.com>
> Signed-off-by: Jakub Sitnicki <jakub@cloudflare.com>
> ---
>  include/linux/bpf_types.h   |   2 +
>  include/linux/filter.h      |  23 ++++
>  include/net/net_namespace.h |   1 +
>  include/uapi/linux/bpf.h    |  53 ++++++++
>  kernel/bpf/syscall.c        |   9 ++
>  net/core/filter.c           | 247 ++++++++++++++++++++++++++++++++++++
>  scripts/bpf_helpers_doc.py  |   9 +-
>  7 files changed, 343 insertions(+), 1 deletion(-)
> 
> diff --git a/include/linux/bpf_types.h b/include/linux/bpf_types.h
> index 8345cdf553b8..08c2aef674ac 100644
> --- a/include/linux/bpf_types.h
> +++ b/include/linux/bpf_types.h
> @@ -64,6 +64,8 @@ BPF_PROG_TYPE(BPF_PROG_TYPE_LIRC_MODE2, lirc_mode2,
>  #ifdef CONFIG_INET
>  BPF_PROG_TYPE(BPF_PROG_TYPE_SK_REUSEPORT, sk_reuseport,
>  	      struct sk_reuseport_md, struct sk_reuseport_kern)
> +BPF_PROG_TYPE(BPF_PROG_TYPE_SK_LOOKUP, sk_lookup,
> +	      struct bpf_sk_lookup, struct bpf_sk_lookup_kern)
>  #endif
>  #if defined(CONFIG_BPF_JIT)
>  BPF_PROG_TYPE(BPF_PROG_TYPE_STRUCT_OPS, bpf_struct_ops,
> diff --git a/include/linux/filter.h b/include/linux/filter.h
> index af37318bb1c5..33254e840c8d 100644
> --- a/include/linux/filter.h
> +++ b/include/linux/filter.h
> @@ -1280,4 +1280,27 @@ struct bpf_sockopt_kern {
>  	s32		retval;
>  };
>  
> +struct bpf_sk_lookup_kern {
> +	unsigned short	family;
> +	u16		protocol;
> +	union {
> +		struct {
> +			__be32 saddr;
> +			__be32 daddr;
> +		} v4;
> +		struct {
> +			struct in6_addr saddr;
> +			struct in6_addr daddr;
> +		} v6;
> +	};
> +	__be16		sport;
> +	u16		dport;
> +	struct sock	*selected_sk;
> +};
> +
> +int sk_lookup_prog_attach(const union bpf_attr *attr, struct bpf_prog *prog);
> +int sk_lookup_prog_detach(const union bpf_attr *attr);
> +int sk_lookup_prog_query(const union bpf_attr *attr,
> +			 union bpf_attr __user *uattr);
> +
>  #endif /* __LINUX_FILTER_H__ */
> diff --git a/include/net/net_namespace.h b/include/net/net_namespace.h
> index ab96fb59131c..70bf4888c94d 100644
> --- a/include/net/net_namespace.h
> +++ b/include/net/net_namespace.h
> @@ -163,6 +163,7 @@ struct net {
>  	struct net_generic __rcu	*gen;
>  
>  	struct bpf_prog __rcu	*flow_dissector_prog;
> +	struct bpf_prog __rcu	*sk_lookup_prog;
>  
>  	/* Note : following structs are cache line aligned */
>  #ifdef CONFIG_XFRM
> diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
> index b3643e27e264..e4c61b63d4bc 100644
> --- a/include/uapi/linux/bpf.h
> +++ b/include/uapi/linux/bpf.h
> @@ -187,6 +187,7 @@ enum bpf_prog_type {
>  	BPF_PROG_TYPE_STRUCT_OPS,
>  	BPF_PROG_TYPE_EXT,
>  	BPF_PROG_TYPE_LSM,
> +	BPF_PROG_TYPE_SK_LOOKUP,
>  };
>  
>  enum bpf_attach_type {
> @@ -218,6 +219,7 @@ enum bpf_attach_type {
>  	BPF_TRACE_FEXIT,
>  	BPF_MODIFY_RETURN,
>  	BPF_LSM_MAC,
> +	BPF_SK_LOOKUP,
>  	__MAX_BPF_ATTACH_TYPE
>  };
>  
> @@ -3041,6 +3043,10 @@ union bpf_attr {
>   *
>   * int bpf_sk_assign(struct sk_buff *skb, struct bpf_sock *sk, u64 flags)
>   *	Description
> + *		Helper is overloaded depending on BPF program type. This
> + *		description applies to **BPF_PROG_TYPE_SCHED_CLS** and
> + *		**BPF_PROG_TYPE_SCHED_ACT** programs.
> + *
>   *		Assign the *sk* to the *skb*. When combined with appropriate
>   *		routing configuration to receive the packet towards the socket,
>   *		will cause *skb* to be delivered to the specified socket.
> @@ -3061,6 +3067,39 @@ union bpf_attr {
>   *					call from outside of TC ingress.
>   *		* **-ESOCKTNOSUPPORT**	Socket type not supported (reuseport).
>   *
> + * int bpf_sk_assign(struct bpf_sk_lookup *ctx, struct bpf_sock *sk, u64 flags)
> + *	Description
> + *		Helper is overloaded depending on BPF program type. This
> + *		description applies to **BPF_PROG_TYPE_SK_LOOKUP** programs.
> + *
> + *		Select the *sk* as a result of a socket lookup.
> + *
> + *		For the operation to succeed passed socket must be compatible
> + *		with the packet description provided by the *ctx* object.
> + *
> + *		L4 protocol (*IPPROTO_TCP* or *IPPROTO_UDP*) must be an exact
> + *		match. While IP family (*AF_INET* or *AF_INET6*) must be
> + *		compatible, that is IPv6 sockets that are not v6-only can be
> + *		selected for IPv4 packets.
> + *
> + *		Only full sockets can be selected. However, there is no need to
> + *		call bpf_fullsock() before passing a socket as an argument to
> + *		this helper.
> + *
> + *		The *flags* argument must be zero.
> + *	Return
> + *		0 on success, or a negative errno in case of failure.
> + *
> + *		**-EAFNOSUPPORT** is socket family (*sk->family*) is not
> + *		compatible with packet family (*ctx->family*).
> + *
> + *		**-EINVAL** if unsupported flags were specified.
> + *
> + *		**-EPROTOTYPE** if socket L4 protocol (*sk->protocol*) doesn't
> + *		match packet protocol (*ctx->protocol*).
> + *
> + *		**-ESOCKTNOSUPPORT** if socket is not a full socket.
> + *
>   * u64 bpf_ktime_get_boot_ns(void)
>   * 	Description
>   * 		Return the time elapsed since system boot, in nanoseconds.
> @@ -4012,4 +4051,18 @@ struct bpf_pidns_info {
>  	__u32 pid;
>  	__u32 tgid;
>  };
> +
> +/* User accessible data for SK_LOOKUP programs. Add new fields at the end. */
> +struct bpf_sk_lookup {
> +	__u32 family;		/* AF_INET, AF_INET6 */
> +	__u32 protocol;		/* IPPROTO_TCP, IPPROTO_UDP */
> +	/* IP addresses allows 1, 2, and 4 bytes access */
> +	__u32 src_ip4;
> +	__u32 src_ip6[4];
> +	__u32 src_port;		/* network byte order */
> +	__u32 dst_ip4;
> +	__u32 dst_ip6[4];
> +	__u32 dst_port;		/* host byte order */
> +};
> +
>  #endif /* _UAPI__LINUX_BPF_H__ */
> diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
> index bb1ab7da6103..26d643c171fd 100644
> --- a/kernel/bpf/syscall.c
> +++ b/kernel/bpf/syscall.c
> @@ -2729,6 +2729,8 @@ attach_type_to_prog_type(enum bpf_attach_type attach_type)
>  	case BPF_CGROUP_GETSOCKOPT:
>  	case BPF_CGROUP_SETSOCKOPT:
>  		return BPF_PROG_TYPE_CGROUP_SOCKOPT;
> +	case BPF_SK_LOOKUP:
It may be a good idea to enforce the "expected_attach_type =
BPF_SK_LOOKUP" during prog load time in bpf_prog_load_check_attach().
The attr->expected_attach_type could be anything right now if I read
it correctly.

> +		return BPF_PROG_TYPE_SK_LOOKUP;
>  	default:
>  		return BPF_PROG_TYPE_UNSPEC;
>  	}
> @@ -2778,6 +2780,9 @@ static int bpf_prog_attach(const union bpf_attr *attr)
>  	case BPF_PROG_TYPE_FLOW_DISSECTOR:
>  		ret = skb_flow_dissector_bpf_prog_attach(attr, prog);
>  		break;
> +	case BPF_PROG_TYPE_SK_LOOKUP:
> +		ret = sk_lookup_prog_attach(attr, prog);
> +		break;
>  	case BPF_PROG_TYPE_CGROUP_DEVICE:
>  	case BPF_PROG_TYPE_CGROUP_SKB:
>  	case BPF_PROG_TYPE_CGROUP_SOCK:
> @@ -2818,6 +2823,8 @@ static int bpf_prog_detach(const union bpf_attr *attr)
>  		return lirc_prog_detach(attr);
>  	case BPF_PROG_TYPE_FLOW_DISSECTOR:
>  		return skb_flow_dissector_bpf_prog_detach(attr);
> +	case BPF_PROG_TYPE_SK_LOOKUP:
> +		return sk_lookup_prog_detach(attr);
>  	case BPF_PROG_TYPE_CGROUP_DEVICE:
>  	case BPF_PROG_TYPE_CGROUP_SKB:
>  	case BPF_PROG_TYPE_CGROUP_SOCK:
> @@ -2867,6 +2874,8 @@ static int bpf_prog_query(const union bpf_attr *attr,
>  		return lirc_prog_query(attr, uattr);
>  	case BPF_FLOW_DISSECTOR:
>  		return skb_flow_dissector_prog_query(attr, uattr);
> +	case BPF_SK_LOOKUP:
> +		return sk_lookup_prog_query(attr, uattr);
"# CONFIG_NET is not set" needs to be taken care.

>  	default:
>  		return -EINVAL;
>  	}
> diff --git a/net/core/filter.c b/net/core/filter.c
> index bc25bb1085b1..a00bdc70041c 100644
> --- a/net/core/filter.c
> +++ b/net/core/filter.c
> @@ -9054,6 +9054,253 @@ const struct bpf_verifier_ops sk_reuseport_verifier_ops = {
>  
>  const struct bpf_prog_ops sk_reuseport_prog_ops = {
>  };
> +
> +static DEFINE_MUTEX(sk_lookup_prog_mutex);
> +
> +int sk_lookup_prog_attach(const union bpf_attr *attr, struct bpf_prog *prog)
> +{
> +	struct net *net = current->nsproxy->net_ns;
> +	int ret;
> +
> +	if (unlikely(attr->attach_flags))
> +		return -EINVAL;
> +
> +	mutex_lock(&sk_lookup_prog_mutex);
> +	ret = bpf_prog_attach_one(&net->sk_lookup_prog,
> +				  &sk_lookup_prog_mutex, prog,
> +				  attr->attach_flags);
> +	mutex_unlock(&sk_lookup_prog_mutex);
> +
> +	return ret;
> +}
> +
> +int sk_lookup_prog_detach(const union bpf_attr *attr)
> +{
> +	struct net *net = current->nsproxy->net_ns;
> +	int ret;
> +
> +	if (unlikely(attr->attach_flags))
> +		return -EINVAL;
> +
> +	mutex_lock(&sk_lookup_prog_mutex);
> +	ret = bpf_prog_detach_one(&net->sk_lookup_prog,
> +				  &sk_lookup_prog_mutex);
> +	mutex_unlock(&sk_lookup_prog_mutex);
> +
> +	return ret;
> +}
> +
> +int sk_lookup_prog_query(const union bpf_attr *attr,
> +			 union bpf_attr __user *uattr)
> +{
> +	struct net *net;
> +	int ret;
> +
> +	net = get_net_ns_by_fd(attr->query.target_fd);
> +	if (IS_ERR(net))
> +		return PTR_ERR(net);
> +
> +	ret = bpf_prog_query_one(&net->sk_lookup_prog, attr, uattr);
> +
> +	put_net(net);
> +	return ret;
> +}
> +
> +BPF_CALL_3(bpf_sk_lookup_assign, struct bpf_sk_lookup_kern *, ctx,
> +	   struct sock *, sk, u64, flags)
> +{
> +	if (unlikely(flags != 0))
> +		return -EINVAL;
> +	if (unlikely(!sk_fullsock(sk)))
May be ARG_PTR_TO_SOCKET instead?

> +		return -ESOCKTNOSUPPORT;
> +
> +	/* Check if socket is suitable for packet L3/L4 protocol */
> +	if (sk->sk_protocol != ctx->protocol)
> +		return -EPROTOTYPE;
> +	if (sk->sk_family != ctx->family &&
> +	    (sk->sk_family = AF_INET || ipv6_only_sock(sk)))
> +		return -EAFNOSUPPORT;
> +
> +	/* Select socket as lookup result */
> +	ctx->selected_sk = sk;
Could sk be a TCP_ESTABLISHED sk?

> +	return 0;
> +}
> +
