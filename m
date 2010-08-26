From: Eugen Dedu <Eugen.Dedu@pu-pm.univ-fcomte.fr>
Date: Thu, 26 Aug 2010 16:11:13 +0000
Subject: Re: DCCP_BUG called
Message-Id: <4C769221.5060506@pu-pm.univ-fcomte.fr>
List-Id: <dccp.vger.kernel.org>
References: <4C6D3DD8.4080606@pu-pm.univ-fcomte.fr>
In-Reply-To: <4C6D3DD8.4080606@pu-pm.univ-fcomte.fr>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 26/08/10 13:08, gerrit@erg.abdn.ac.uk wrote:
>> Let's say that qdisc on the sender allows 2Mb/s to get out.  A sender
>> application sends a file at 3Mb/s to DCCP.  Currently, DCCP "eats" it
>> completely, i.e. at 3Mb/s.  However, about 1Mb/s is "eaten" (lost)
>> locally because of qdisc, and only 2Mb/s are sent to the network.  DCCP
>> indeed sees that some packets are lost (the ones lost locally), that is
>> why it computes a rate ("computed transmit rate") of 2Mb/s indeed (we
>> printed it to the screen in our tests).  The problem is that DCCP "eats"
>> 3Mb/s instead of eating 2Mb/s.
>
> Up to here I agree; but there is nothing wrong here. DCCP would even
> "eat" 10Gbps if it were given large enough buffers. It is not a bug
> since the actuator for the sending rate is the output, not the input.
>
> It is made complicated since here are two control circuits wired in series:
>   * TFRC as rate-based protocol functions similar to a Token Bucket Filter;
>   * the Queueing Discipline attached to the output interface.
>
> There are three different speeds:
>   * the speed at which the application puts data into the socket (3Mbps)
>   * the output rate of DCCP (circa 2Mbps as printed)
>   * the target rate of the qdisc (also set to 2Mbps)

This needs a clarification.  Suppose a DCCPsocket with a size of a few 
packets.  The current situation is the following:

App ---------> DCCPsocket --------> qdisc ---------> network
       3Mb/s                 3Mb/s     |     2Mb/s
                                       v
                                     1Mb/s rejected locally

We believe that DCCP acts wrongly when it sends at 3Mb/s (identical to 
appli speed).  It should have been:

App ---------> DCCPsocket --------> qdisc ---------> network
       3Mb/s        |        2Mb/s           2Mb/s
                    v
                  1Mb/s rejected because buffer is full

Now, we have seen that DCCP correctly computes the estimated transmit 
rate to 2Mb/s.  We believe this should be considered as DCCP (buffer) 
output, not as network output.  What is the interest of sending (eating 
from DCCPsocket) more than 2Mb/s if DCCP knows that all further packets 
are lost?  Otherwise said, when a packet is lost locally, why sending 
right afterwards another packet and not to wait the N ms given by TFRC 
equation?

In fact, when feedback about 1Mb/s lost packets arrives at the sender, 
three cases appear (I do not know how linux DCCP acts in reality):
- either DCCP pays attention to lost packets => it further reduces the 
rate, from 2Mb/s to say 1Mb/s, which is wrong, since the network accepts 
2Mb/s
- or DCCP pays attention to receiver rate (2Mb/s) and does NOT pay 
attention to lost packets, which is strange; in this case it stabilises 
to 2Mb/s indeed
- or other strange case (DCCP bug?)

> You have not said whether the application uses constant bitrate, it looks
> as if. In this case the two control circuits interact
>   * initially TFRC will send at a higher rate (slow-start);
>   * to shape outgoing traffic, packets will be dropped at the outgoing
>     interface;
>   * the receiver (at the other end) will detect loss and feed it back
>   * TFRC will recompute its sending rate and adjust in proportion to
>     the experienced loss;
>   * this stabilizes at some point where TFRC has converged to about 2Mbps
>
>
>> In fact, it seems to us that when a packet is lost locally (DCCP_BUG
>> called), the next available packet from DCCP socket is immediately
>> taken into account, as if the other had not been "eaten" and had not been
>> taken into account as a sent packet.
>
> Yes that is what was trying to say: TCP feeds back local loss immediately
> (but also notifies the receiver via ECN CWR), whereas DCCP has to wait
> until the receiver reports the loss.

It is not that DCCP has to wait one RTT, it is that it does not take 
into account the local losses at all.  DCCP does not act correctly one 
RTT later either.

> But as per previous email, I think it is not a high-priority issue to
> provide a special case for local loss.
>
> For tests involving traffic shaping the recommendation on the list has
> been to use a separate "middlebox":
>
> http://www.linuxfoundation.org/collaborate/workgroups/networking/dccptesting#Network_emulation_setup

Thank you, we have finally used a middlebox, and shaping works (well, 
there are from time to time intervals of 1 second where the receiver 
receives twice more packets than middlebox's qdisc would allow, but we 
need to investigate further this strange issue).

> Have you considered using dccp_probe to look at the other parameters --
> some information is on
>
> http://www.erg.abdn.ac.uk/users/gerrit/dccp/testing_dccp/#dccp_probe

We have done this manually, through getsockopt.

-- 
Eugen
