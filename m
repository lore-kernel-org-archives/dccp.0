From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 08 Nov 2007 10:21:44 +0000
Subject: Re: [PATCH 11/25] Share TFRC sender states via tfrc_ccids
Message-Id: <20071108102144.GC11792@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <200710312131.03012.leandroal@gmail.com>
In-Reply-To: <200710312131.03012.leandroal@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

| @@ -76,16 +76,16 @@ static const char *ccid4_tx_state_name(e
|  #endif
|  
|  static void ccid4_hc_tx_set_state(struct sock *sk,
| -				  enum ccid4_hc_tx_states state)
| +				  enum tfrc_hc_tx_states state)
|  {
|  	struct ccid4_hc_tx_sock *hctx = ccid4_hc_tx_sk(sk);
| -	enum ccid4_hc_tx_states oldstate = hctx->ccid4hctx_state;
| +	enum tfrc_hc_tx_states oldstate = hctx->tfrchctx_state;
|  
|  	ccid4_pr_debug("%s(%p) %-8.8s -> %s\n",
|  		       dccp_role(sk), sk, ccid4_tx_state_name(oldstate),
|  		       ccid4_tx_state_name(state));
|  	WARN_ON(state = oldstate);
| -	hctx->ccid4hctx_state = state;
| +	hctx->tfrchctx_state = state;
|  }
|  
I think this function is a candidate for sharing: no need to keep
this function separate for CCID3/4 when both use the same enum of
states; i.e. the function could be written tfrc_hc_tx_set_state().
