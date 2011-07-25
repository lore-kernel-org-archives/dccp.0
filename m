From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 25 Jul 2011 13:36:33 +0000
Subject: [PATCH 4/7] dccp ccid-2: use feature-negotiation to report Ack Ratio changes
Message-Id: <1311600996-6712-5-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This uses the new feature-negotiation framework to signal Ack Ratio changes,
as required by RFC 4341, sec. 6.1.2.

That raises some problems with CCID-2, which at the moment can not cope
gracefully with Ack Ratios > 1. Since these issues are not directly related
to feature negotiation, they are marked by a FIXME.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Signed-off-by: Samuel Jero <sj323707@ohio.edu>
Acked-by: Ian McDonald <ian.mcdonald@jandi.co.uk>
---
 net/dccp/ccids/ccid2.c |   10 +++++++++-
 net/dccp/proto.c       |    1 -
 2 files changed, 9 insertions(+), 2 deletions(-)

--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -184,7 +184,6 @@ int dccp_init_sock(struct sock *sk, const __u8 ctl_sock_initialized)
 	dp->dccps_rate_last	= jiffies;
 	dp->dccps_role		= DCCP_ROLE_UNDEFINED;
 	dp->dccps_service	= DCCP_SERVICE_CODE_IS_ABSENT;
-	dp->dccps_l_ack_ratio	= dp->dccps_r_ack_ratio = 1;
 	dp->dccps_tx_qlen	= sysctl_dccp_tx_qlen;
 
 	dccp_init_xmit_timers(sk);
--- a/net/dccp/ccids/ccid2.c
+++ b/net/dccp/ccids/ccid2.c
@@ -494,8 +494,16 @@ static void ccid2_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
 			if (hc->tx_rpdupack >= NUMDUPACK) {
 				hc->tx_rpdupack = -1; /* XXX lame */
 				hc->tx_rpseq    = 0;
-
+#ifdef __CCID2_COPES_GRACEFULLY_WITH_ACK_CONGESTION_CONTROL__
+				/*
+				 * FIXME: Ack Congestion Control is broken; in
+				 * the current state instabilities occurred with
+				 * Ack Ratios greater than 1; causing hang-ups
+				 * and long RTO timeouts. This needs to be fixed
+				 * before opening up dynamic changes. -- gerrit
+				 */
 				ccid2_change_l_ack_ratio(sk, 2 * dp->dccps_l_ack_ratio);
+#endif
 			}
 		}
 	}
