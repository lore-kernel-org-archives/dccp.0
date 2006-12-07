From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Thu, 07 Dec 2006 22:01:28 +0000
Subject: Re: [Patch 4/12]: In-line ccid3_hc_tx_insert_options
Message-Id: <5640c7e00612071401t13a04fefwd793840fc7c8fa24@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200612072112.46742@strip-the-willow>
In-Reply-To: <200612072112.46742@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 12/8/06, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> [CCID 3]: In-line ccid3_hc_tx_insert_options
>
> The function ccid3_hc_tx_insert_options currently only does a no-op,
> since the operation
>
>   DCCP_SKB_CB(skb)->dccpd_ccval = hctx->ccid3hctx_last_win_count;
>
> is already performed _unconditionally_ in ccid3_hc_tx_send_packet.
>
> This redundancy is removed and the remaining stub function inlined.
>
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>

Gerrit,

A couple of points here:
- the whole ccid3_hc_tx_insert_options could actually be removed with
a little work as there is no ccid2 equivalent and so the whole thing
isn't needed! If you want I can tidy that one up or up to you.
- don't inline functions - at the moment people are saying let gcc
decide when to do it - see comments in linus' git tree recently.

Ian
-- 
Web: http://wand.net.nz/~iam4
Blog: http://imcdnzl.blogspot.com
WAND Network Research Group
