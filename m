From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Mon, 12 Dec 2005 00:38:27 +0000
Subject: Re: [PATCH 1/4][DCCP]: Introduce DCCPv6
Message-Id: <39e6f6c70512111638x746582d8ja3cb7d96b1fb4731@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <39e6f6c70512110556r387a6a18q37baca095737e3e0@mail.gmail.com>
In-Reply-To: <39e6f6c70512110556r387a6a18q37baca095737e3e0@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 12/11/05, Francois Romieu <romieu@fr.zoreil.com> wrote:
> Arnaldo Carvalho de Melo <acme@ghostprotocols.net> :
> [...]
> index 0000000..23058dc
> --- /dev/null
> +++ b/net/dccp/ipv6.c
> [...]
> +static void dccp_v6_ctl_send_reset(struct sk_buff *rxskb)
> +{
> [...]
> +       skb = alloc_skb(MAX_HEADER + sizeof(struct ipv6hdr) +
> +                       dccp_hdr_reset_len, GFP_ATOMIC);
> +       if (skb = NULL)
> +               return;
> [...]
> +       /* sk = NULL, but it is safe for now. RST socket required. */
> +       if (!ip6_dst_lookup(NULL, &skb->dst, &fl)) {
> +
> +               if ((xfrm_lookup(&skb->dst, &fl, NULL, 0)) < 0)
> +                       return;
>
> skb leak ?
>
> Same pattern in dccp_v6_ctl_send_ack/tcp_v6_send_{ack/reset}.

Good spot, chatted with Dave and will resend [1/4] with a fix for this
and 5/5 with the fix for the tcp_v6 ones, without resending [2/[2..4]],
thanks!

- Arnaldo
