From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Tue, 03 Oct 2006 03:40:14 +0000
Subject: Re: [dccp] Packet size s on CCID3
Message-Id: <5640c7e00610022040i6fcf4645rf3ea1633dd62dbee@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <5640c7e00609202022j1b97cf1g30797ffcd9b650b6@mail.gmail.com>
In-Reply-To: <5640c7e00609202022j1b97cf1g30797ffcd9b650b6@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Just re-reading this again:

> One reason for including the packet size s is discussed in
> Section 5.3 of RFC 4342:
>
>     "The packet size s is used in the TCP throughput equation.  A CCID 3
>     implementation MAY calculate s as the segment size averaged over
>     multiple round trip times -- for example, over the most recent four
>     loss intervals, for loss intervals as defined in Section 6.1.
>     Alternately, a CCID 3 implementation MAY use the Maximum Packet Size
>     to derive s.  In this case, s is set to the Maximum Segment Size
>     (MSS), the maximum size in bytes for the data segment, not including
>     the default DCCP and IP packet headers.  Each packet transmitted then
>     counts as one MSS, regardless of the actual segment size, and the TCP
>     throughput equation can be interpreted as specifying the sending rate
>     in packets per second."
>
> Thus, an implementation MAY calculate the allowed sending rate
> in bytes per second, using for s the average segment size.
> Or an implementation may use the MSS for s, and in fact calculate
> the allowed sending rate simply in packets per second.  This would be
> a purely local implementation decision.
>
> - Sally

Why do we have to assume s = MSS? If we actually track the number of
packets this makes the situation far worse and we can't send at a fair
rate. For example if MSS is 1500 bytes and we are actually using 50
byte packets then we can only send 1/30 th of what we are permitted
under the TCP throughput equation.

Using MSS is fair if we are using a byte rate per second
implementation but if we do a packet per second implementation (given
X and s act to cancel out) this seems patently wrong.

This would not be open to application abuse as the protocl would be
just tracking packets per second.

Forgive me if I'm making a fundamental error - I would like to see
what I am doing wrong if I am. I know that what I am saying is not
what RFC4342 says but I'm referring to the ideas behind it.

Ian
-- 
Ian McDonald
Web: http://wand.net.nz/~iam4
Blog: http://imcdnzl.blogspot.com
WAND Network Research Group
Department of Computer Science
University of Waikato
New Zealand
