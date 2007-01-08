From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 08 Jan 2007 10:32:12 +0000
Subject: Re: [PATCH 4/4] DCCP: Recalculate t_nom on change of t_ipi
Message-Id: <200701081032.12428@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200612281708.38935.ian.mcdonald@jandi.co.nz>
In-Reply-To: <200612281708.38935.ian.mcdonald@jandi.co.nz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

|  > there are two causes, which are not resolved by this patch:
|  >
|  >  (1) t_nom becoming negative is caused by tardiness in packet scheduling
|  >      and therefore it should be resolved at the location which deals with packet
|  >      sending (ccid3_hc_tx_send_packet), and not in ccid3_update_send_time()
|  >
|  I thought my solution was better. I originally implemented the same
|  solution as you and then realised this point 1 you discuss. But it
|  should be negative in these cases as per RFC 3448 4.6
|  
|  When a sender first starts sending at time t_0, it calculates t_ipi,
We have had this discussion in detail before, please see
http://www.mail-archive.com/dccp@vger.kernel.org/msg00841.html

  
|  Note there that several packets can be sent in bursts. Your code stops
|  this and slows transmit down quite a lot.
Under which conditions are packets sent in bursts? 

RFC 3448, 4.6 considers coarse timer granularity. However, the problem considered here
is when a packet is scheduled for sending after it was due - tardiness. 

You are saying that my "code stops this and slows transmit down quite a lot". 
This is not true:
 * when tardiness does not occur and packet scheduling is always within bounds, 
   the issue does not arise - we are doing as the RFC says.
 * when tardiness occurs then it is a problem of the packet scheduling engine, but
   not of the calculation of t_ipi. 
In simple terms, tardiness is either a bug (when occurs constantly) or it is an overload
indicator. What my patch does is avoid further damage when such a condition occurs and there
is no doubt here that it should.
What you are proposing above is that reacting to an error condition stops sending a burst of
packets and that therefore it "slows transmit down quite a lot". 
I am not convinced since your argumentation is only valid if the bug/overload case occurs. My
suggestion is to add a warning message when tardiness occurs, but not try to fix a possible
bug/overload condition by changing the way t_ipi is calculated.

|  
|  However I think now my solution is not perfect. What I was trying to
|  work around and fix was that the t_ipi gets altered down from 1
|  second.
Sorry I don't get the reason for this. 
  
|  However thinking about it some more we are doing this the wrong way
|  altogether and should do it in the sending loop ONLY as per the
|  suggestion (not requirement) at the top of section 4.6
Please have a look at the other patch which fixes the race condition; indeed it
makes sure that t_nom is only updated in the sending loop. With regard to t_ipi, 
it is best to update it as soon as new data becomes available.

  
|  The special case that we need to deal with is this one from section 5
|  of RFC4342:
|     [RFC3448], Section 4, specifies an initial sending rate of one packet
|     per round-trip time (RTT) as follows: The sender initializes the
|     allowed sending rate to one packet per second.  As soon as a feedback
|     packet is received from the receiver, the sender has a measurement of
|     the round-trip time and then sets the initial allowed sending rate to
|     one packet per RTT.
This has been done already - support for larger initial windows in hc_tx_packet_recv.


|  
|  >  (2) Using this routine carries with it a race condition: several functions
|  >      (ccid3_hc_tx_send_packet, this routine, ccid3_hc_tx_update_x, ccid3_hc_tx_packet_recv)
|  >      have asynchronous, concurrent read-write access to t_nom.
|  >
|  > Please see earlier discussion on `tardiness bug' and the detailed analysis provided with
|  > the `race condition' patch.
|  >
|  I think that rewriting this code as per point 1 will eliminate this
|  problem provided we do it properly.
|  
|  So the short answer is we both made improvements but we've both got it
|  not quite right and we need to revise again.
I remain to be convinced where we "got it not quite right": we need to catch the bug/overload
condition and we must ensure that race conditions are avoided. Both are taken care of by the
patches I sent. 

Sorry I fail to see what problem you are trying to fix. Of course, it is regrettable when bursts
of packets can not be sent due to tardiness. But, as already explained above, this condition only
appears when there is either (i) a bug in the scheduling engine or (ii) an overload condition.

While I think that (i) is unlikely; if it occurs then we need to reconsider the packet scheduling
(dccp_wait_for_ccid, dccp_write_xmit_timer and related functions), but not the code to calculate
t_nom and t_ipi.

In case (ii) sending bursts of packets is not possible anyhow, since the OS/NIC/network first needs
to recover from the overload condition.

Hence the only point where I agree with you is to add a warning message whenever the tardiness condition
occurs in hc_tx_send_packet, to see whether (i) holds. I am NOT in support of code to deal with (ii).
