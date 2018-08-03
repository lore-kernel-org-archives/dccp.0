From: David Miller <davem@davemloft.net>
Date: Fri, 03 Aug 2018 20:36:39 +0000
Subject: Re: [PATCH net] dccp: fix undefined behavior with 'cwnd' shift in ccid2_cwnd_restart()
Message-Id: <20180803.133639.1730093521545082783.davem@davemloft.net>
List-Id: <dccp.vger.kernel.org>
References: <1533226925-16783-1-git-send-email-alexey.kodanev@oracle.com>
In-Reply-To: <1533226925-16783-1-git-send-email-alexey.kodanev@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Alexey Kodanev <alexey.kodanev@oracle.com>
Date: Thu,  2 Aug 2018 19:22:05 +0300

> Make sure that the value of "(now - hc->tx_lsndtime) / hc->tx_rto" is
> properly limited when shifting 'u32 cwnd' with it, otherwise we can get:
 ...
> Fixes: 113ced1f52e5 ("dccp ccid-2: Perform congestion-window validation")
> Signed-off-by: Alexey Kodanev <alexey.kodanev@oracle.com>
 ...
> @@ -234,7 +234,7 @@ static void ccid2_cwnd_restart(struct sock *sk, const u32 now)
>  
>  	/* don't reduce cwnd below the initial window (IW) */
>  	restart_cwnd = min(cwnd, iwnd);
> -	cwnd >>= (now - hc->tx_lsndtime) / hc->tx_rto;
> +	cwnd >>= min((now - hc->tx_lsndtime) / hc->tx_rto, 31U);
>  	hc->tx_cwnd = max(cwnd, restart_cwnd);
>  
>  	hc->tx_cwnd_stamp = now;

Better to mimick the TCP cwnd validation code, something like:

	s32 delta = now - hc->tx_lsndtime;
	while ((delta -= hc->tx_rto) > 0 && cwnd > restart_cwnd)
		cwnd >>= 1;

Thanks.
