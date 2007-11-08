From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 08 Nov 2007 11:27:36 +0000
Subject: Re: [PATCH 9/25] Adapt CCID-4 according to the latest changes to CCID-3
Message-Id: <20071108112736.GE15246@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <200710312130.35629.leandroal@gmail.com>
In-Reply-To: <200710312130.35629.leandroal@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

|  static inline struct ccid4_hc_tx_sock *ccid4_hc_tx_sk(const struct sock *sk)
|  {
| -	void *ccid4_tx_priv = ccid_priv(dccp_sk(sk)->dccps_hc_tx_ccid);
| -
| -	BUG_ON(ccid4_tx_priv = NULL);
| -	return ccid4_tx_priv;
| +    struct ccid4_hc_tx_sock *hctx = ccid_priv(dccp_sk(sk)->dccps_hc_tx_ccid);
| +    BUG_ON(hctx = NULL);
| +    return hctx;

| @@ -177,10 +176,9 @@ struct ccid4_hc_rx_sock {
|  
|  static inline struct ccid4_hc_rx_sock *ccid4_hc_rx_sk(const struct sock *sk)
|  {
| -	void *ccid4_rx_priv = ccid_priv(dccp_sk(sk)->dccps_hc_rx_ccid);
| -
| -	BUG_ON(ccid4_rx_priv = NULL);
| -	return ccid4_rx_priv;
| +    struct ccid4_hc_rx_sock *hcrx = ccid_priv(dccp_sk(sk)->dccps_hc_rx_ccid);
| +    BUG_ON(hcrx = NULL);
| +    return hcrx;

Two instances of re-indenting - also fixed.
