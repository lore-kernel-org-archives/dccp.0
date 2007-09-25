From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Tue, 25 Sep 2007 23:02:30 +0000
Subject: Re: [PATCH 6/8]: Add (missing) option parsing to request_sock processing
Message-Id: <5640c7e00709251602p26c58dber747d0529f5ffb07d@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200709251530.45192@strip-the-willow>
In-Reply-To: <200709251530.45192@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 9/26/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> [DCCP]: Add (missing) option parsing to request_sock processing
>
> This adds option-parsing code to processing of Acks in the listening state
> on request_socks on the server, serving two purposes
>  (i)  resolves a FIXME (removed);
>  (ii) paves the way for feature-negotiation during connection-setup.
>
> There is an intended subtlety here with regard to dccp_check_req:
>
>  Parsing options happens only after testing whether the received packet is
>  a retransmitted Request.  Otherwise, if the Request contained (a possibly
>  large number of) feature-negotiation options, recomputing state would have to
>  happen each time a retransmitted Request arrives, which opens the door to an
>  easy DoS attack.  Since in a genuine retransmission the options should not be
>  different from the original, reusing the already computed state seems better.
>
>  The other point is - if there are timestamp options on the Request, they will
>  not be answered; which means that in the presence of retransmission (likely
>  due to loss and/or other problems), the use of Request/Response RTT sampling
>  is suspended, so that startup problems here do not propagate.
>
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>

Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
-- 
Web1: http://wand.net.nz/~iam4/
Web2: http://www.jandi.co.nz
Blog: http://iansblog.jandi.co.nz
