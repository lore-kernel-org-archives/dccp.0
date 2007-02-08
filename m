From: Eddie Kohler <kohler@cs.ucla.edu>
Date: Thu, 08 Feb 2007 00:59:52 +0000
Subject: Re: [PATCH 1/1] DCCP: Fix up t_nom - FOLLOW-UP
Message-Id: <45CA7608.7060702@cs.ucla.edu>
List-Id: <dccp.vger.kernel.org>
References: <200701101021.38920@strip-the-willow>
In-Reply-To: <200701101021.38920@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

I have some minor thoughts relating to this.

- In what units are t_nom kept?  I would hope microseconds at least, not 
milliseconds.  You say "dccps_xmit_timer is reset to expire in t_now + rc 
milliseconds"; I assume you mean that the value t_now + rc is cast to 
milliseconds.  Clearly high rates will require that t_nom be kept in 
microseconds at least.

I wonder because you say:

>  -> assume that t_ipi is less than 1 millisecond, then in effect all packets are
>     sent immediately; hence we have a _continuous_ burst of packets

but this does not follow.  If t_ipi<1ms, but is non-zero, then at most 1ms 
worth of packets can be sent in a burst -- not continuous (assuming it takes 
way less than 1ms to send a packet).

- ccid3_hc_tx_send_packet should return a value that is measured in 
MICROSECONDS not milliseconds.  It also sounds like there is a rounding error 
in step 3a); it should probably return (delay + 500)/1000 at least.

- What if the delay till the next packet is >0 but <HZ?  It sounds like that 
case is causing the problem.  One answer: Do not schedule a TIMER; instead, 
leave a kernel thread or bottom half scheduled, so that the next time the 
kernel runs, it will poll DCCP, even if that is before 1HZ from now.

Make sense?
Eddie


