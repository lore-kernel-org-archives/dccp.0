From: Andrei Vagin <avagin@gmail.com>
Date: Mon, 11 Sep 2023 23:36:55 +0000
Subject: Re: [PATCH RESEND net-next v4 1/3] net: Add a bhash2 table hashed by port and address
Message-Id: <ZP+kl4/UuTaQTGPT@google.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Mon, Aug 22, 2022 at 11:10:21AM -0700, Joanne Koong wrote:
>  
> +static bool inet_use_bhash2_on_bind(const struct sock *sk)
> +{
> +#if IS_ENABLED(CONFIG_IPV6)
> +	if (sk->sk_family = AF_INET6) {
> +		int addr_type = ipv6_addr_type(&sk->sk_v6_rcv_saddr);
> +
> +		return addr_type != IPV6_ADDR_ANY &&
> +			addr_type != IPV6_ADDR_MAPPED;
>

Why do we return false to all mapped addresses? Should it be

(addr_type != IPV6_ADDR_MAPPED || sk->sk_rcv_saddr != htonl(INADDR_ANY))

>
> +	}
> +#endif
> +	return sk->sk_rcv_saddr != htonl(INADDR_ANY);
> +}
> +
>
Thanks,
Andrei
