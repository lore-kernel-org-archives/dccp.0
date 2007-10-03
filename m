From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Wed, 03 Oct 2007 20:00:01 +0000
Subject: Re: [PATCH 5/14]: Clean up remains from old feature-negotiation infrastructure
Message-Id: <5640c7e00710031300l76624ab2u49000066b75c1d32@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200710031502.38598@strip-the-willow>
In-Reply-To: <200710031502.38598@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 10/4/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> [DCCP]: Clean up remains from old feature-negotiation infrastructure
>
> The code removed by this patch is no longer referenced or used, the added
> lines update documentation and copyrights.
>
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>

Your code doesn't quite match your description as removing one line of
code from a function. I'm assuming this is OK but raising it just in
case.

Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>

> --- a/net/dccp/proto.c
> +++ b/net/dccp/proto.c
> @@ -234,7 +234,6 @@ int dccp_destroy_sock(struct sock *sk)
>         dp->dccps_hc_rx_ccid = dp->dccps_hc_tx_ccid = NULL;
>
>         /* clean up feature negotiation state */
> -       dccp_feat_clean(dmsk);
>         dccp_feat_list_purge(&dp->dccps_featneg);
>
>         return 0;
> -


-- 
Web1: http://wand.net.nz/~iam4/
Web2: http://www.jandi.co.nz
Blog: http://iansblog.jandi.co.nz
