From: Ian McDonald <ian.mcdonald@jandi.co.uk>
Date: Thu, 26 Aug 2010 16:26:21 +0000
Subject: Re: DCCP_BUG called
Message-Id: <AANLkTinpno4f+3xuu3KSDOBF_dhkt8bOskj1WS9ux3Pe@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <4C6D3DD8.4080606@pu-pm.univ-fcomte.fr>
In-Reply-To: <4C6D3DD8.4080606@pu-pm.univ-fcomte.fr>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

One salient point here:
- are you using qdisc on the same box as the DCCP sender? I had to
shift qdisc onto another box as the point that qdisc intercepts is not
necessarily where you think. In my research I ended up using three
boxes - a sender, a traffic shaper and a receiver. I also had to
create two subnets and have the traffic shaper route also as otherwise
the boxes were smart enough to work out they were on the same Ethernet
segment.

I can supply some scripts etc if you want to look at mine...

Regards

Ian
--
twitter imcdnzl
web http://www.next-genit.co.uk

On 26 August 2010 17:11, Eugen Dedu <Eugen.Dedu@pu-pm.univ-fcomte.fr> wrote:
>
> On 26/08/10 13:08, gerrit@erg.abdn.ac.uk wrote:
>>>
>>> Let's say that qdisc on the sender allows 2Mb/s to get out. =A0A sender
>>> application sends a file at 3Mb/s to DCCP. =A0Currently, DCCP "eats" it
>>> completely, i.e. at 3Mb/s. =A0However, about 1Mb/s is "eaten" (lost)
>>> locally because of qdisc, and only 2Mb/s are sent to the network. =A0DC=
CP
>>> indeed sees that some packets are lost (the ones lost locally), that is
>>> why it computes a rate ("computed transmit rate") of 2Mb/s indeed (we
>>> printed it to the screen in our tests). =A0The problem is that DCCP "ea=
ts"
>>> 3Mb/s instead of eating 2Mb/s.
>>
>> Up to here I agree; but there is nothing wrong here. DCCP would even
>> "eat" 10Gbps if it were given large enough buffers. It is not a bug
>> since the actuator for the sending rate is the output, not the input.
>>
