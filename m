From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 14 Jun 2007 09:05:13 +0000
Subject: [PATCH 4/5]: Wait for CCID
Message-Id: <200706141005.13964@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[DCCP]: Wait for CCID

This performs a minor optimisation: when ccid_hc_tx_send_packet returns a value greater
zero, then the same call previously was done again at the begin of the while loop
in dccp_wait_for_ccid.

This patch exploits the available information and schedule-timeouts directly instead.

Documentation also added.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/output.c |   34 +++++++++++++++++++---------------
 1 file changed, 19 insertions(+), 15 deletions(-)

--- a/net/dccp/output.c
+++ b/net/dccp/output.c
@@ -174,34 +174,38 @@ void dccp_write_space(struct sock *sk)
 
 /**
  * dccp_wait_for_ccid - Wait for ccid to tell us we can send a packet
- * @sk: socket to wait for
+ * @sk:    socket to wait for
+ * @skb:   current skb to pass on for waiting
+ * @delay: sleep timeout in milliseconds (> 0)
+ * This function is called by default when the socket is closed, and
+ * when a non-zero linger time is set on the socket. For consistency
  */
-static int dccp_wait_for_ccid(struct sock *sk, struct sk_buff *skb)
+static int dccp_wait_for_ccid(struct sock *sk, struct sk_buff *skb, int delay)
 {
 	struct dccp_sock *dp = dccp_sk(sk);
 	DEFINE_WAIT(wait);
-	unsigned long delay;
+	unsigned long jiffdelay;
 	int rc;
 
-	while (1) {
+	do {
+		dccp_pr_debug("delayed send by %d msec\n", delay);
+		jiffdelay = msecs_to_jiffies(delay);
+
 		prepare_to_wait(sk->sk_sleep, &wait, TASK_INTERRUPTIBLE);
 
+		sk->sk_write_pending++;
+		release_sock(sk);
+		schedule_timeout(jiffdelay);
+		lock_sock(sk);
+		sk->sk_write_pending--;
+
 		if (sk->sk_err)
 			goto do_error;
 		if (signal_pending(current))
 			goto do_interrupted;
 
 		rc = ccid_hc_tx_send_packet(dp->dccps_hc_tx_ccid, sk, skb);
-		if (rc <= 0)
-			break;
-		dccp_pr_debug("delayed send by %d msec\n", rc);
-		delay = msecs_to_jiffies(rc);
-		sk->sk_write_pending++;
-		release_sock(sk);
-		schedule_timeout(delay);
-		lock_sock(sk);
-		sk->sk_write_pending--;
-	}
+	} while ((delay = rc) > 0);
 out:
 	finish_wait(sk->sk_sleep, &wait);
 	return rc;
@@ -228,7 +232,7 @@ void dccp_write_xmit(struct sock *sk, in
 						msecs_to_jiffies(err)+jiffies);
 				break;
 			} else
-				err = dccp_wait_for_ccid(sk, skb);
+				err = dccp_wait_for_ccid(sk, skb, err);
 			if (err && err != -EINTR)
 				DCCP_BUG("err=%d after dccp_wait_for_ccid", err);
 		}
