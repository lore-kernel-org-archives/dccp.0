From: Eddie Kohler <kohler@cs.ucla.edu>
Date: Tue, 03 Oct 2006 15:43:12 +0000
Subject: Re: [dccp] Packet size s on CCID3
Message-Id: <45228510.4040007@cs.ucla.edu>
List-Id: <dccp.vger.kernel.org>
References: <5640c7e00609202022j1b97cf1g30797ffcd9b650b6@mail.gmail.com>
In-Reply-To: <5640c7e00609202022j1b97cf1g30797ffcd9b650b6@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

There are a couple issues with the packet size.

This mail will list my understanding of those issues.  It has no solutions, 
for that there will be another mail.

One thing we have had to consider is that different congestion points in the 
network might have different limitations.  Conventional wisdom is that 
congestion points, such as router output queues, are essentially limited in 
bytes.  That is, a packet of length 200 occupies 200 units of the bottleneck 
resource, where a packet of length 40 occupies 40 units only.  However, in the 
past and probably in the future, some congestion points have been limited in 
PACKETS.  Thus, packets of length 200 and 40 occupy THE SAME AMOUNT of 
bottleneck resource.  And there are other possibilities.

If we were guaranteed that all bottlenecks in the Internet were limited in 
packets, we could stop worrying about the packet size s.  All flows sending K 
packets/sec would observe the same loss rate, regardless of their packet 
sizes.  So a packet-based loss response would react to all congestion 
appropriately.

However that is not the real world.  In the real world a flow sending K small 
packets/sec may occupy LESS bottleneck resource than a flow sending K LARGE 
packets/sec.

So what? you may ask.  If the small-packet flow is occupying less bottleneck 
resource, perhaps it will observe a lower loss event rate than a large-packet 
flow, and thus still occupy its fair share.  The answer is that it MIGHT 
observe a lower loss event rate and it might not.

Also, there is the problem of dynamics.  If a flow sends small packets for 5 
years and then shifts to Gigantapackets (tm), the packet/sec loss rate 
observed over the last 5 years is probably not a fair metric for the 
Gigantapacket transmission rate in packets/sec.  In the long term, of course, 
the Gigantapacket flow will observe its correct loss rate and settle down to a 
fair rate, but the short term could get ugly.  And then what about flows whose 
dynamics shift wildly??

Eddie



Ian McDonald wrote:
> On 9/23/06, Sally Floyd <sallyfloyd@mac.com> wrote:
>> > Why not just calculate a packet rate per second? Or am I missing
>> > something obvious?
>>
>> No, that is a good question.
>>
>> One reason for including the packet size s is discussed in
>> Section 5.3 of RFC 4342:
>>
>>     "The packet size s is used in the TCP throughput equation.  A CCID 3
>>     implementation MAY calculate s as the segment size averaged over
>>     multiple round trip times -- for example, over the most recent four
>>     loss intervals, for loss intervals as defined in Section 6.1.
>>     Alternately, a CCID 3 implementation MAY use the Maximum Packet Size
>>     to derive s.  In this case, s is set to the Maximum Segment Size
>>     (MSS), the maximum size in bytes for the data segment, not including
>>     the default DCCP and IP packet headers.  Each packet transmitted then
>>     counts as one MSS, regardless of the actual segment size, and the TCP
>>     throughput equation can be interpreted as specifying the sending rate
>>     in packets per second."
>>
>> Thus, an implementation MAY calculate the allowed sending rate
>> in bytes per second, using for s the average segment size.
>> Or an implementation may use the MSS for s, and in fact calculate
>> the allowed sending rate simply in packets per second.  This would be
>> a purely local implementation decision.
>>
>> - Sally
> 
> I'm still thinking this all through and want to discuss this a bit further.
> 
> The papers by Padhye and Floyd for the TCP throughput equation all
> seem to say that given a fixed RTT and fixed loss rate that you have a
> fixed throughput rate in packets per second. Have I read this
> correctly?
> 
> The throughput rate is then based on the packet size for a given loss
> rate and RTT. If packet sizes increase, throughput increases but the
> packet transmission rate remains the same.
> 
> Said another way we don't alter packet sending rate if we alter the
> size of the packet. I'm not sure that this is correct on things like
> wireless links but this is the starting point for TFRC at present.
> 
> If the mss is used then t_ipi = s/X_inst according to TFRC spec. That
> means that it will get less than fair share which makes sense (Richard
> I had this around the wrong way when we were discussing).
> 
> I personally don't see why you would do all the calculations for
> average packet size etc when you can simplify it by just counting
> packets. I'm guessing that it was done in this way because people
> wanted to calculate throughput rates due to the protocols being
> thought of but this is far less relevant when you are datagram based
> and don't normally fragment.
> 
> If I get time I'll experiment with implementations in Linux.
> 
> Regards,
> 
> Ian
