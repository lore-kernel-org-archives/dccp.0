From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Tue, 28 Nov 2006 19:49:20 +0000
Subject: Re: [PATCH 2/2]: Use `unsigned' for packet lengths
Message-Id: <5640c7e00611281149m42a748en5a7699a47cedacac@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200611281435.05466@strip-the-willow>
In-Reply-To: <200611281435.05466@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 11/29/06, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> These are further changes - do you think that this would improve anything - I don't know.
> The proposed change of u32 for payload length seems fully sufficient in my eyes since
> with that we have more than enough for IPv4 and in IPv6 we are already in jumbogram-dimensions.
>
I think I didn't explain my point well here. You can't change to u32
but need to be unsigned int (not u64). u32 is plenty but skb->len gets
passed into the length parameter... Or that's how I read it anyway.

e.g. net/dccp/output.c dccp_write_xmit:
		err = ccid_hc_tx_send_packet(dp->dccps_hc_tx_ccid, sk, skb,
					 skb->len);
which then goes through callback to the code in the patch.

> I have two other suggestions regarding 64-bit unsigned - I think it would make sense to store
> the calculated send rate in bytes per microsecond, since there are some nasty conversion problems
> attached to it, as well as division errors. I am working on this right now.
>
Disagree if I understand you. This would imply minimum send rate of 1
million bytes per second which is often not achievable.

Regards,

Ian
-- 
Ian McDonald
Web: http://wand.net.nz/~iam4
Blog: http://imcdnzl.blogspot.com
WAND Network Research Group
Department of Computer Science
University of Waikato
New Zealand
