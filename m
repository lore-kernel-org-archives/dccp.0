From: "Arnaldo Carvalho de Melo" <arnaldo.melo@gmail.com>
Date: Fri, 22 Sep 2006 19:41:53 +0000
Subject: Re: [PATCH 2.6.19] net/dccp: set safe upper bound for option length
Message-Id: <39e6f6c70609221241r3015c321h835b370741f829ae@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <39e6f6c70609220750i681a28c4lf912c7ccb393cd72@mail.gmail.com>
In-Reply-To: <39e6f6c70609220750i681a28c4lf912c7ccb393cd72@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 9/22/06, Arnaldo Carvalho de Melo <arnaldo.melo@gmail.com> wrote:
> On 9/22/06, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> > Hi Arnaldo
> > |  Gerrit, could you please use my net-2.6.19?
> > Of course - I didn't know it was active. I have just pulled your tree and
> > the patch applies without problem.
>
> OK, going over it now.

> diff --git a/net/dccp/dccp.h b/net/dccp/dccp.h
> index 272e858..9e6344f 100644
> --- a/net/dccp/dccp.h
> +++ b/net/dccp/dccp.h
> @@ -40,12 +40,17 @@ extern void dccp_tw_deschedule(struct in
>
> extern void dccp_time_wait(struct sock *sk, int state, int timeo);
>
> -/* FIXME: Right size this */
> -#define DCCP_MAX_OPT_LEN 128
> -
> -#define DCCP_MAX_PACKET_HDR 32
> -
> -#define MAX_DCCP_HEADER  (DCCP_MAX_PACKET_HDR + DCCP_MAX_OPT_LEN + MAX_HEADER)
> +/*
> + *  Set safe upper bounds for header and option length. Since Data Offset is 8
> + *  bits (RFC 4340, sec. 5.1), the total header length can never be more than
> + *  4 * 255 = 1020 bytes. The largest possible header length is 28 bytes (X=1):
> + *    - DCCP-Response with ACK Subheader and 4 bytes of Service code      OR
> + *    - DCCP-Reset    with ACK Subheader and 4 bytes of Reset Code fields
> + *  Hence a safe upper bound for the maximum option length is 1020-28 = 992
> + */
> +#define DCCP_MAX_OPT_LEN      992
> +#define DCCP_MAX_PACKET_HDR    28
> +#define MAX_DCCP_HEADER     (1020 + MAX_HEADER)

With this change DCCP_MAX_PACKET_HDR is not used anywhere, I'm
rewriting it so that we use it to calculate MAX_DCCP_HEADER, something
like:

#define MAX_DCCP_SPECIFIC_HEADER (255 * sizeof(int))
#define DCCP_MAX_PACKET_HDR 28
#define DCCP_MAX_OPT_LEN (MAX_DCCP_SPECIFIC_HEADER - DCCP_MAX_PACKET_HDR)
#define MAX_DCCP_HEADER (MAX_DCCP_SPECIFIC_HEADER + MAX_HEADER)

Thanks,

- Arnaldo
