From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Wed, 20 Dec 2006 00:09:18 +0000
Subject: State of CCID3/todo
Message-Id: <5640c7e00612191609l252883dcqb92e91628ff76916@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Folks,

Been working away on testing and thought I'd summarise where I'm up
to. I've got it looking much better (matching closer to TFRC
throughput equation). Performance is still not so good for direct
connect boxes/boxes 1 hop away though :-(

We were putting long loss intervals in because we were testing against
~0 in calc_i_mean instead of ~0U. Patch sent - still to be merged.

We were sending at way too fast rate because t_ipi was getting
calculated down because s was too low initially at skb->len when it
was just a request packet. I've set this initially now to mss in a
patch soon to be sent. This has mostly been fixed. I was thinking of
altering ccid3_hc_tx_update_s to call ccid3_hc_tx_update_send_time
when s changed as this should help also but this causes a divide by
zero as x is zero initally... Still to look into this.

When we recalculate t_ipi we send a flood of packets or starve for a
while. This is due to the fact we don't check t_nom when the packet is
sent. Patch to be sent soon for this one.

We weren't taking account of long non-loss intervals. Patch sent for this one.

Calculating the first loss interval seems to be too optimistic - gives
way too high values. Still to look into.

We don't use ccval in loss calculation. Haven't looked into fixing
much. Hurts my head.

When we have multi packet loss we make multiple loss intervals of 1
which is wrong according to spec.
-- 
Web: http://wand.net.nz/~iam4
Blog: http://imcdnzl.blogspot.com
WAND Network Research Group
