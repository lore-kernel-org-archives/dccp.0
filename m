From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sat, 29 Sep 2007 16:42:54 +0000
Subject: [PATCH 2/3]: One more exemption from full sequence number checks
Message-Id: <200709291742.54639@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[DCCP]: One more exemption from full sequence number checks

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
---
 net/dccp/ipv4.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -242,7 +242,7 @@ static void dccp_v4_err(struct sk_buff *
 
 	dp = dccp_sk(sk);
 	seq = dccp_hdr_seq(dh);
-	if (sk->sk_state != DCCP_LISTEN &&
+	if ((1 << sk->sk_state) & ~(DCCPF_REQUESTING | DCCPF_LISTEN) &&
 	    !between48(seq, dp->dccps_swl, dp->dccps_swh)) {
 		NET_INC_STATS_BH(LINUX_MIB_OUTOFWINDOWICMPS);
 		goto out;
