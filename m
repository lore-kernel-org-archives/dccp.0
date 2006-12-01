From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 01 Dec 2006 13:52:11 +0000
Subject: Re: [PATCH] [DCCP]: Use higher timeout value for nofeedback timer
Message-Id: <200612011352.12245@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200611301318.46685@strip-the-willow>
In-Reply-To: <200611301318.46685@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Quoting Mark Handley:
|  On 12/1/06, Colin Perkins <csp@csperkins.org> wrote:
|  > I'd actually suggest something on the order of 16-20ms. The rationale
|  > would be to match the typical inter-frame interval for multimedia
|  > applications, so that the kernel will likely be processing a sent
|  > packet when the timer expires, and can amortise the costs of checking
|  > the nofeedback timer into the send routine.
|  
|  You make a good point.  The cost of checking the timer should be
|  fairly low if you're already in the DCCP send code for the relevant
|  connection.  You have to reset the timer anyway every time you get
|  feedback, and checking the timer shouldn't be more expensive than
|  resetting it. As you get feedback every RTT under normal conditions,
|  you ought to be able to check it at least once per RTT so long as
|  you're in the DCCP code anyway.
|  
|  Now, do you every need to check the timer when you're not in the DCCP
|  send code?  I think not.  It's not like TCP, where you need to send a
|  packet on RTO expiry.  I think it should be possible to only ever
|  check the nofeedback timer when you're in the send code for that
|  particular DCCP connection.  And if so, then surely you can afford to
|  check it as often as you reset it - ie around once per RTT?
|  
|  You just have to be a bit smart - if you go to send and discover that
|  the timer should have expired multiple times, then you have to process
|  multiple backoff events, and perhaps reschedule your send for later
|  after you've done that.
Once again thanks to both answers - both value range will be made configurable
and a default value of 100ms will be provided. With a default of 10ms, one is
close to the timer granularity of 100HZ on some systems. 
I will also add the helpful information provided to the configuration menu.

Gerrit
