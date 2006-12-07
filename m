From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 07 Dec 2006 21:12:39 +0000
Subject: [Patch 3/12]: Warn when discarding packet due to internal errors
Message-Id: <200612072112.40032@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[DCCP]: Warn when discarding packet due to internal errors

This adds a (debug) warning message which is triggered whenever a packet is
discarded due to send failure.

It also adds a conditional, so that an interruption during dccp_wait_for_ccid
is not treated as a `BUG': the rationale is that interruptions are external,
whereas bug warnings are concerned with the internals.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/output.c |    6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

--- a/net/dccp/output.c
+++ b/net/dccp/output.c
@@ -242,7 +242,7 @@ void dccp_write_xmit(struct sock *sk, in
 				break;
 			} else
 				err = dccp_wait_for_ccid(sk, skb);
-			if (err)
+			if (err && err != -EINTR)
 				DCCP_BUG("err=%d after dccp_wait_for_ccid", err);
 		}
 
@@ -268,8 +268,10 @@ void dccp_write_xmit(struct sock *sk, in
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
 
