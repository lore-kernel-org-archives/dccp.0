From: gerrit@erg.abdn.ac.uk
Date: Thu, 26 Aug 2010 11:08:58 +0000
Subject: Re: DCCP_BUG called
Message-Id: <40246.148.187.160.35.1282820938.squirrel@148.187.160.35>
List-Id: <dccp.vger.kernel.org>
References: <4C6D3DD8.4080606@pu-pm.univ-fcomte.fr>
In-Reply-To: <4C6D3DD8.4080606@pu-pm.univ-fcomte.fr>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

> Let's say that qdisc on the sender allows 2Mb/s to get out.  A sender
> application sends a file at 3Mb/s to DCCP.  Currently, DCCP "eats" it
> completely, i.e. at 3Mb/s.  However, about 1Mb/s is "eaten" (lost)
> locally because of qdisc, and only 2Mb/s are sent to the network.  DCCP
> indeed sees that some packets are lost (the ones lost locally), that is
> why it computes a rate ("computed transmit rate") of 2Mb/s indeed (we
> printed it to the screen in our tests).  The problem is that DCCP "eats"
> 3Mb/s instead of eating 2Mb/s.

Up to here I agree; but there is nothing wrong here. DCCP would even
"eat" 10Gbps if it were given large enough buffers. It is not a bug
since the actuator for the sending rate is the output, not the input.

It is made complicated since here are two control circuits wired in series:
 * TFRC as rate-based protocol functions similar to a Token Bucket Filter;
 * the Queueing Discipline attached to the output interface.

There are three different speeds:
 * the speed at which the application puts data into the socket (3Mbps)
 * the output rate of DCCP (circa 2Mbps as printed)
 * the target rate of the qdisc (also set to 2Mbps)

You have not said whether the application uses constant bitrate, it looks
as if. In this case the two control circuits interact
 * initially TFRC will send at a higher rate (slow-start);
 * to shape outgoing traffic, packets will be dropped at the outgoing
   interface;
 * the receiver (at the other end) will detect loss and feed it back
 * TFRC will recompute its sending rate and adjust in proportion to
   the experienced loss;
 * this stabilizes at some point where TFRC has converged to about 2Mbps


> In fact, it seems to us that when a packet is lost locally (DCCP_BUG
> called), the next available packet from DCCP socket is immediately
> taken into account, as if the other had not been "eaten" and had not been
> taken into account as a sent packet.

Yes that is what was trying to say: TCP feeds back local loss immediately
(but also notifies the receiver via ECN CWR), whereas DCCP has to wait
until the receiver reports the loss.

But as per previous email, I think it is not a high-priority issue to
provide a special case for local loss.

For tests involving traffic shaping the recommendation on the list has
been to use a separate "middlebox":

http://www.linuxfoundation.org/collaborate/workgroups/networking/dccptesting#Network_emulation_setup


Have you considered using dccp_probe to look at the other parameters --
some information is on

http://www.erg.abdn.ac.uk/users/gerrit/dccp/testing_dccp/#dccp_probe

