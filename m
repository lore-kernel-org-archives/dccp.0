From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Tue, 03 Oct 2006 03:41:37 +0000
Subject: Re: PACKET_SIZE option and congestion control on variable-length packets
Message-Id: <5640c7e00610022041n3e3e32bo97e45295fc0a61b5@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200610021108.57676@strip-the-willow>
In-Reply-To: <200610021108.57676@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 10/2/06, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> There have been discussions on whether `s' is fixed in CCID 2/3 or whether,
> in spite of RFC 4341/2, `s' is variable. To resolve the discussion into
> material which is practically implementable and yet does not defy existing
> standards-track documents, a simple algorithmic strategy is suggested below.
>
> An aside to the discussion was the PACKET_SIZE socket option, but in actual
> fact this option is of no use other than causing unnecessary confusion: for
> CCID 2 it is entirely irrelevant, and for CCID 3 (and its variations) it is
> redundant and not useful due to argumentation below.
>
> Strategy
> ----------
> 1/ Remove the PACKET_SIZE socket options as they don't help with the problem;
>     I have therefore updated Ian's patch to be used standalone [attached].

NAK this patch. At present it just sets s to be 256 bytes where the
spec says to use the MSS. My patch is not perfect but it is better
than this as it allows you to set the size where you can't at present,
nor with this patch.

Gerrit - your strategy below is OK, although complicated, but without
patches for these steps we shouldn't regress to a worse state.
Something can be implemented if it is better than mine but this isn't
yet.

> 2/ In the initialisation code, set ccid3hctx_s = ccid3hcrx_s = 0  instead of the
>     TFRC_STD_PACKET_SIZE (which would give wrong estimates)
> 3/ Update  ccid3hc{rx,tx}_s using the `payload len' value taken each time from
>         * dccp_sendmsg (after the check against dccp_mss_cache)
>         * dccp_v{4,6}_rcv (only on Data/DataAck packets)
>     using a moving average with a large q = 8/10 ... 9/10:
>        s  <--  q * s   +  (1-q) * len
> 4/ Don't use MTU minus header length for `s'  (justified below).
>
I agree that a moving average is better than my patch if it is implemented.

I think it is better again to track just packets per second but this
needs further discussions with the DCCP working group.

Ian
 --
Ian McDonald
Web: http://wand.net.nz/~iam4
Blog: http://imcdnzl.blogspot.com
WAND Network Research Group
Department of Computer Science
University of Waikato
New Zealand
