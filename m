From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Wed, 24 Oct 2007 13:11:02 +0000
Subject: [PATCH 2/5] [DCCP]: One more exemption from full sequence number
Message-Id: <20071024131102.GE6371@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This fixes the following problem: client connects to peer which has no DCCP
enabled or loaded; ICMP error messages ("Protocol Unavailable") can be seen
on the wire, but the application hangs. Reason: ICMP packets don't get through
to dccp_v4_err.

When reporting errors, a sequence number check is made for the DCCP packet
that had caused an ICMP error to arrive.
Such checks can not be made if the socket is in state LISTEN, RESPOND (which
in the implementation is the same as LISTEN), or REQUEST, since update_gsr()
has not been called in these states, hence the sequence window is 0..0.

This patch fixes the problem by adding the REQUEST state as another exemption
to the window check. The error reporting now works as expected on connecting.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
Signed-off-by: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
---
 net/dccp/ipv4.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index 3f1578d..01a6a80 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -242,7 +242,7 @@ static void dccp_v4_err(struct sk_buff *skb, u32 info)
 
 	dp = dccp_sk(sk);
 	seq = dccp_hdr_seq(dh);
-	if (sk->sk_state != DCCP_LISTEN &&
+	if ((1 << sk->sk_state) & ~(DCCPF_REQUESTING | DCCPF_LISTEN) &&
 	    !between48(seq, dp->dccps_swl, dp->dccps_swh)) {
 		NET_INC_STATS_BH(LINUX_MIB_OUTOFWINDOWICMPS);
 		goto out;
-- 
1.5.3.4

