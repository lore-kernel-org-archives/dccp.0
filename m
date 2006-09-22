From: Sally Floyd <sallyfloyd@mac.com>
Date: Fri, 22 Sep 2006 13:26:01 +0000
Subject: Re: [dccp] Packet size s on CCID3
Message-Id: <cf450b133ceda5ddfceb0d0d2d998301@mac.com>
List-Id: <dccp.vger.kernel.org>
References: <5640c7e00609202022j1b97cf1g30797ffcd9b650b6@mail.gmail.com>
In-Reply-To: <5640c7e00609202022j1b97cf1g30797ffcd9b650b6@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

> Why not just calculate a packet rate per second? Or am I missing
> something obvious?

No, that is a good question.

One reason for including the packet size s is discussed in
Section 5.3 of RFC 4342:

    "The packet size s is used in the TCP throughput equation.  A CCID 3
    implementation MAY calculate s as the segment size averaged over
    multiple round trip times -- for example, over the most recent four
    loss intervals, for loss intervals as defined in Section 6.1.
    Alternately, a CCID 3 implementation MAY use the Maximum Packet Size
    to derive s.  In this case, s is set to the Maximum Segment Size
    (MSS), the maximum size in bytes for the data segment, not including
    the default DCCP and IP packet headers.  Each packet transmitted then
    counts as one MSS, regardless of the actual segment size, and the TCP
    throughput equation can be interpreted as specifying the sending rate
    in packets per second."

Thus, an implementation MAY calculate the allowed sending rate
in bytes per second, using for s the average segment size.
Or an implementation may use the MSS for s, and in fact calculate
the allowed sending rate simply in packets per second.  This would be
a purely local implementation decision.

- Sally
http://www.icir.org/floyd/

