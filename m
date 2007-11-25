From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Sun, 25 Nov 2007 00:21:28 +0000
Subject: [PATCH 03/18] [CCID2]: Fix sequence number arithmetic/comparisons
Message-Id: <1195950103-18102-4-git-send-email-acme@redhat.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>

This replaces use of normal subtraction with modulo-48 subtraction.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 net/dccp/ccids/ccid2.c |    9 ++-------
 1 files changed, 2 insertions(+), 7 deletions(-)

diff --git a/net/dccp/ccids/ccid2.c b/net/dccp/ccids/ccid2.c
index 7873dc7..5552218 100644
--- a/net/dccp/ccids/ccid2.c
+++ b/net/dccp/ccids/ccid2.c
@@ -24,9 +24,6 @@
 
 /*
  * This implementation should follow RFC 4341
- *
- * BUGS:
- * - sequence number wrapping
  */
 
 #include "../ccid.h"
@@ -619,9 +616,8 @@ static void ccid2_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
 		/* go through this ack vector */
 		while (veclen--) {
 			const u8 rl = *vector & DCCP_ACKVEC_LEN_MASK;
-			u64 ackno_end_rl;
+			u64 ackno_end_rl = SUB48(ackno, rl);
 
-			dccp_set_seqno(&ackno_end_rl, ackno - rl);
 			ccid2_pr_debug("ackvec start:%llu end:%llu\n",
 				       (unsigned long long)ackno,
 				       (unsigned long long)ackno_end_rl);
@@ -671,8 +667,7 @@ static void ccid2_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
 			if (done)
 				break;
 
-
-			dccp_set_seqno(&ackno, ackno_end_rl - 1);
+			ackno = SUB48(ackno_end_rl, 1);
 			vector++;
 		}
 		if (done)
-- 
1.5.3.4

