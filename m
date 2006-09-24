From: Sally Floyd <sallyfloyd@mac.com>
Date: Sun, 24 Sep 2006 14:11:24 +0000
Subject: Fwd: [dccp] Packet size s on CCID3
Message-Id: <97b8a4d0825a7a50cbbc971f9477f397@mac.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

I am forwarding this email  that I sent earlier - I was using a new
email address that wasn't subscribed to the mailing list.

Begin forwarded message:

>> Why not just calculate a packet rate per second? Or am I missing
>> something obvious?
>
> No, that is a good question.
>
> One reason for including the packet size s is discussed in
> Section 5.3 of RFC 4342:
>
>    "The packet size s is used in the TCP throughput equation.  A CCID 3
>    implementation MAY calculate s as the segment size averaged over
>    multiple round trip times -- for example, over the most recent four
>    loss intervals, for loss intervals as defined in Section 6.1.
>    Alternately, a CCID 3 implementation MAY use the Maximum Packet Size
>    to derive s.  In this case, s is set to the Maximum Segment Size
>    (MSS), the maximum size in bytes for the data segment, not including
>    the default DCCP and IP packet headers.  Each packet transmitted 
> then
>    counts as one MSS, regardless of the actual segment size, and the 
> TCP
>    throughput equation can be interpreted as specifying the sending 
> rate
>    in packets per second."
>
> Thus, an implementation MAY calculate the allowed sending rate
> in bytes per second, using for s the average segment size.
> Or an implementation may use the MSS for s, and in fact calculate
> the allowed sending rate simply in packets per second.  This would be
> a purely local implementation decision.
>
> - Sally
> http://www.icir.org/floyd/
>
>
- Sally
http://www.icir.org/floyd/

