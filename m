From: Arnaldo Carvalho de Melo <acme@mandriva.com>
Date: Sun, 10 Dec 2006 03:02:26 +0000
Subject: [PATCH 12/22] [DCCP]: Warn when discarding packet due to internal errors
Message-Id: <20061210030225.GN17909@mandriva.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This adds a (debug) warning message which is triggered whenever a packet is
discarded due to send failure.

It also adds a conditional, so that an interruption during dccp_wait_for_ccid
is not treated as a `BUG': the rationale is that interruptions are external,
whereas bug warnings are concerned with the internals.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>
---
 net/dccp/output.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/dccp/output.c b/net/dccp/output.c
index 29a8e85..b4df12b 100644
--- a/net/dccp/output.c
+++ b/net/dccp/output.c
@@ -241,7 +241,7 @@ void dccp_write_xmit(struct sock *sk, in
 				break;
 			} else
 				err = dccp_wait_for_ccid(sk, skb);
-			if (err)
+			if (err && err != -EINTR)
 				DCCP_BUG("err=%d after dccp_wait_for_ccid", err);
 		}
 
@@ -267,8 +267,10 @@ void dccp_write_xmit(struct sock *sk, in
 			if (err)
 				DCCP_BUG("err=%d after ccid_hc_tx_packet_sent",
 					 err);
-		} else
+		} else {
+			dccp_pr_debug("packet discarded\n");
 			kfree(skb);
+		}
 	}
 }
 
-- 
1.4.2.1.g3d5c

