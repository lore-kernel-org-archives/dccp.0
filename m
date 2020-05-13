From: Martin KaFai Lau <kafai@fb.com>
Date: Wed, 13 May 2020 05:41:21 +0000
Subject: Re: [PATCH bpf-next v2 02/17] bpf: Introduce SK_LOOKUP program type with a dedicated attach point
Message-Id: <20200513054121.qztevjyfkc2ltcvp@kafai-mbp.dhcp.thefacebook.com>
List-Id: <dccp.vger.kernel.org>
References: <20200511185218.1422406-3-jakub@cloudflare.com>
In-Reply-To: <20200511185218.1422406-3-jakub@cloudflare.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Mon, May 11, 2020 at 08:52:03PM +0200, Jakub Sitnicki wrote:

[ ... ]

> +BPF_CALL_3(bpf_sk_lookup_assign, struct bpf_sk_lookup_kern *, ctx,
> +	   struct sock *, sk, u64, flags)
The SK_LOOKUP bpf_prog may have already selected the proper reuseport sk.
It is possible by looking up sk from sock_map.

Thus, it is not always desired to do lookup_reuseport() after sk_assign()
in patch 5.  e.g. reuseport_select_sock() just uses a normal hash if
there is no reuse->prog.

A flag (e.g. "BPF_F_REUSEPORT_SELECT") can be added here to
specifically do the reuseport_select_sock() after sk_assign().
If not set, reuseport_select_sock() should not be called.

> +{
> +	if (unlikely(flags != 0))
> +		return -EINVAL;
> +	if (unlikely(sk_is_refcounted(sk)))
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
> +	return 0;
> +}
> +
