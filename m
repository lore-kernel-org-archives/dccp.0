From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Wed, 21 Nov 2007 15:28:32 +0000
Subject: [PATCH 10/11] [DCCP]: Ignore Ack Vectors / Elapsed Time on DCCP-Request also
Message-Id: <1195658913-24840-11-git-send-email-acme@redhat.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>

Small update with regard to RFC 4340 (references added as documentation):
on Requests, Ack Vectors / Elapsed Time should be ignored.
Length handling of Elapsed Time also simplified.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 net/dccp/options.c |   13 ++++++-------
 1 files changed, 6 insertions(+), 7 deletions(-)

diff --git a/net/dccp/options.c b/net/dccp/options.c
index d286cff..523250b 100644
--- a/net/dccp/options.c
+++ b/net/dccp/options.c
@@ -136,7 +136,7 @@ int dccp_parse_options(struct sock *sk, struct sk_buff *skb)
 			break;
 		case DCCPO_ACK_VECTOR_0:
 		case DCCPO_ACK_VECTOR_1:
-			if (pkt_type = DCCP_PKT_DATA)
+			if (dccp_packet_without_ack(skb))   /* RFC 4340, 11.4 */
 				break;
 
 			if (dccp_msk(sk)->dccpms_send_ack_vector &&
@@ -194,18 +194,17 @@ int dccp_parse_options(struct sock *sk, struct sk_buff *skb)
 				opt_recv->dccpor_elapsed_time = elapsed_time;
 			break;
 		case DCCPO_ELAPSED_TIME:
-			if (len != 2 && len != 4)
-				goto out_invalid_option;
-
-			if (pkt_type = DCCP_PKT_DATA)
-				continue;
+			if (dccp_packet_without_ack(skb))   /* RFC 4340, 13.2 */
+				break;
 
 			if (len = 2) {
 				__be16 opt_val2 = get_unaligned((__be16 *)value);
 				elapsed_time = ntohs(opt_val2);
-			} else {
+			} else if (len = 4) {
 				opt_val = get_unaligned((__be32 *)value);
 				elapsed_time = ntohl(opt_val);
+			} else {
+				goto out_invalid_option;
 			}
 
 			if (elapsed_time > opt_recv->dccpor_elapsed_time)
-- 
1.5.3.4

