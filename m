From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 08 Nov 2007 11:04:13 +0000
Subject: Re: [PATCH 4/25] Set packet size to 1460 as per ccid-4 draft
Message-Id: <20071108110413.GB15246@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <200710312129.57873.leandroal@gmail.com>
In-Reply-To: <200710312129.57873.leandroal@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Quoting Leandro:
| [CCID-4] Set packet size to 1460 as per ccid-4 draft
| 
| Signed-off-by: Leandro Melo de Sales <leandro@embedded.ufcg.edu.br>
| Signed-off-by: Tommi Saviranta <wnd@iki.fi>
| 
| Index: leandro.new/net/dccp/ccids/ccid4.c
| =================================| --- leandro.new.orig/net/dccp/ccids/ccid4.c
| +++ leandro.new/net/dccp/ccids/ccid4.c
| @@ -472,9 +472,9 @@ static void ccid4_hc_tx_packet_recv(stru
|  			goto done_computing_x;
|  		}
|  	}
| -	/* perform step (4) of draft rfc3448bis, section 4.3 */
| +        /* Update sending rate (step 4 of [RFC 3448, 4.3]) */
|  	if (hctx->ccid4hctx_p > 0)
| -		hctx->ccid4hctx_x_calc = tfrc_calc_x(hctx->ccid4hctx_s,
| +		hctx->ccid4hctx_x_calc = tfrc_calc_x(NOM_PACKET_SIZE,
|  						     hctx->ccid4hctx_rtt,
|  						     hctx->ccid4hctx_p);
|  	ccid4_hc_tx_update_x(sk, &now);
| @@ -775,7 +775,7 @@ static u32 ccid4_first_li(struct sock *s
|  		}
|  	}
|  
| -	fval = scaled_div(hcrx->ccid4hcrx_s, hcrx->ccid4hcrx_rtt);
| +	fval = scaled_div(NOM_PACKET_SIZE, hcrx->ccid4hcrx_rtt);
|  	fval = scaled_div32(fval, x_recv);
|  	p = tfrc_calc_x_reverse_lookup(fval);
|  
| Index: leandro.new/net/dccp/ccids/ccid4.h
| =================================| --- leandro.new.orig/net/dccp/ccids/ccid4.h
| +++ leandro.new/net/dccp/ccids/ccid4.h
| @@ -65,6 +65,9 @@
|  /* Parameter t_mbi from [RFC 3448, 4.3]: backoff interval in seconds */
|  #define TFRC_T_MBI		   64
|  
| +/* The nominal packet size to be used into TFRC equation as per CCID-4 draft*/
| +#define NOM_PACKET_SIZE            1460
| +
|  enum ccid4_options {
|  	TFRC_OPT_LOSS_EVENT_RATE = 192,
|  	TFRC_OPT_LOSS_INTERVALS	 = 193,
| -
The above code is CCID3 with the difference that s = 1460. To better
share the code between CCID3/4, I think it would be simpler to
initialise `s' with this value, and to dispense with the `update_s'
routine that CCID3 uses.

Like, for example in ccid4_hc_tx_init:
	{
		/* ... */
		hctx->ccid4hctx_s = NOM_PACKET_SIZE;

	}

Then one could consider sharing tx_packet_recv code.
