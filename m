From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Fri, 01 Dec 2006 22:44:09 +0000
Subject: Re: [PATCH 3/8]: Document boundaries and limits of the TFRC lookup table
Message-Id: <5640c7e00612011444i4c965d2dwc47a2763816fdb69@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200612011826.44541@strip-the-willow>
In-Reply-To: <200612011826.44541@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 12/2/06, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> [DCCP]: Document boundaries and limits of the TFRC lookup table
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>

Looks really good but can we keep how we simplify the equation in
there (the bit below)? It doesn't hurt to have too much documentation
and it compiles away to 0 bytes so doesn't affect performance...


> -/* Calculate the send rate as per section 3.1 of RFC3448
> -
> -Returns send rate in bytes per second
> -
> -Integer maths and lookups are used as not allowed floating point in kernel
> -
> -The function for Xcalc as per section 3.1 of RFC3448 is:
> -
> -X =                            s
> -     -------------------------------------------------------------
> -     R*sqrt(2*b*p/3) + (t_RTO * (3*sqrt(3*b*p/8) * p * (1+32*p^2)))
> -
> -where
> -X is the trasmit rate in bytes/second
> -s is the packet size in bytes
> -R is the round trip time in seconds
> -p is the loss event rate, between 0 and 1.0, of the number of loss events
> -  as a fraction of the number of packets transmitted
> -t_RTO is the TCP retransmission timeout value in seconds
> -b is the number of packets acknowledged by a single TCP acknowledgement
> -
> -we can assume that b = 1 and t_RTO is 4 * R. With this the equation becomes:
> -
> -X =                            s
> -     -----------------------------------------------------------------------
> -     R * sqrt(2 * p / 3) + (12 * R * (sqrt(3 * p / 8) * p * (1 + 32 * p^2)))
> -
> -
> -which we can break down into:
> -
> -X =     s
> -     --------
> -     R * f(p)
> -
> -where f(p) = sqrt(2 * p / 3) + (12 * sqrt(3 * p / 8) * p * (1 + 32 * p * p))
> -
-- 
Web: http://wand.net.nz/~iam4
Blog: http://imcdnzl.blogspot.com
WAND Network Research Group