> Below I throw in my 2 cents of why I think there is a critical speed X_crit. Maybe you can
> help me dispel it or point out other possibilities which we can - step-by-step - eliminate,
> until the cause becomes fully clear.
> 
> Firstly, all packet scheduling is based on schedule_timeout().
> 
> The return code rc of ccid_hc_tx_send_packet (wrapper around ccid3_hc_tx_send_packet) is used
> to decide whether to 
> 
>  (a) send the packet immediately or
>  (b) sleep with HZ granularity before retrying
> 
> I am assuming that there is no loss on the link and no backlog of packets which couldn't be
> scheduled so far (i.e. if t_nom < t_now then t_now - t_nom < t_ipi). I assume further that
> there is a constant stream of packets, fed into the TX queue by continuously calling
> dccp_sendmsg. This is also the background of the experiments/graphs. 
> 
> Here is the analysis, starting with ccid3_hc_tx_send_packet:
> 
>  1) dccp_sendmsg calls dccp_write_xmit(sk, 0)
> 
>  2) dccp_write_xmit calls ccid_hc_tx_send_packet, a wrapper around ccid3_hc_tx_send_packet
> 
>  3) ccid3_hc_tx_send_packet gets the current time in usecs and computes  delay = t_nom - t_now
> 
>      (a) if delay >= delta = min(t_ipi/2, t_gran/2) then it returns delay/1000
>      (b) otherwise it returns 0
> 
>  4) back in dccp_write_xmit, 
>      * if rc=0 then the packet is sent immediately;  otherwise (since block=0), 
>      * dccps_xmit_timer is reset to expire in t_now + rc  milliseconds (sk_reset_timer)
>          -- in this case dccp_write_xmit exits now and
> 	 -- when the write timer expires, dccp_write_xmit_timer is called, which again
> 	    calls dccp_write_xmit(sk, 0)
> 	 -- this means going back to (3), now delay < delta, the function returns 0
> 	    and the packet is sent immediately
> 
> To find where the problematic case is, assume that the sender is in slow start and
> doubles X each RTT. As X increases, t_ipi decreases so that there is a point where
> t_ipi < 1000 usec. 
>  
>  -> all differences delay = t_nom - t_now which are less than 1000 result in 
>     delay / 1000 = 0 due to integer division
>  -> hence all packets which are late up to 1 millisecond are sent immediately
>  -> assume that t_ipi is less than 1 millisecond, then in effect all packets are
>     sent immediately; hence we have a _continuous_ burst of packets
>  -> schedule_timeout() really only has a granularity of HZ:
>      * if HZ00,   msecs_to_jiffies(m) returns m
>      * if HZ < 1000, msecs_to_jiffies(m) returns (m * HZ + 999)/1000
>           => hence m=1 millisecond will give a result of 1 jiffie
> 	  => but the granularity of jiffies is in HZ < 1000 so that the 
> 	      timer will expire with a granularity of HZ
>           => that means if X is higher than X_crit, t_ipi will always be such that
> 	      the timer expires at a time which is too late, so that packets are all
> 	      sent in immediate bursts or in scheduled bursts, but there is no longer
> 	      any real scheduling
> 
> The other points which I am not entirely sure about yet are
>  * compression of packet spacing due to using TX output queues
>  * interactions with the traffic control subsystem
>  * times when the main socket is locked
> 
> - Gerrit
> 
> |  > I have a snapshot which illustrates this state: 
> |  > 
> |  >  http://www.erg.abdn.ac.uk/users/gerrit/dccp/dccp_probe/examples/no_tx_locking/transmit_rate.png
> |  >   
> |  > The oscillating behaviour is well visible. In contrast, I am sure that you would agree that the
> |  > desirable state is the following:
> |  > 
> |  >  http://www.erg.abdn.ac.uk/users/gerrit/dccp/dccp_probe/examples/with_tx_locking/transmit_rate.png
> |  > 
> |  > These snapshots were originally taken to compare the performance with and without serializing access to
> |  > TX history. I didn't submit the patch since, at times, I would get the same chaotic behaviour with TX locking.
> |  > 
> |  > Other people on this list have reported that iperf performance is unpredictable with CCID 3. 
> |  > 
> |  > The point is that, without putting in some kind of control, we have a system which gets into a state of
> |  > chaos as soon as the maximum controllable speed X_crit is reached. When it is past that point, there is
> |  > no longer a notion of predictable performance or correct average rate: what happens is then outside the
> |  > control of the CCID 3 module, performance is then a matter of coincidence.
> |  > 
> |  > I don't think that a kernel maintainer will gladly support a module which is liable to reaching such a
> |  > chaotic state.
> |  >  
> |  >   
> |  > |  > I have done a back-of-the-envelope calculation below for different sizes of s; 9kbyte
> |  > |  > I think is the maximum size of an Ethernet jumbo frame.
> |  > |  > 
> |  > |  >    -----------+---------+---------+---------+---------+-------+---------+-------+
> |  > |  >             s | 32      | 100     | 250     | 500     | 1000  | 1500    | 9000  |
> |  > |  >    -----------+---------+---------+---------+---------+-------+---------+-------+
> |  > |  >     X_critical| 32kbps  | 100kbps | 250kbps | 500kbps | 1mbps | 1.5mbps | 9mbps |
> |  > |  >    -----------+---------+---------+---------+---------+-------+---------+-------+ 
> |  > |  > 
> |  > |  > That means we can only expect predictable performance up to 9mbps ?????
> |  > |  
> |  > |  Same comment.  I imagine performance will be predictable at speeds FAR 
> |  > |  ABOVE 9mbps, DESPITE the sub-RTT bursts.  Predictable performance means 
> |  > |  about the same average rate from one RTT to the next.
> |  > I think that, without finer timer resolution, we need to put in some kind of throttle to avoid
> |  > entering the region where speed can no longer be controlled.
> |  > 
> |  >   
> |  > |  > I am dumbstruck - it means that the whole endeavour to try and use Gigabit cards (or
> |  > |  > even 100 Mbit ethernet cards) is futile and we should be using the old 10 Mbit cards???
> |  > |  
> |  > |  Remember that TCP is ENTIRELY based on bursts!!!!!  No rate control at 
> |  > |  all.  And it still gets predictable performance at high rates.
> |  > |  
> |  > Yes, but ..... it uses an entirely different mechanism and is not rate-based.
> |  
> |  
