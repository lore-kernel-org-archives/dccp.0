From: David Miller <davem@davemloft.net>
Date: Fri, 13 Apr 2007 20:43:56 +0000
Subject: Re: Sensitivity of TFRC throughput equation wrt to changes of RTT
Message-Id: <20070413.134356.18297036.davem@davemloft.net>
List-Id: <dccp.vger.kernel.org>
References: <200704131303.03072@strip-the-willow>
In-Reply-To: <200704131303.03072@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Sat, 14 Apr 2007 07:52:32 +1200

> Which comes into play when we have loss. When we have no loss, or a
> long period of non-loss we can send as fast as we want according to
> the spec. This should normally be the case on LANs where the RTT makes
> a far bigger difference.

This is correct, also there is another related issue I should
have mentioned.

Congestion control on LANs and very small RTTs arguably does not make
much sense.  Many very smart networking folk have argued this.

The reason is that any congestion you detect on a LAN will go away
long before you can even react to it in a protocol stack.

Alexey Kuznetsov once was trying to come up with a statistical
theoretical model to justify this in some tangible way, but he
never came up with anything concrete.

It's funny but the RTT measurements of TCP have a minimum which
is established by the timer granularity limitations of the original
TCP implementation in BSD.  See the TCP_RTO_MIN clamping we do
in the Linux TCP stack.

Although originally an implementation side-effect, it plays into
the LAN issues I discussed above.
