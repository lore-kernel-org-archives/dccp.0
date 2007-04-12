From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Thu, 12 Apr 2007 21:14:20 +0000
Subject: [PATCH 03/29] Debug statements for Elapsed Time option
Message-Id: <20070412211420.GD21292@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This prints the value of the parsed Elapsed Time when received via a
Timestamp Echo option [RFC 4342, 13.3].

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
Signed-off-by: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
---
 net/dccp/options.c |    8 ++++++--
 1 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/net/dccp/options.c b/net/dccp/options.c
index 14b6212..34d536d 100644
--- a/net/dccp/options.c
+++ b/net/dccp/options.c
@@ -172,21 +172,25 @@ int dccp_parse_options(struct sock *sk, struct sk_buff *skb)
 			opt_recv->dccpor_timestamp_echo = ntohl(*(__be32 *)value);
 
 			dccp_pr_debug("%s rx opt: TIMESTAMP_ECHO=%u, len=%d, "
-				      "ackno=%llu, ",  dccp_role(sk),
+				      "ackno=%llu", dccp_role(sk),
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
-- 
1.5.0.6

