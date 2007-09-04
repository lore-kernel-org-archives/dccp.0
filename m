From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Tue, 04 Sep 2007 01:24:50 +0000
Subject: Re: [PATCH 4/6] DCCP: Add framework for faster restart
Message-Id: <5640c7e00709031824w1ab3db27tfaaa386daa96fd32@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200708291136.19130.ian.mcdonald@jandi.co.nz>
In-Reply-To: <200708291136.19130.ian.mcdonald@jandi.co.nz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 8/30/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> I think a small optimisation is possible below:
>
> |  +static int ccid3_hc_rx_setsockopt(struct sock *sk, const int optname,
> |  +                              int val, int optlen)
> |  +{
> |  +    struct ccid3_hc_rx_sock *hcrx = ccid3_hc_rx_sk(sk);
> |  +
> |  +    /* Listen socks don't have a private CCID block */
> |  +    if (sk->sk_state = DCCP_LISTEN)
> |  +            return -EINVAL;
> This check appears now 6 times in the CCID3 code. I think it could be moved to
> the wrapper functions ccid_hc_{t,r}x_getsockopt and - with regard to your previous patch -
> to ccid_hc_{t,r}x_setsockopt.
>
I've tidied this up a bit and will resubmit once I finish fixing faster restart.

> What I am working on is resolving this "Listen socks don't have a private CCID block" business,
> i.e. trying to get away from passing all the CCID control blocks to the control socket and let
> the connection do the negotiation.

Cool

-- 
Web1: http://wand.net.nz/~iam4/
Web2: http://www.jandi.co.nz
Blog: http://iansblog.jandi.co.nz
