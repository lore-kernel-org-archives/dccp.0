From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 27 Nov 2006 11:17:44 +0000
Subject: Re: NAK Re: [PATCH 4/10]: Consolidate timer resets
Message-Id: <200611271117.44403@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <5640c7e00611261243k34ef8d72m7e8462e461f1e71@mail.gmail.com>
In-Reply-To: <5640c7e00611261243k34ef8d72m7e8462e461f1e71@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Ian,

thank you for checking this. RFC 3448 is contradictory, since step (3)
of section 4.3 instructs to use R which is undefined by section 4.2.
 
Please see below.

|  On 11/25/06, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
|  > [CCID 3]: Consolidate timer resets
|  >
|  > The specification in [RFC 3448, 4.4, step (3)] is impossible to
|  > implement: when no feedback has been received, the value of RTT
|  > is undefined as per [RFC 3448, 4.2]. Hence we can not set the
|  > timeout value to max(4*R, 2*s/X) as step (3) suggests.
|  >
|  > The most reasonable solution is to remain at the initial timeout
|  > value of 2 seconds, as per [RFC 3448, 4.2] - until an estimate
|  > for R has been computed.
|  
|  But RFC4342 says:
|  If the sender hasn't
|     received a feedback packet from the receiver when the nofeedback
|     timer expires, then the sender halves its allowed sending rate.  The
|     allowed sending rate is never reduced below one packet per 64
|     seconds.  Note that not all acknowledgements are considered feedback
|     packets, since feedback packets must contain valid Loss Intervals,
|     Elapsed Time, and Receive Rate options.
|  
|     If the sender never receives a feedback packet from the receiver, and
|     as a consequence never gets to set the allowed sending rate to one
|     packet per RTT, then the sending rate is left at its initial rate of
|     one packet per second, with the nofeedback timer expiring after two
|     seconds.
I see - so this gives some evidence that if we don't get any feedback, we leave
the timeout of the nofeedback timer at the (initial) value of 2 seconds.
This means that the commit message and comments I provided were wrong, while
the patch actually does the right thing with regard to the above. I will
resend an updated patch.

Gerrit
