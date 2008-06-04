From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 04 Jun 2008 13:38:49 +0000
Subject: Re: [PATCH - test-tree] DCCP: Increment sequence number on
Message-Id: <20080604133849.GA5583@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <4846462F.3020004@cn.fujitsu.com>
In-Reply-To: <4846462F.3020004@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Quoting Arnaldo:
| Em Wed, Jun 04, 2008 at 03:37:19PM +0800, Wei Yongjun escreveu:
| > When retransmit the first REQUEST, the sequence number does not be  
| > increased. This is because before retransmit the first REQUEST packet,  
| > the icsk->icsk_retransmits is 0, so dccp_transmit_skb() will fetch the  
| > dp->dccps_iss as the retransmit sequence number.
| >
| > This patch fix the problem.
| 
| Looks like a hack, ugh. Proper fix must be not bumping it on
| dccp_transmit_skb when the packet is a REQUEST, no?
| 
Yes, correct, it is a hack. I was working on that until one hour ago
and then decided to put it aside. The fix is in the test tree for now
but is not meant to remain there.

The problem is that, for the three retransmittable packet types in DCCP
(Close, CloseReq, Request), there is no obvious way of distinguishing
the original packet from the cloned packet.

Here is the sketch of the solution I was working on, I'd be glad for input:
 * dccp_entail(), skb_clone(), dccp_transmit_skb() and setting of the icsk
   retransmit timer always occur together;
 * as soon as skb_clone() is called, skb->cloned is true;
 * so the idea is to 
   - use dccp_transmit_skb() to transmit the un-cloned skb;
   - sk->send_head = skb_clone(skb, gfp_any())
   - need some more careful analysis, but I think the set_owner_w() can
     also be removed, needs checking against the WARN_ON in
     dccp_transmit_skb().

Or maybe there is an easier way - the objective is to have a clear
indicator whether the skb is a retransmitted one or the first one
(since a similar problem arises when sending Close(Req) packets).

Suggestions welcome.

Gerrit
