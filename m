From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 25 Jul 2008 10:25:58 +0000
Subject: Re: [PATCH 5/6] dccp: Fix incorrect length check for ICMPv4 packets
Message-Id: <20080725102558.GB21357@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <1216976578-17767-6-git-send-email-gerrit@erg.abdn.ac.uk>
In-Reply-To: <1216976578-17767-6-git-send-email-gerrit@erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

| > -	if (skb->len < (iph->ihl << 2) + 8) {
| > +	if (skb->len < (iph->ihl << 2) + __dccp_basic_hdr_len(dh)) {
| >  		ICMP_INC_STATS_BH(net, ICMP_MIB_INERRORS);
| >  		return;
| >  	}
| 
| You can't dereference "dh" before you know there is even
| space past offset "iph->ihl << 2".  Yet that is what doing
| an unconditional __dccp_basic_hdr_len() call here is going
| to do.
| 
Oh that was my fault. Thanks a lot for pointing this out.

Will work out a fixed/improved version for both patches,
test and then resubmit.

Gerrit
