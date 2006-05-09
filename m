From: "Ian McDonald" <imcdnzl@gmail.com>
Date: Tue, 09 May 2006 03:02:55 +0000
Subject: Re: dccp-iperf and high speed UDP, Was: [dccp] DCCP with iperf was Re: Question on iperf versions
Message-Id: <cbec11ac0605082002g48b3518eq1d30f649b8e58b6c@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 5/9/06, Dimitrios Miras <d.miras@cs.ucl.ac.uk> wrote:
> Hi Ian,
>
> we talked a while ago, hope you're doing fine. Well, I need to ask you
> something that puzzles me:
>   I do DCCP ccid3 iperfs between two machines at the two ends of a 1Gb/s
> transatlantic link with 177ms RTT. Iperf tells me that the sender's
> throughput goes up to 900mbps, however, the receiver appears to be
> hanging, or reporting far lower throughput. Using ifconfig, i notice
> huge numbers of dropped packets on the interface. Well, when I use the
> same scenario on a local testbed (machines connect to a local gigabit
> switch and RTT is fraction of ms).. i don';t get this behaviour,
> throughput is as expected ~900+ mbps.
> Do you have any ideas why this is happening? Why are packets being
> dropped on the interface? I've stuck with this big time.
>
> Thanks in advance,
> Dimitrios Miras
>
Dimitrios,

I've been investigating this a bit further and thought I'd cc dccp
development list as well - trust that this is OK.

When I run iperf between the two nodes with a box as a router in
between I get the following through the kernel logs:
May  9 13:55:49 localhost kernel: [17185928.512000] DCCP: Step 6
failed for DATA packet, (LSWL(91744560301) <= P.seqno(91744560658) <S.SWH(91744560400)) and (P.ackno doesn't exist or LAWL(93698688431) <P.ackno(1125899906842620) <= S.AWH(93698688459), sending SYNC...

As I understand this it is showing that the packet received has too
high a sequence number and my thoughts are on this is that we have had
too many packets dropped by the network. DCCP checks in input.c to see
whether sequence number is not too low or too high.

So I went onto my router and ran top and see that I am using 100% of
my CPU on hardware interrupts and software interrupts. What I think is
happening is that the routing queues are building up and then it drops
the packets but DCCP says your sequence number is too high for the
packets it does receive as I haven't seen the other packets (which
were dropped).

Now I would have thought that DCCP should back off when it knows it is
being constrained somehow. It does do this on other tests that I do
with loss etc. So I thought that I would test on TCP to see whether it
can handle the 100 Mbit speed (it is an old box...). So I tested this
and it uses approximately 75% of CPU for hi/si when running iperf with
TCP between my two end nodes.

That is where I am leaving it for today until I get more time. This
needs checking for it's congestion control really... there are other
reports also that DCCP uses an unfair share of traffic when mixed with
TCP so suspect that there is something wrong in it's calculations
about how much traffic to let through...

Hopefully this might help you somewhat or help others to look at
fixing if they can beat me to it.

BTW mine is CCID3 as well and ackvecs off.

Ian
--
Ian McDonald
Web: http://wand.net.nz/~iam4
Blog: http://imcdnzl.blogspot.com
WAND Network Research Group
Department of Computer Science
University of Waikato
New Zealand
