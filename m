From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Thu, 08 Dec 2005 21:40:47 +0000
Subject: Re: initial CCID2 implementation for linux
Message-Id: <39e6f6c70512081340w12541288y8b2a4e222fb53817@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <20051206190131.GA834@tribal.sorbonet.org>
In-Reply-To: <20051206190131.GA834@tribal.sorbonet.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 12/6/05, Andrea Bittau <a.bittau@cs.ucl.ac.uk> wrote:
> http://darkircop.org/acme-ccid2-20051206.diff
>
> it's a diff from today's:
> git/acme/net-2.6.16.git
>
> To use it, you need to compile support for ack vectors and:
> setsockopt DCCP_SOCKOPT_CCID_RX and DCCP_SOCKOPT_CCID_TX to 2.
>
>
> CCID2 status:
>
> * Standard TCP congestion control:
>   - AIMD of cwnd, slow start etc.
>
> * RTO timeouts:
>   - Maintains RTT estimate and calculates RTO from that.
>   - Doesn't support timestamp option.
>
> * Ack ratios [reverse path congestion control]:
>   - Supported by "infrastructure"
>   - Missing feature negotiation, so no ack ratio change.
>
> * ECN:
>   - Correctly adjusts cwnd when packets are reported ECN marked.
>   - Doesn't deal with ECN nonces.
>   - No ECN support for reverse path congestion [receiving ECN marked ACK].
>
> * No support for determining that flows go silent [ack an ack stuff].
>
>
> I need to make the code solid and linux friendly.  Then I will split the patch
> so hopefully arnaldo will agree to commit it.  It currently includes, and will
> be split to:

I'm more than willing to merge your stuff :-)

>
> * connect() race condition:
>   Connect, send and disconnect real fast.  I don't remember details but,
>   The socket will be transiting from SS_CONNECTING to SS_CONNECTED.  However,
>   connect will return -1 because DCCP will have moved to CLOSE by the time
>   connect() checks status.
>
> * disconnect doesn't cleanup state:
>   server sends close req.  Client doesn't reply with close "fast enough".
>   Server will never destroy socket.  I still gotta think about this more though.
>
> * support for ack vector records
>
> * support for switching ccids
>
> * support for ccid2
>
>
> Any feedback is appreciated.  Specifically, if this code looks "promising" [i.e.
> eventually commitable], it would be nice if someone can indicate the major

It looks promising, yes :-)

> problems with it. [coding style, way of doing things, bugs, etc]
>
> I'll now work on making the code more solid and splitting the patches.

I look forward, I've been away from kernel development due to "Real
Work" and "Real Life" "getting in the way", but I'm adjusting my work
schedule to allow me to dedicate time to at least merge and comment on
these patches that are flowing in recently, excellent news indeed,
keep it up!

- Arnaldo
