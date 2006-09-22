From: Eddie Kohler <kohler@cs.ucla.edu>
Date: Fri, 22 Sep 2006 16:56:52 +0000
Subject: Re: [PATCH 5/7] [DCCP]: Introduce two new socket options
Message-Id: <451415D4.6090408@cs.ucla.edu>
List-Id: <dccp.vger.kernel.org>
References: <200609221430.14555.ian.mcdonald@jandi.co.nz>
In-Reply-To: <200609221430.14555.ian.mcdonald@jandi.co.nz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hi, just a couple clarifications and notes.  I haven't deeply thought through 
the new socket options, but disagree with your objections :)

Gerrit Renker wrote:
> |  This creates two new socket options DCCP_SOCKOPT_TX_PACKET_SIZE
> |  and DCCP_SOCKOPT_RX_PACKET_SIZE. DCCP_SOCKOPT_PACKET_SIZE doesn't
> |  work and packet size should be set independently on two half
> |  connections.
> I disagree with this solution: it solves one problem by introducing two
> new ones:
> 
>  * the options are redundant:
>      --at the sender the packet size is implicitly communicated via the 
>        `len' argument of dccp_sendmsg()
>      --the receiver samples the packet sizes of incoming packets

The "intended average packet size", a congestion control parameter used by 
CCID 3 and CCID 4, is different from the actually _observed_ packet size.  I 
could see how an explicit setting for this congestion control parameter might 
be useful in addition to the information communicated by 'len' and incoming 
packet sizes.

CCID 3, for example, says that 's' MAY be calculated from a running average, 
OR from the maximum segment size.  I think an option like 
DCCP_SOCKOPT_TX_PACKET_SIZE, by which the app can declare an intended average 
packet size, is also acceptable.

In practice CCID 2 won't make use of these parameters, and neither will most 
CCID 3 receivers.  But Ian is right that this is a per-half-connection variable.


>  * it makes the programming interface more complex; currently these options
>    only work for CCID 3 (cf. patch 6/7)

Don't understand this objection.


>  * both CCID 2/3 are for fixed-packet sizes anyway, and the upcoming
>    CCID 4 draft-ietf-dccp-tfrc-voip-05.txt looks much rather like a 
>    fixed `mini' packet size rather than a variable-size protocols

This is not right.  We expected CCID 2 and CCID 3 senders to vary their packet 
sizes due to application constraints.  DCCP implementations SHOULD NOT require 
sending apps to limit themselves to a single packet size.  CCID 2 and 3 are 
NOT intended for apps that vary their packet size *in response to congestion*, 
but this is a different kettle of fish.


>  * for varying packet sizes, the sender should calculate the mean/avg
>    packet size by itself, rather than relying on information. For TFRC, 
>    [draft-floyd-rfc3448bis-00, sec. 4.1] suggests here:
>       "where the segment size varies depending on the data, the sender MAY estimate the
>        segment size s as the average segment size over the last four loss intervals."

See above.


> In summary, I think it would be better to let the sender/receiver determine the 
> packet size from already available data. That is, derive s from the `len' of dccp_sendmsg(),
> and use a weighted-average mechanism like
>                        s  =   q * len  +  (1-q) * s
> to smooth out variations: in accordance with draft-floyd-rfc3448bis-00.

This would be fine with me, and perhaps even preferable in terms of the 
programming API.  But the drafts I think would allow the socket option, so if 
it's needed now, why not?

Eddie


> -- Gerrit
> -
> To unsubscribe from this list: send the line "unsubscribe dccp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
