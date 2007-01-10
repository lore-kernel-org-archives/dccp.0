From: Eddie Kohler <kohler@cs.ucla.edu>
Date: Wed, 10 Jan 2007 17:03:25 +0000
Subject: Re: CCID 3 question: length of the `open' loss interval I_0
Message-Id: <45A51C5D.6020101@cs.ucla.edu>
List-Id: <dccp.vger.kernel.org>
References: <200701091321.00592@strip-the-willow>
In-Reply-To: <200701091321.00592@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hi Gerrit,

Strictly speaking one can identify a loss event with a single ECN-marked 
packet, so I_0 might be < 3, but let that pass.  The RFC occasionally 
uses "lost" to mean "lost or marked".

The correct answer is simply to subtract X_prev from the sequence number 
of the currently received packet.  This is certainly what we were 
thinking while writing RFC4342, although I don't have time now to check 
whether the text actually defines this explicitly.

I'm almost certain but am cc'ing the IETF list for possible correction.

Among the reasons for this choice is that if you measure it the other 
way, I_0 will use different units from every other loss interval length.

However, to be honest, I'd say that RFC3448 appears to define it as 
"number of packets received since last loss event".  I think this is a 
misstatement in RFC3448 and should be considered for fixing in 
RFC3448bis.  Every other loss interval is defined as a length in 
sequence space INCLUDING lost and marked packets (RFC3448 5.3).  There 
seems no reason to EXCLUDE lost and marked packets for I_0; this might 
lead to weird rate hiccups where the TFRC rate INCREASED after a loss 
(because I_0 got longer when it became I_1)!  I would define I_0 as "the 
most recent interval, which includes the most recent loss event and all 
packets thereafter" (5.4), and say later that I_0 "includes the packets 
received since the last loss event" (rather than REPRESENTS the number 
of packets received since the last loss event) (5.5).

Eddie




Gerrit Renker wrote:
> Eddie, 
> 
> sorry to trouble you with yet another question, but it is extremely important to get this
> right. This concerns the length of I_0, the interval since the most recent loss event.
> 
> In the current implementation, we are relying on the highest sequence numbers received
> before a loss occurred. Using the terminology from [RFC 4342, 10.2], this corresponds
> to X_prev and Y_prev.
> 
> For subsequent loss intervals (assuming that more than 1 RTT lies between X_prev/Y_prev),
> we can compute the loss interval length [RFC 3448, 5.3] as modulo-2^48 distance between
> X_prev and Y_prev.
> ( Strictly speaking, the first packet known to be lost - starting the loss event - 
>   has sequence number (X_prev + 1) % 2^48. Since the next loss event begins at sequence 
>   number (Y_prev + 1) % 2^48, the distance is however the same as from X_prev to Y_prev. )
> 
> With the open loss interval I_0, however, the situation is different. In [RFC 3448, 5.5],
> I_0 is defined as "the number of packets received since the last loss event". Taking this 
> literally means the following:
> 
>   * at the instant this loss is detected,              I_0 = 3 
>     (since NUMDUPACK=3 packets need to be received to identify a loss event)
>   * when the first data packet after the loss arrives, I_0 = 4,
>   * when the i-th  data packet after the loss arrives, I_0 = 3 + i
>   * ... and so on until the next loss is detected 
> 
> Question: Is this reasoning correct, or is the intention to determine the number of 
>           data packets in I_0 by using X_prev and simply subtracting X_prev from the
>           sequence number of the currently received packet (modulo 2^48)? 
>           
> 
> The first variant seems to be conform with the RFC, the latter is conform with the way 
> the other loss intervals are computed.
> 
> Resolving this will help to clear up the loss detection algorithm we are currently using.
> 
> Gerrit
