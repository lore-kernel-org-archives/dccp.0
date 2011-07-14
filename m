From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 14 Jul 2011 13:42:32 +0000
Subject: [PATCH 04/07] dccp ccid-2: use feature-negotiation to report Ack Ratio changes
Message-Id: <1310650955-5159-5-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This uses the new feature-negotiation framework to signal Ack Ratio changes,
as required by RFC 4341, sec. 6.1.2.

This raises some problems for CCID-2 since it can at the moment not cope
gracefully with Ack Ratio of e.g. 2. A FIXME has thus been added which
reverts to the existing policy of bypassing the Ack Ratio sysctl.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>

**** EDITORIAL: patches merged into this one from earlier iterations ***********
dccp: Enable the Ack Ratio Feature but keep CCID-2 Ack Congestion Control disabled

In order to effectively utilize the first patch of this series ("Prevent
Congestion Window > Sequence Window"), we need the Ack Ratio Feature. However,
this feature has been disabled because the CCID-2 Ack Congestion Control code
is so broken that it was causing major problems.

This patch enables the Ack Ratio Feature, but disables sending the feature
because of the Ack Congestion Control. This allows us to utilize the Ack
Ratio, but prevents the problems with broken Ack Congestion Control.

Signed-off-by: Samuel Jero <sj323707@ohio.edu>
**** EDITORIAL: patches merged into this one from earlier iterations ***********
---
 net/dccp/ccids/ccid2.c |   10 +++++++++-
 net/dccp/proto.c       |    1 -
 2 files changed, 9 insertions(+), 2 deletions(-)

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
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -184,7 +184,6 @@ int dccp_init_sock(struct sock *sk, const __u8 ctl_sock_initialized)
 	dp->dccps_rate_last	= jiffies;
 	dp->dccps_role		= DCCP_ROLE_UNDEFINED;
 	dp->dccps_service	= DCCP_SERVICE_CODE_IS_ABSENT;
-	dp->dccps_l_ack_ratio	= dp->dccps_r_ack_ratio = 1;
 	dp->dccps_tx_qlen	= sysctl_dccp_tx_qlen;
 
 	dccp_init_xmit_timers(sk);
-- 
1.7.2.5

