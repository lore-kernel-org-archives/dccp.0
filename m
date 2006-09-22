From: Eddie Kohler <kohler@cs.ucla.edu>
Date: Fri, 22 Sep 2006 17:35:03 +0000
Subject: Re: [PATCH 5/7] [DCCP]: Introduce two new socket options
Message-Id: <45141EC7.2030207@cs.ucla.edu>
List-Id: <dccp.vger.kernel.org>
References: <200609221430.14555.ian.mcdonald@jandi.co.nz>
In-Reply-To: <200609221430.14555.ian.mcdonald@jandi.co.nz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

> Why burden the application programmer to handcode an estimation of the average each
> time? I can not see a justification for this, certainly not for CCIDs which
> are intended to be used with (on average) fixed packet sizes.
> 
> I think that a priority is to keep the user programming interface as simple as
> possible -- like UDP's interface, as stated in RFC 4340.

But if DCCP_SOCKOPT_TX_PACKET_SIZE defaults to the MSS, which the drafts 
explicitly allow, then there's no burden on the application programmer.

Hopefully this is my last mail on this subject; I do not think it is that 
important.  The option seems potentially useful and not a huge burden. 
Calculating the average would be good too.  But we do not have a patch for 
that at the moment.

Eddie
