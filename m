From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Sun, 26 Nov 2006 20:43:09 +0000
Subject: NAK Re: [PATCH 4/10]: Consolidate timer resets
Message-Id: <5640c7e00611261243k34ef8d72m7e8462e461f1e71@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 11/25/06, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> [CCID 3]: Consolidate timer resets
>
> The specification in [RFC 3448, 4.4, step (3)] is impossible to
> implement: when no feedback has been received, the value of RTT
> is undefined as per [RFC 3448, 4.2]. Hence we can not set the
> timeout value to max(4*R, 2*s/X) as step (3) suggests.
>
> The most reasonable solution is to remain at the initial timeout
> value of 2 seconds, as per [RFC 3448, 4.2] - until an estimate
> for R has been computed.

But RFC4342 says:
If the sender hasn't
   received a feedback packet from the receiver when the nofeedback
   timer expires, then the sender halves its allowed sending rate.  The
   allowed sending rate is never reduced below one packet per 64
   seconds.  Note that not all acknowledgements are considered feedback
   packets, since feedback packets must contain valid Loss Intervals,
   Elapsed Time, and Receive Rate options.

   If the sender never receives a feedback packet from the receiver, and
   as a consequence never gets to set the allowed sending rate to one
   packet per RTT, then the sending rate is left at its initial rate of
   one packet per second, with the nofeedback timer expiring after two
   seconds.  The allowed sending rate is halved each time the nofeedback
   timer expires.  Thus, if no feedback is received from the receiver,
   the allowed sending rate is never above one packet per second and is
   quickly reduced below one packet per second.
-- 
Ian McDonald
Web: http://wand.net.nz/~iam4
Blog: http://imcdnzl.blogspot.com
WAND Network Research Group
Department of Computer Science
University of Waikato
New Zealand
