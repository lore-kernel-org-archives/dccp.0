From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sun, 15 Apr 2007 16:49:41 +0000
Subject: Re: [PATCH 28/43]: Make computation of X_recv conform to TFRC
Message-Id: <200704151749.41426@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200704051636.00836@strip-the-willow>
In-Reply-To: <200704051636.00836@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

|  This is a question, not a comment:
|  Sally and I are actually discussing whether, as a result of the RFC3448bis 
|  work, we should update RFC4342 so that the Receive Rate option in CCID 3 
|  *always* reports the receive rate over the last RTT, rather the max of (RTT, 
|  time since last RR option).

I get the impression that this could be resolved with a `should' clause.

The problem is that the receiver may sometimes sample X_recv over more
than a full RTT - e.g. when the window counter CCVal distance from one
data packet to the next one is more than 4, indicating a time difference
of more than 1 RTT.

In such cases, it seems better to allow the receiver to use this value, 
being as close to an RTT sample as one can get.

In other cases, when the receiver is able to choose between sampling over one RTT
and a longer period, it does seem better to use the RTT, since the sending rate
could have changed during the last RTT - which would not show as sharply when
the longer sampling period is preferred.

But, as said, the sender may not always have this choice.

Gerrit


|  If, as implementors, you have opinions about which definition would be easier, 
|  we would like to hear them.
|  
|  Thanks,
|  Eddie
|  
|  
|  Gerrit Renker wrote:
|  > |  I think this is one of those (rare) instances where RFC4342 overrides
|  > |  RFC3448. Have a look in particular at section 10.3 of 4342 and 8.1/8.3
|  > |  
|  > |  As such this patch is not correct I think.
|  > |  
|  > |  Thoughts?
|  > There are two points here: 
|  > 
|  > (1) The title is a bit unfortunate, as 90% of the patch are concerned with
|  >     improving the interface from rx_packet_recv() to send_feedback().
|  > 
|  > (2) With regards to the 3448/4342 relationship, you are correct. 
|  >     I had overlooked the following passage in section 8.3 of RFC 4342:
|  > 
|  >      "To calculate this receive rate, the receiver sets t to the larger of 
|  >       the estimated round-trip time and the time since the last Receive Rate
|  >       option was sent."
|  > 
|  >     However, though I wish I had read that earlier, this additional rule causes
|  >     no contradiction - in fact, it simplifies the issue.
|  > 
|  > 
|  > What follows shows that the patch conforms to above rule from [RFC 4342, 8.3]. The 
|  > documentation of how the patch works is on 
|  >   http://www.erg.abdn.ac.uk/users/gerrit/dccp/docs/ccid3_packet_reception/#8._Computing_X_recv_
|  > The time `t' here corresponds to delta = t_now - ccid3hcrx_last_feedback
|  > 
|  > 
|  >  1. Periodic feedback (FBACK_PERIODIC) triggered by the window counter.
|  > 
|  >     This is using the rule specified by [RFC 4340,  10.3]. 
|  > 
|  >       (a) Time between window counter changes larger than or equal to RTT
|  >           This corresponds to a window counter difference of 4 or larger 
|  >           and is in agreement with above rule from 8.3 with regard to "the
|  >           larger of the estimated round-trip time".
|  > 
|  >       (b) Time between window counter changes less than RTT.
|  >           No periodic feedback  is sent due to 10.3.
|  > 
|  > 
|  >  2. Feedback due to parameter change (FBACK_PARAM_CHANGE).
|  > 
|  >     There are thw possible cases, both need to be handled correctly.
|  > 
|  >       (i) Parameter change directly after sending periodic feedback.
|  >           In this case few (worst case: none) packets have been received since the last
|  >           feedback was sent. The code does not (as was done previously) use the number
|  >           of bytes received since the last feedback was received: the time interval 
|  >           since sending the last feedback is less than the estimated RTT used in sending
|  >           periodic feedback. 
|  >           RFC 4342, 8.3 requires to compute X_recv over an interval larger than the 
|  >           estimated RTT and this time interval. The code therefore uses the longer interval 
|  >           of the RTT estimate, by reusing X_recv computed previously. Note that both feedback
|  >           packets are sent within the same RTT. In addition, last_counter is reset to correctly
|  >           trigger the next periodic feedback.
|  > 
|  >      (ii) Parameter change when no periodic feedback has been sent yet.
|  >  
|  >           Here X_recv is 0. This case can happen due to early loss. We have no reasonable RTT 
|  >           estimate, the only feedback that has been sent is the initial feedback from [RFC 3448, 6.3].
|  >           Here X_recv is computed over the interval since last_counter was last set (at the same time
|  >           when the initial feedback packet was sent). This again does not contradict the rule from
|  >           RFC 4342, 8.3; rather it is a special case with the premise that there is no reliable RTT
|  >           estimate yet. Furthermore, this case is an exception - it occurs only when there is loss
|  >           immediately after the first data packet and before the first periodic feedback is due. 
|  > -
|  > To unsubscribe from this list: send the line "unsubscribe dccp" in
|  > the body of a message to majordomo@vger.kernel.org
|  > More majordomo info at  http://vger.kernel.org/majordomo-info.html
|  -
|  To unsubscribe from this list: send the line "unsubscribe dccp" in
|  the body of a message to majordomo@vger.kernel.org
|  More majordomo info at  http://vger.kernel.org/majordomo-info.html
|  
|  
