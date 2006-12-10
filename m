From: Arnaldo Carvalho de Melo <acme@mandriva.com>
Date: Sun, 10 Dec 2006 02:59:39 +0000
Subject: [PATCH 1/22] [DCCP]: Remove timeo from output.c
Message-Id: <20061210025938.GC17909@mandriva.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

It simplifies waiting for the CCID module to signal that a packet
is ready to be sent.  Other simplifications flow on from this such as
removing constants.

As a result of this EAGAIN is not returned any more by dccp_wait_for_ccid
(which would otherwise lead to unnecessarily discarding the packet in
dccp_write_xmit).

Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>
---
 net/dccp/dccp.h   |    2 --
 net/dccp/output.c |   26 ++++++--------------------
 2 files changed, 6 insertions(+), 22 deletions(-)

diff --git a/net/dccp/dccp.h b/net/dccp/dccp.h
index 6888698..44829d6 100644
--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -80,8 +80,6 @@ #define DCCP_RESOURCE_PROBE_INTERVAL ((u
 
 #define DCCP_RTO_MAX ((unsigned)(120 * HZ)) /* FIXME: using TCP value */
 
-#define DCCP_XMIT_TIMEO 30000 /* Time/msecs for blocking transmit per packet */
-
 /* sysctl variables for DCCP */
 extern int  sysctl_dccp_request_retries;
 extern int  sysctl_dccp_retries1;
diff --git a/net/dccp/output.c b/net/dccp/output.c
index 400c30b..29a8e85 100644
--- a/net/dccp/output.c
+++ b/net/dccp/output.c
@@ -175,14 +175,12 @@ void dccp_write_space(struct sock *sk)
 /**
  * dccp_wait_for_ccid - Wait for ccid to tell us we can send a packet
  * @sk: socket to wait for
- * @timeo: for how long
  */
-static int dccp_wait_for_ccid(struct sock *sk, struct sk_buff *skb,
-			      long *timeo)
+static int dccp_wait_for_ccid(struct sock *sk, struct sk_buff *skb)
 {
 	struct dccp_sock *dp = dccp_sk(sk);
 	DEFINE_WAIT(wait);
-	long delay;
+	unsigned long delay;
 	int rc;
 
 	while (1) {
@@ -190,8 +188,6 @@ static int dccp_wait_for_ccid(struct soc
 
 		if (sk->sk_err)
 			goto do_error;
-		if (!*timeo)
-			goto do_nonblock;
 		if (signal_pending(current))
 			goto do_interrupted;
 
@@ -199,12 +195,9 @@ static int dccp_wait_for_ccid(struct soc
 		if (rc <= 0)
 			break;
 		delay = msecs_to_jiffies(rc);
-		if (delay > *timeo || delay < 0)
-			goto do_nonblock;
-
 		sk->sk_write_pending++;
 		release_sock(sk);
-		*timeo -= schedule_timeout(delay);
+		schedule_timeout(delay);
 		lock_sock(sk);
 		sk->sk_write_pending--;
 	}
@@ -215,11 +208,8 @@ out:
 do_error:
 	rc = -EPIPE;
 	goto out;
-do_nonblock:
-	rc = -EAGAIN;
-	goto out;
 do_interrupted:
-	rc = sock_intr_errno(*timeo);
+	rc = -EINTR;
 	goto out;
 }
 
@@ -240,8 +230,6 @@ void dccp_write_xmit(struct sock *sk, in
 {
 	struct dccp_sock *dp = dccp_sk(sk);
 	struct sk_buff *skb;
-	long timeo = DCCP_XMIT_TIMEO; 	/* If a packet is taking longer than
-					   this we have other issues */
 
 	while ((skb = skb_peek(&sk->sk_write_queue))) {
 		int err = ccid_hc_tx_send_packet(dp->dccps_hc_tx_ccid, sk, skb);
@@ -251,10 +239,8 @@ void dccp_write_xmit(struct sock *sk, in
 				sk_reset_timer(sk, &dp->dccps_xmit_timer,
 						msecs_to_jiffies(err)+jiffies);
 				break;
-			} else {
-				err = dccp_wait_for_ccid(sk, skb, &timeo);
-				timeo = DCCP_XMIT_TIMEO;
-			}
+			} else
+				err = dccp_wait_for_ccid(sk, skb);
 			if (err)
 				DCCP_BUG("err=%d after dccp_wait_for_ccid", err);
 		}
-- 
1.4.2.1.g3d5c

