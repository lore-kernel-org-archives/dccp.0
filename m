From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 30 Aug 2007 07:41:33 +0000
Subject: Re: [PATCH 4/6] DCCP: Add framework for faster restart
Message-Id: <200708300841.33113@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200708291136.19130.ian.mcdonald@jandi.co.nz>
In-Reply-To: <200708291136.19130.ian.mcdonald@jandi.co.nz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

|  Set up options for enabling TFRC options. Also add variables for faster
|  restart.
|  
|  Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>

I think a small optimisation is possible below:

|  +static int ccid3_hc_rx_setsockopt(struct sock *sk, const int optname,
|  +				  int val, int optlen)
|  +{
|  +	struct ccid3_hc_rx_sock *hcrx = ccid3_hc_rx_sk(sk);
|  +
|  +	/* Listen socks don't have a private CCID block */
|  +	if (sk->sk_state = DCCP_LISTEN)
|  +		return -EINVAL;
This check appears now 6 times in the CCID3 code. I think it could be moved to
the wrapper functions ccid_hc_{t,r}x_getsockopt and - with regard to your previous patch -
to ccid_hc_{t,r}x_setsockopt.

What I am working on is resolving this "Listen socks don't have a private CCID block" business,
i.e. trying to get away from passing all the CCID control blocks to the control socket and let
the connection do the negotiation.
