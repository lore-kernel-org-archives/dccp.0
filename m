From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Tue, 25 Sep 2007 22:53:02 +0000
Subject: Re: [PATCH 3/8]: Remove duplicate code for Reset from connected socket
Message-Id: <5640c7e00709251553k661f2a74xe674743666e175b8@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200709251530.21163@strip-the-willow>
In-Reply-To: <200709251530.21163@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 9/26/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> [DCCP]: Remove duplicate code for Reset from connected socket
>
> In this patch, duplicated code is removed for the case when a Reset packet is
> sent from a connected socket. This code duplication is between dccp_make_reset
> and dccp_transmit_skb, which already contained an (up to now entirely unused)
> switch statement to fill in the reset code from the DCCP_SKB_CB.
>
> The only thing that has been removed is the call to dst_clone(dst), since
> the queue_xmit functions use sk_dst_cache anyway.
>
> I wasn't sure which purpose inet_sk_rebuild_header served, so I left it in.
>
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>

Haven't studied in great depth but looks right.
Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
-- 
Web1: http://wand.net.nz/~iam4/
Web2: http://www.jandi.co.nz
Blog: http://iansblog.jandi.co.nz
