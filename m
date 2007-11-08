From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 08 Nov 2007 10:28:14 +0000
Subject: Re: [PATCH 16/25] Share ccid3_hc_rx_sock struct and ccid3_hc_rx_sk function via tfrc_ccids
Message-Id: <20071108102814.GE11792@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <200710312131.50615.leandroal@gmail.com>
In-Reply-To: <200710312131.50615.leandroal@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

| +static inline struct tfrc_hc_rx_sock *tfrc_hc_rx_sk(const struct sock *sk)
| +{
| +    struct tfrc_hc_rx_sock *hcrx = ccid_priv(dccp_sk(sk)->dccps_hc_rx_ccid);
| +    BUG_ON(hcrx = NULL);
| +    return hcrx;
| +}
Whitespace issue (the same problem is in the original where it was
copied from) -- should have tabs at the start, not 4 blanks.
