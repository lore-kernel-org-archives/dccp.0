From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Sun, 25 Nov 2007 00:21:29 +0000
Subject: [PATCH 04/18] [CCID2]: Don't assign negative values to Ack Ratio
Message-Id: <1195950103-18102-5-git-send-email-acme@redhat.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>

Since it makes not sense to assign negative values to Ack Ratio, this
patch disallows this possibility.

As a consequence, a Bug test for negative Ack Ratio values becomes obsolete.

Furthermore, a check against overflow (as Ack Ratio may not exceed 2 bytes,
due to RFC 4340, 11.3) has been added.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 net/dccp/ccids/ccid2.c |    9 +++++----
 1 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/net/dccp/ccids/ccid2.c b/net/dccp/ccids/ccid2.c
index 5552218..f18235e 100644
--- a/net/dccp/ccids/ccid2.c
+++ b/net/dccp/ccids/ccid2.c
@@ -140,7 +140,7 @@ static int ccid2_hc_tx_send_packet(struct sock *sk, struct sk_buff *skb)
 	return 1; /* XXX CCID should dequeue when ready instead of polling */
 }
 
-static void ccid2_change_l_ack_ratio(struct sock *sk, int val)
+static void ccid2_change_l_ack_ratio(struct sock *sk, u32 val)
 {
 	struct dccp_sock *dp = dccp_sk(sk);
 	/*
@@ -159,9 +159,10 @@ static void ccid2_change_l_ack_ratio(struct sock *sk, int val)
 		if (val > max)
 			val = max;
 	}
+	if (val > 0xFFFF)		/* RFC 4340, 11.3 */
+		val = 0xFFFF;
 
-	ccid2_pr_debug("changing local ack ratio to %d\n", val);
-	WARN_ON(val <= 0);
+	ccid2_pr_debug("changing local ack ratio to %u\n", val);
 	dp->dccps_l_ack_ratio = val;
 }
 
@@ -572,7 +573,7 @@ static void ccid2_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
 				hctx->ccid2hctx_rpdupack = -1; /* XXX lame */
 				hctx->ccid2hctx_rpseq = 0;
 
-				ccid2_change_l_ack_ratio(sk, dp->dccps_l_ack_ratio << 1);
+				ccid2_change_l_ack_ratio(sk, 2 * dp->dccps_l_ack_ratio);
 			}
 		}
 	}
-- 
1.5.3.4

