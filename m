From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sat, 27 Oct 2007 11:34:29 +0000
Subject: [PATCH 3/6]: Fix sequence number arithmetic/comparisons
Message-Id: <200710271234.29484@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[CCID2]: Fix sequence number arithmetic/comparisons

This replaces use of normal subtraction with modulo-48 subtraction.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/ccid2.c |    9 ++-------
 1 file changed, 2 insertions(+), 7 deletions(-)

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
@@ -619,9 +616,8 @@ static void ccid2_hc_tx_packet_recv(stru
 		/* go through this ack vector */
 		while (veclen--) {
 			const u8 rl = *vector & DCCP_ACKVEC_LEN_MASK;
-			u64 ackno_end_rl;
+			u64 ackno_end_rl = SUB48(ackno, rl);
 
-			dccp_set_seqno(&ackno_end_rl, ackno - rl);
 			ccid2_pr_debug("ackvec start:%llu end:%llu\n",
 				       (unsigned long long)ackno,
 				       (unsigned long long)ackno_end_rl);
@@ -671,8 +667,7 @@ static void ccid2_hc_tx_packet_recv(stru
 			if (done)
 				break;
 
-
-			dccp_set_seqno(&ackno, ackno_end_rl - 1);
+			ackno = SUB48(ackno_end_rl, 1);
 			vector++;
 		}
 		if (done)
