From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Sun, 01 Jul 2007 03:54:12 +0000
Subject: Re: [PATCH 1/5]: Shorten variable names in dccp_check_seqno
Message-Id: <5640c7e00706302054m5620368cl541bab40b04f47c1@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 6/20/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> [DCCP]: Shorten variable names in dccp_check_seqno
>
> This patch is in part required by the next patch; it
>
>  * replaces 6 instances of `DCCP_SKB_CB(skb)->dccpd_seq' with `seqno';
>  * replaces 7 instances of `DCCP_SKB_CB(skb)->dccpd_ack_seq' with `ackno';
>  * replaces 1 use of dccp_inc_seqno() by unfolding `ADD48' macro in place.
>
> No changes in algorithm, all changes are text replacement/substitution.
>
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
> ---
>  net/dccp/input.c |   40 +++++++++++++++++-----------------------
>  1 file changed, 17 insertions(+), 23 deletions(-)
>
> --- a/net/dccp/input.c
> +++ b/net/dccp/input.c
> @@ -68,7 +68,8 @@ static int dccp_check_seqno(struct sock
>  {
>         const struct dccp_hdr *dh = dccp_hdr(skb);
>         struct dccp_sock *dp = dccp_sk(sk);
> -       u64 lswl, lawl;
> +       u64 lswl, lawl, seqno = DCCP_SKB_CB(skb)->dccpd_seq,
> +                       ackno = DCCP_SKB_CB(skb)->dccpd_ack_seq;
>
I think this would be better served by a macro e.g.
#define SEQNO DCCP_SKB_CB(skb)->dccpd_seq

With the change you're making here you're increasing stack usage by 16 bytes.

Ian
-- 
Web: http://wand.net.nz/~iam4/
Blog: http://iansblog.jandi.co.nz
WAND Network Research Group
