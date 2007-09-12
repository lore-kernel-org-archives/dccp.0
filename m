From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 12 Sep 2007 14:35:14 +0000
Subject: [PATCH 3/5]: Ignore Ack Vectors / Elapsed Time on DCCP-Request also
Message-Id: <200709121535.14762@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[DCCP]: Ignore Ack Vectors / Elapsed Time on DCCP-Request also

Small update with regard to RFC 4340 (references added as documentation):
on Requests, Ack Vectors / Elapsed Time should be ignored.
Length handling of Elapsed Time also simplified.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>						
---
 net/dccp/options.c |   14 ++++++--------
 1 file changed, 6 insertions(+), 8 deletions(-)

--- a/net/dccp/options.c
+++ b/net/dccp/options.c
@@ -128,7 +128,7 @@ int dccp_parse_options(struct sock *sk, 
 			break;
 		case DCCPO_ACK_VECTOR_0:
 		case DCCPO_ACK_VECTOR_1:
-			if (pkt_type = DCCP_PKT_DATA)
+			if (dccp_packet_without_ack(skb))   /* RFC 4340, 11.4 */
 				break;
 
 			if (dccp_msk(sk)->dccpms_send_ack_vector &&
@@ -186,19 +186,17 @@ int dccp_parse_options(struct sock *sk, 
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
 				opt_val = get_unaligned((u16 *)value);
 				elapsed_time = ntohs((u16)opt_val);
-			} else {
+			} else if (len = 4) {
 				opt_val = get_unaligned((u32 *)value);
 				elapsed_time = ntohl(opt_val);
-			}
+			} else
+				goto out_invalid_option;
 
 			if (elapsed_time > opt_recv->dccpor_elapsed_time)
 				opt_recv->dccpor_elapsed_time = elapsed_time;
