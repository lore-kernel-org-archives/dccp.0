From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 26 Jul 2007 12:56:44 +0000
Subject: [PATCH 3/5]: Wrong format in printk
Message-Id: <200707261356.44426@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[DCCP]: Wrong format in printk

The elapsed time uses u32, but printk was using %d, not %u.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/options.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- a/net/dccp/options.c
+++ b/net/dccp/options.c
@@ -179,7 +179,7 @@ int dccp_parse_options(struct sock *sk, 
 				elapsed_time = ntohl(opt_val);
 			}
 
-			dccp_pr_debug_cat(", ELAPSED_TIME=%d\n", elapsed_time);
+			dccp_pr_debug_cat(", ELAPSED_TIME=%u\n", elapsed_time);
 
 			/* Give precedence to the biggest ELAPSED_TIME */
 			if (elapsed_time > opt_recv->dccpor_elapsed_time)
