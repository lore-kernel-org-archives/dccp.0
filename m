From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Mon, 01 Oct 2007 22:53:59 +0000
Subject: Re: [PATCH 6/11]: Insert feature-negotiation options into skb
Message-Id: <5640c7e00710011553t737e400fy4b8cc9dcca748c6d@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200710011518.24129@strip-the-willow>
In-Reply-To: <200710011518.24129@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 10/2/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> [DCCP]: Insert feature-negotiation options into skb
>
> The core insertion routine, provided by this patch, does a simple list walk and calls
> an already existing function in options.c to do the actual insertion of individual options.
>
> This replaces the earlier insertion routine from options.c
>
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>

Once a couple of things commented on/fixed.
Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
> ---
>  net/dccp/dccp.h    |    2 +
>  net/dccp/feat.c    |   57 +++++++++++++++++++++++++++++++++++++++++++++++++++++
>  net/dccp/options.c |   45 -----------------------------------------
>  3 files changed, 59 insertions(+), 45 deletions(-)
>
> --- a/net/dccp/dccp.h
> +++ b/net/dccp/dccp.h
> @@ -424,6 +424,8 @@ static inline int dccp_ack_pending(const
>
>  extern int  dccp_feat_finalise_settings(struct dccp_sock *dp);
>  extern int  dccp_feat_server_ccid_dependencies(struct dccp_request_sock *dreq);
> +extern int  dccp_feat_insert_opts(struct dccp_sock*, struct dccp_request_sock*,
> +                                 struct sk_buff *skb);
>  extern void dccp_feat_list_purge(struct list_head *fn_list);
>
>  extern int dccp_insert_options(struct sock *sk, struct sk_buff *skb);
> --- a/net/dccp/feat.c
> +++ b/net/dccp/feat.c
> @@ -334,6 +334,63 @@ static u8 dccp_feat_sp_list_ok(u8 feat_n
>  }
>
>  /**
> + * dccp_feat_insert_opts  -  Generate FN options from current list state
> + * @skb: next sk_buff to be sent to the peer
> + * @dp: for client during handshake and general negotiation
> + * @dreq: used by the server only (all Changes/Confirms in LISTEN/RESPOND)
> + */
> +int dccp_feat_insert_opts(struct dccp_sock *dp, struct dccp_request_sock *dreq,
> +                         struct sk_buff *skb)
> +{
> +       struct list_head *fn = dreq? &dreq->dreq_featneg : &dp->dccps_featneg;

need a space before ? as per Arnaldo's email.

> +       struct dccp_feat_entry *pos, *next;
> +       u8 opt, type, len, *ptr, nn_in_nbo[6];

I think the 6 should be a constant of some kind.

-- 
Web1: http://wand.net.nz/~iam4/
Web2: http://www.jandi.co.nz
Blog: http://iansblog.jandi.co.nz
