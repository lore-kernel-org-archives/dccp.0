From: "Arnaldo Carvalho de Melo" <acme@ghostprotocols.net>
Date: Mon, 28 May 2007 19:27:26 +0000
Subject: Re: [PATCH 1/7] DCCP: Fix dccp_sum_coverage
Message-Id: <39e6f6c70705281227j65f09204yb1aa01e6bfb3ff4@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200705191711.55522.ian.mcdonald@jandi.co.nz>
In-Reply-To: <200705191711.55522.ian.mcdonald@jandi.co.nz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 5/19/07, Ian McDonald <ian.mcdonald@jandi.co.nz> wrote:
> When compiling with EXTRA_CFLAGS=-W notice that we have signed/unsigned
> issue in dccp.h.
>
> Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
> ---
> diff --git a/net/dccp/dccp.h b/net/dccp/dccp.h
> index d8ad27b..e2d74cd 100644
> --- a/net/dccp/dccp.h
> +++ b/net/dccp/dccp.h
> @@ -184,7 +184,7 @@ DECLARE_SNMP_STAT(struct dccp_mib, dccp_statistics);
>  /*
>   *     Checksumming routines
>   */
> -static inline int dccp_csum_coverage(const struct sk_buff *skb)
> +static inline unsigned int dccp_csum_coverage(const struct sk_buff *skb)
>  {
>         const struct dccp_hdr* dh = dccp_hdr(skb);
>
> @@ -195,7 +195,7 @@ static inline int dccp_csum_coverage(const struct sk_buff
> *skb)
>
>  static inline void dccp_csum_outgoing(struct sk_buff *skb)
>  {
> -       int cov = dccp_csum_coverage(skb);
> +       unsigned int cov = dccp_csum_coverage(skb);
>
>         if (cov >= skb->len)
>                 dccp_hdr(skb)->dccph_cscov = 0;
>

Thanks, applied.

- Arnaldo
