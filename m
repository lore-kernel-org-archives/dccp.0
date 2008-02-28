From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 28 Feb 2008 09:53:33 +0000
Subject: Re: [PATCH 3/4] [CCID2]: Replace broken RTT estimator with better algorithm
Message-Id: <20080228095333.GA4730@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <1204122188-9984-4-git-send-email-gerrit@erg.abdn.ac.uk>
In-Reply-To: <1204122188-9984-4-git-send-email-gerrit@erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

| >  +                * Decay RTTVAR at most once per flight, exploiting that
| >  +                *  1) pipe <= cwnd <= Sequence_Window = W  (RFC 4340, 7.5.2)
| >  +                *  2) AWL = GSS-W+1 <= GAR <= GSS          (RFC 4340, 7.5.1)
| >  +                * GAR is a useful bound for FlightSize = pipe, AWL is probably
| >  +                * too low as it over-estimates pipe.
| >  +                */
| >  +               if (after48(dccp_sk(sk)->dccps_gar, hctx->ccid2hctx_rtt_seq)) {
| >  +                       if (hctx->ccid2hctx_mdev_max < hctx->ccid2hctx_rttvar)
| >  +                               hctx->ccid2hctx_rttvar -= (hctx->ccid2hctx_rttvar - hctx->ccid2hctx_mdev_max) >> 2;
| 
| More than 80 chars in this line! 87 chars. Is this ok?
| 
There are actually 120 characters in this line. The 80-characters constraint
has become a recommendation, i.e. it is possible and legal to make exceptions.
I kept it in to allow a better comparison to the original TCP code.

If anything, it shows how the ubiquitous `hctx->ccid?hctx_' prefixes make
it hard to read the code.
