From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 28 Nov 2006 19:32:12 +0000
Subject: Re: [PATCH 0/2] [RFC]: Clean-ups
Message-Id: <200611281932.13250@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200611281430.01278@strip-the-willow>
In-Reply-To: <200611281430.01278@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Quoting Ian McDonald:
|  > The code here predates me but I think the reason for it might be to do
|  > with RFC4342 (remember to read 3448 in conjunction with this).
|  >
|  >    If the sender never receives a feedback packet from the receiver, and
|  >    as a consequence never gets to set the allowed sending rate to one
|  >    packet per RTT, then the sending rate is left at its initial rate of
|  >    one packet per second, with the nofeedback timer expiring after two
|  >    seconds.  The allowed sending rate is halved each time the nofeedback
|  >    timer expires.  Thus, if no feedback is received from the receiver,
|  >    the allowed sending rate is never above one packet per second and is
|  >    quickly reduced below one packet per second.
|  >
|  > NB I'm not saying the old code is correct - I'm just guessing that the
|  > above is reason for it... Your thoughts Gerrit? (I haven't re-read the
|  > code or checked any of it out properly)
|  >
|  Just realised I didn't explain what I actually meant. I'm wondering
|  whether initially no feedback timer was used to maintain 1 packet per
|  second (which is the wrong way to do it).
I checked RFC 4342 again - there is no news with regard to RFC 3448. And in RFC 3448
it is in the way suggested - use max(4*R, 2*s/X). I think it is better to use this
value, as described.

There is a lot of cruft from the old code. I would like to go over that - I have been
studying older FreeBSD patches and now see the relationships.
