From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 03 Jan 2007 13:57:51 +0000
Subject: [PATCH 2/4][NEW]: More debug information for dccp_wait_for_ccid
Message-Id: <200701031357.51935@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[DCCP]: More debug information for dccp_wait_for_ccid

This adds more detail in the wait_for_ccid packet scheduling loop.
In particular, it informs about (i) when delay is used and (ii) why
a packet is discarded.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/output.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

--- a/net/dccp/output.c
+++ b/net/dccp/output.c
@@ -194,6 +194,7 @@ static int dccp_wait_for_ccid(struct soc
 		rc = ccid_hc_tx_send_packet(dp->dccps_hc_tx_ccid, sk, skb);
 		if (rc <= 0)
 			break;
+		dccp_pr_debug("delayed send by %d msec\n", rc);
 		delay = msecs_to_jiffies(rc);
 		sk->sk_write_pending++;
 		release_sock(sk);
@@ -268,7 +269,7 @@ void dccp_write_xmit(struct sock *sk, in
 				DCCP_BUG("err=%d after ccid_hc_tx_packet_sent",
 					 err);
 		} else {
-			dccp_pr_debug("packet discarded\n");
+			dccp_pr_debug("packet discarded due to err=%d\n", err);
 			kfree(skb);
 		}
 	}
