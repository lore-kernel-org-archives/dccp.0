From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Sat, 29 Sep 2007 15:39:41 +0000
Subject: [PATCH 11/13] [DCCP]: Wrong format in printk
Message-Id: <20070929153941.GP23546@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

The elapsed time uses u32, but printk was using %d, not %u.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 net/dccp/options.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/dccp/options.c b/net/dccp/options.c
index 172eb6b..d361b55 100644
--- a/net/dccp/options.c
+++ b/net/dccp/options.c
@@ -179,7 +179,7 @@ int dccp_parse_options(struct sock *sk, struct sk_buff *skb)
 			else
 				elapsed_time = ntohl(*(__be32 *)(value + 4));
 
-			dccp_pr_debug_cat(", ELAPSED_TIME=%d\n", elapsed_time);
+			dccp_pr_debug_cat(", ELAPSED_TIME=%u\n", elapsed_time);
 
 			/* Give precedence to the biggest ELAPSED_TIME */
 			if (elapsed_time > opt_recv->dccpor_elapsed_time)
-- 
1.5.2.2

