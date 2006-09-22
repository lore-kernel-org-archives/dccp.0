From: Eddie Kohler <kohler@cs.ucla.edu>
Date: Fri, 22 Sep 2006 17:10:16 +0000
Subject: Re: [PATCH 7/7] [DCCP]: Remove socket option
Message-Id: <451418F8.5070002@cs.ucla.edu>
List-Id: <dccp.vger.kernel.org>
References: <200609221433.48612.ian.mcdonald@jandi.co.nz>
In-Reply-To: <200609221433.48612.ian.mcdonald@jandi.co.nz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hi, a bit of re-clarification:  CCIDs 2 and 3 are *not* meant for apps that 
NEVER vary their packet size.  Rather, they are meant for apps that very 
packet size *for application reasons* (such as codec output), but *not* in 
response to congestion.  CCIDs 2 and 3 expect to reduce application RATES in 
response to congestion.

Applications that lie about the packet size parameter are a concern, but 
perhaps one could handle that as it came up.  Our simulations indicated that 
applications got little benefit from manipulating packet size.  Note also that 
the RFC explicitly allows CCID 3 to use the largest packet size possible for 
the 's' parameter, regardless of the actual packet size.  If the option value 
was bounded above by this maximum segment size, then I believe the app would 
get little benefit from lying.  (Would need to check.)

In summary, in the longer-term deriving 's' from observations would work, but 
I don't see any objection to this socket option in the short term or the long 
term.  It allows the application to explicitly state its intent, which is 
usually useful.

Eddie


Gerrit Renker wrote:
> I think that the PACKET_SIZE socket option is redundant, since
> it can be derived from
>  * the buflen argument of dccp_sendmsg()
>  * the size of received packets
> independent of whether the CCID is for fixed packet sizes or not.
> 
> Virtually all known CCIDs have fixed packet sizes; for such CCIDs
> there are two cases:
> 
>  (i)  buffer length never changes and is equal to PACKET_SIZE
>       --> then PACKET_SIZE is clearly redundant
>  (ii) PACKET_SIZE gives the intention of an average packet size
>       which implies that PACKET_SIZE gives an average of buflen
> 
> So the relevant case to consider is (ii) and here I think that
> using a PACKET_SIZE option is also redundant: the application
> could simply lie and state the wrong PACKET_SIZE.
> 
> Below are excerpts from the literature to substantiate the above.
> 
> Fixed-size CCIDS 2 and 3
> ============
> Both CCID 2 and 3 are meant for applications that use fixed packet sizes.
> 
> * [RFC 4341, sec. 5.3]: "CCID 2 is optimized for applications that
>   generally use a fixed packet size and vary their sending rate in
>   packets per second in response to congestion."
> 
> * [RFC 4341, sec. 5.3]: "CCID 3 is intended for applications that use
>   a fixed packet size, and that vary their sending rate in packets per
>   second in response to congestion."
> 
> * [draft-floyd-rfc3448bis-00, sec. 1]: "TFRC is designed for applications that
>   use a fixed segment size, and vary their sending rate [...]  Some applications
>   [...] vary their segment size instead of their packet rate in response to 
>   congestion.  The congestion control mechanism in this document is not designed
>   for those applications."
> 
> When applications don't know their average packet (aka segment) size, 
> [draft-floyd-rfc3448bis-00, sec. 4.1] suggests the following:
> 
>  "For the first class of applications where the segment size varies depending on
>   the data, the sender MAY estimate the segment size s as the average segment size
>   over the last four loss intervals.  The sender MAY also estimate the average segment
>   size over longer time intervals, if so desired."
> 
> This means that for CCIDs 2 and 3 the PACKET_SIZE option is redundant, since the
> sender is asked to take care of the averaging itself. 
> 
> Future CCIDs with varying packet sizes
> ===================
> In the section 6 of draft-ietf-dccp-tfrc-voip-05.txt (the upcoming CCID 4), 
> "TFRC-SP with Applications that Modify the Packet Size", the issue of varying packet
> sizes is addressed as follows:
> 
>    "One possible use for TFRC-SP would be with applications [...] modify
>     their packet size in response to congestion.  [...]
> 
>     There are many questions about how an adaptive application would use
>     TFRC-SP that are beyond the scope of this document.  [...] The details
>     of how long an application might wait before reducing the packet size can be
>     addressed in documents that are more application-specific.
> 
>     Similarly, an application using TFRC-SP might only have a few packet
>     sizes that it is able to use.  [...] Again, the details will have to
>     be addressed in documents that are more application-specific."
> 
> So it is the problem of the application and we don't need/want to know about
> packet size in the kernel.
> 
> -- Gerrit
> -
> To unsubscribe from this list: send the line "unsubscribe dccp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
