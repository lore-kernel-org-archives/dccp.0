From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Mon, 26 Mar 2007 02:56:30 +0000
Subject: Re: [PATCH 8/25]: Honour initial RTT estimate
Message-Id: <5640c7e00703251956n56eef3c5kaf9ed80c20a02551@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200703211844.44041@strip-the-willow>
In-Reply-To: <200703211844.44041@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 3/22/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> [CCID 3]: Honour initial RTT estimate
>
> This is a small optimisation which improves the accuracy of TX
> RTT sampling when an initial RTT sample (e.g. from the intial
> Request/Response exchange) is available.
>
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
> ---
>  net/dccp/ccids/ccid3.c |   13 ++++++-------
>  1 file changed, 6 insertions(+), 7 deletions(-)
>
> --- a/net/dccp/ccids/ccid3.c
> +++ b/net/dccp/ccids/ccid3.c
> @@ -469,28 +469,29 @@ static void ccid3_hc_tx_packet_recv(stru
>                 else                                   /* can not exceed 100% */
>                         hctx->ccid3hctx_p = 1000000 / pinv;
>
> -               skb_get_timestamp(skb, &now);
> -
>                 /*
>                  * Calculate new round trip sample as per [RFC 3448, 4.3] by
>                  *      R_sample  =  (now - t_recvdata) - t_elapsed
>                  */
> +               skb_get_timestamp(skb, &now);

I can see how that optimises - shifting after the comment ;-)

Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
-- 
Web: http://wand.net.nz/~iam4
Blog: http://iansblog.jandi.co.nz
WAND Network Research Group
