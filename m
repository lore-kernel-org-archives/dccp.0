From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 19 Jun 2007 16:08:54 +0000
Subject: Re: [PATCH 1/1][BUG-Fix]: Allocation in atomic context
Message-Id: <200706191708.54793@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200706191131.15251@strip-the-willow>
In-Reply-To: <200706191131.15251@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: dccp@vger.kernel.org

Quoting Arnaldo Carvalho de Melo:
|  > @@ -298,7 +298,7 @@ static void ccid2_hc_tx_packet_sent(stru
|  >                 int rc;
|  >
|  >                 ccid2_pr_debug("allocating more space in history\n");
|  > -               rc = ccid2_hc_tx_alloc_seq(hctx, CCID2_SEQBUF_LEN, GFP_KERNEL);
|  > +               rc = ccid2_hc_tx_alloc_seq(hctx, CCID2_SEQBUF_LEN, gfp_any());
|  >                 BUG_ON(rc); /* XXX what do we do? */
|  >
|  >                 next = hctx->ccid2hctx_seqh->ccid2s_next;
|  
|  This one is better than the one I came up with, will use it. But ccid2
|  needs a major rework, the BUG_ON that appears here is horrendous!
Agree but didn't feel competent to make a better suggestion. One idea that comes to
mind is

	/* check if we need to alloc more space */
	if (next = hctx->ccid2hctx_seqt) {
			if (ccid2_hc_tx_alloc_seq(...))	{
				DCCP_CRIT("can not allocate");
				return;
			}
			// ...
	}


I wonder if it is possible to integrate with the TFRC list - but just made that
one singly-linked.
