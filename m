From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 08 Nov 2007 10:15:23 +0000
Subject: Re: [PATCH 6/25] Reduce allowed sending rate by a factor that accounts for packet header size
Message-Id: <20071108101523.GB11792@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <200710312130.18806.leandroal@gmail.com>
In-Reply-To: <200710312130.18806.leandroal@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

| @@ -170,6 +181,7 @@ static void ccid4_hc_tx_update_x(struct 
|  		hctx->ccid4hctx_x = max(hctx->ccid4hctx_x,
|  					(((__u64)hctx->ccid4hctx_s) << 6) /
|  								TFRC_T_MBI);
| +                ccid4_hc_tx_x_header_penalty(hctx);
|  
|  	} else if (ktime_us_delta(now, hctx->ccid4hctx_t_ld)
|  				- (s64)hctx->ccid4hctx_rtt >= 0) {
| @@ -178,6 +190,8 @@ static void ccid4_hc_tx_update_x(struct 
|  			max(min(2 * hctx->ccid4hctx_x, min_rate),
|  			    scaled_div(((__u64)hctx->ccid4hctx_s) << 6,
|  				       hctx->ccid4hctx_rtt));
| +
| +                ccid4_hc_tx_x_header_penalty(hctx);
|  		hctx->ccid4hctx_t_ld = now;
|  	}
Since ccid4_hc_tx_x_header_penalty() is called in both the if/else
branches, it looks to me that you can put it before the if/else. 
If you then wanted to abstract this function, it looks as if a wrapper
could be used:

	ccid4_hc_tx_update_x(hctx) 
	{
                ccid4_hc_tx_x_header_penalty(hctx);
		tfrc_hc_tx_update_x(...);
	}

Makes sense?
