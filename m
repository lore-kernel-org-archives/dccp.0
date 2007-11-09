From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 09 Nov 2007 14:16:09 +0000
Subject: Re: [PATCH 4/25] Set packet size to 1460 as per ccid-4 draft
Message-Id: <20071109141609.GA23706@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <200710312129.57873.leandroal@gmail.com>
In-Reply-To: <200710312129.57873.leandroal@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

| |  	if (hctx->ccid4hctx_p > 0)
| | -		hctx->ccid4hctx_x_calc = tfrc_calc_x(hctx->ccid4hctx_s,
| | +		hctx->ccid4hctx_x_calc = tfrc_calc_x(NOM_PACKET_SIZE,
| |  						     hctx->ccid4hctx_rtt,
| |  						     hctx->ccid4hctx_p);
<snip>
| The above code is CCID3 with the difference that s = 1460. To better
| share the code between CCID3/4, I think it would be simpler to
| initialise `s' with this value, and to dispense with the `update_s'
| routine that CCID3 uses.
| 
| Like, for example in ccid4_hc_tx_init:
| 	{
| 		/* ... */
| 		hctx->ccid4hctx_s = NOM_PACKET_SIZE;
| 
| 	}
| 
| Then one could consider sharing tx_packet_recv code.
Nope. The above is nonsense, I've just realised the way `s' is used, so
the comment does not really apply, please forget that.

Using the moving-average as in CCID3, as you do, is probably a good
idea, since when the packet size is varied in response to congestion
the spikes will be smoothed out be the earlier averages.
