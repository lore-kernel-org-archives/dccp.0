From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 12 Jan 2007 12:54:47 +0000
Subject: Re: [PATCH 1/1] DCCP: Fix up t_nom - FOLLOW-UP
Message-Id: <200701121254.47302@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200701101021.38920@strip-the-willow>
In-Reply-To: <200701101021.38920@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Quoting Eddie Kohler:
|  > The problem I see is that
|  >  * scheduling granularity is at best 1ms
|  >  * hence t_gran/2 is at best 500usec
|  >  * and so when t_ipi < 1ms, packets will always be sent in bursts
|  > 
|  > So we have a `critical point' after which the average sending rate is dominated by the
|  > hardware and no longer under the rate-based control of t_ipi.
|  
|  I think there might be a confusion about what "average sending rate" 
|  actually means.  You appear to assume that precise timing control is 
|  needed to obtain a smooth average.  I.e., if there are bursts, then 
|  there is no smooth average.  But this isn't what the RFC means by 
|  average.  The average rate is suppsoed to be smooth *from one RTT to the 
|  next*.  Sub-RTT burstiness is *explicitly allowed*, although 
|  implementations should try to avoid it when it's easy to do so.
Sorry, I don't think you got my point. The problem is NOT in occasional bursts, but rather
that there is a critical speed X_crit after which the system essentially gets completely out
of control.

If bursts would occur occasionally then it would be like a car which is speeding up for a moment, 
but then slows down again (and thus keeps the average speed) - agree that this would not be a problem.
Here however we have that, once X_crit is reached, the system will _oscillate_ between the top
available speed (and this could be hundreds of Mbits per second) and whatever it gets in terms
of feedback from the receiver. After slowing down, it would again climb in slow-start up to 
X_crit, then jump to top speed. Thus it is  like a car which will abruptly switch to top speed
of e.g. 160 mph when trying to accelerate past 2 mph.

I have a snapshot which illustrates this state: 

 http://www.erg.abdn.ac.uk/users/gerrit/dccp/dccp_probe/examples/no_tx_locking/transmit_rate.png
  
The oscillating behaviour is well visible. In contrast, I am sure that you would agree that the
desirable state is the following:

 http://www.erg.abdn.ac.uk/users/gerrit/dccp/dccp_probe/examples/with_tx_locking/transmit_rate.png

These snapshots were originally taken to compare the performance with and without serializing access to
TX history. I didn't submit the patch since, at times, I would get the same chaotic behaviour with TX locking.

Other people on this list have reported that iperf performance is unpredictable with CCID 3. 

The point is that, without putting in some kind of control, we have a system which gets into a state of
chaos as soon as the maximum controllable speed X_crit is reached. When it is past that point, there is
no longer a notion of predictable performance or correct average rate: what happens is then outside the
control of the CCID 3 module, performance is then a matter of coincidence.

I don't think that a kernel maintainer will gladly support a module which is liable to reaching such a
chaotic state.
 
  
|  > I have done a back-of-the-envelope calculation below for different sizes of s; 9kbyte
|  > I think is the maximum size of an Ethernet jumbo frame.
|  > 
|  >    -----------+---------+---------+---------+---------+-------+---------+-------+
|  >             s | 32      | 100     | 250     | 500     | 1000  | 1500    | 9000  |
|  >    -----------+---------+---------+---------+---------+-------+---------+-------+
|  >     X_critical| 32kbps  | 100kbps | 250kbps | 500kbps | 1mbps | 1.5mbps | 9mbps |
|  >    -----------+---------+---------+---------+---------+-------+---------+-------+ 
|  > 
|  > That means we can only expect predictable performance up to 9mbps ?????
|  
|  Same comment.  I imagine performance will be predictable at speeds FAR 
|  ABOVE 9mbps, DESPITE the sub-RTT bursts.  Predictable performance means 
|  about the same average rate from one RTT to the next.
I think that, without finer timer resolution, we need to put in some kind of throttle to avoid
entering the region where speed can no longer be controlled.

  
|  > I am dumbstruck - it means that the whole endeavour to try and use Gigabit cards (or
|  > even 100 Mbit ethernet cards) is futile and we should be using the old 10 Mbit cards???
|  
|  Remember that TCP is ENTIRELY based on bursts!!!!!  No rate control at 
|  all.  And it still gets predictable performance at high rates.
|  
Yes, but ..... it uses an entirely different mechanism and is not rate-based.
