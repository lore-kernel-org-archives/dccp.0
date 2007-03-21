From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 21 Mar 2007 18:44:17 +0000
Subject: [PATCH 3/25]: Debug statements for Elapsed Time option
Message-Id: <200703211844.17587@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[DCCP]: Debug statements for Elapsed Time option

This prints the value of the parsed Elapsed Time when received via a
Timestamp Echo option [RFC 4342, 13.3].

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/options.c |    8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

--- a/net/dccp/options.c
+++ b/net/dccp/options.c
@@ -172,21 +172,25 @@ int dccp_parse_options(struct sock *sk, 
 			opt_recv->dccpor_timestamp_echo = ntohl(*(__be32 *)value);
 
 			dccp_pr_debug("%s rx opt: TIMESTAMP_ECHO=%u, len=%d, "
-				      "ackno=%llu, ",  dccp_role(sk),
+				      "ackno=%llu",  dccp_role(sk),
 				      opt_recv->dccpor_timestamp_echo,
 				      len + 2,
 				      (unsigned long long)
 				      DCCP_SKB_CB(skb)->dccpd_ack_seq);
 
 
-			if (len = 4)
+			if (len = 4) {
+				dccp_pr_debug_cat("\n");
 				break;
+			}
 
 			if (len = 6)
 				elapsed_time = ntohs(*(__be16 *)(value + 4));
 			else
 				elapsed_time = ntohl(*(__be32 *)(value + 4));
 
+			dccp_pr_debug_cat(", ELAPSED_TIME=%d\n", elapsed_time);
+
 			/* Give precedence to the biggest ELAPSED_TIME */
 			if (elapsed_time > opt_recv->dccpor_elapsed_time)
 				opt_recv->dccpor_elapsed_time = elapsed_time;
