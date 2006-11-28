From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Tue, 28 Nov 2006 19:23:19 +0000
Subject: Re: [PATCH 0/2] [RFC]: Clean-ups
Message-Id: <5640c7e00611281123y37c57502h98e3d45677228a41@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200611281430.01278@strip-the-willow>
In-Reply-To: <200611281430.01278@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

> Patch 1: Removes a typo in setting the nofeedback timer.
>          => Question: The nofeedback timer is currently set to time out after
>
>                            max(t_rto, 2 * s/X)  =  max(max(4*R, 1 second), 2 *s/X)
>
>                        This is non-standard and has been flagged in the code as such
>              I have conferred with a colleague who does a lot of simulations in this
>              field and he says doing this is bad, especially when the RTTs are small.
>              Therefore, since it is both non-standard and obviously not a good idea,
>              I want to suggest revising the entire patch so that the nofeedback timer
>              expires after max(4*R, 2 * s/X) as per RFC 3448.
>              OK with this suggestion?
>
The code here predates me but I think the reason for it might be to do
with RFC4342 (remember to read 3448 in conjunction with this).

   If the sender never receives a feedback packet from the receiver, and
   as a consequence never gets to set the allowed sending rate to one
   packet per RTT, then the sending rate is left at its initial rate of
   one packet per second, with the nofeedback timer expiring after two
   seconds.  The allowed sending rate is halved each time the nofeedback
   timer expires.  Thus, if no feedback is received from the receiver,
   the allowed sending rate is never above one packet per second and is
   quickly reduced below one packet per second.

NB I'm not saying the old code is correct - I'm just guessing that the
above is reason for it... Your thoughts Gerrit? (I haven't re-read the
code or checked any of it out properly)

Ian
-- 
Ian McDonald
Web: http://wand.net.nz/~iam4
Blog: http://imcdnzl.blogspot.com
WAND Network Research Group
Department of Computer Science
University of Waikato
New Zealand
