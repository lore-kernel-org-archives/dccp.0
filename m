From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 01 Oct 2007 11:07:24 +0000
Subject: Re: [PATCH 2/9]: Query supported CCIDs
Message-Id: <200710011207.24964@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200709281630.17307@strip-the-willow>
In-Reply-To: <200709281630.17307@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

|  One thing is the pointer in the request_sock case that I have to
|  figure out what is best and possibly rework your patches to provide what
|  I think is best.
|  
I am looking forward to that - if you want me to change single patches, let me know.

I had one more thought regarding timestamping: currently CCID2 uses the old RFC2988 
RTT mechanism from Jacobson's old 1988 paper. RFC 4341 says that the sampling should 
be done at most once per cwnd, but RFC 1323 says that this is insufficient for 
high-speed networking. And today it is almost impossible to buy a computer /not/ with
a Gbps ethernet card.

In short - if you change the architecture, is is possible to keep a door open to
add a timestamping-based RTT algorithm to CCID2? That has been your suggestion 
anyway some emails ago and I like the idea.

There is further stuff that can be shared - I have some ideas for using the ICSK_RETRANS
to replace a lot of code duplication for the RTO timer in CCID2. Would make sense, since
in OPEN/PARTOPEN state the retransmit timer is never used (only for Request/Close/CloseReq).
