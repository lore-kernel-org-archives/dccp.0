From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 14 Feb 2008 13:48:23 +0000
Subject: [PATCH 2/5] [CCID]: Refine the wait-for-ccid mechanism
Message-Id: <1202996906-29652-3-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This extends the existing wait-for-ccid routine so that it may be used with
different types of CCID. It further addresses the problems listed below.

The code looks if the write queue is non-empty and grants the TX CCID up to
`timeout' jiffies to drain the queue. It will instead purge that queue if
 * the delay suggested by the CCID exceeds the time budget;
 * a socket error occurred while waiting for the CCID;
 * there is a signal pending (eg. annoyed user pressed Control-C);
 * the CCID does not support delays (we don't know how long it will take).


                 D e t a i l s  [can be removed]
                 -------------------------------
DCCP's sending mechanism functions a bit like non-blocking I/O: dccp_sendmsg()
will enqueue up to net.dccp.default.tx_qlen packets (default=5), without waiting
for them to be released to the network.

Rate-based CCIDs, such as CCID3/4, can impose sending delays of up to maximally
64 seconds (t_mbi in RFC 3448). Hence the write queue may still contain packets
when the application closes. Since the write queue is congestion-controlled by
the CCID, draining the queue is also under control of the CCID.

There are several problems that needed to be addressed:
 1) The queue-drain mechanism only works with rate-based CCIDs. If CCID2 for
    example has a full TX queue and becomes network-limited just as the
    application wants to close, then waiting for CCID2 to become unblocked could
    lead to an indefinite  delay (i.e., application "hangs").
 2) Since each TX CCID in turn uses a feedback mechanism, there may be changes
    in its sending policy while the queue is being drained. This can lead to
    further delays during which the application will not be able to terminate.
 3) The minimum wait time for CCID3/4 can be expected to be the queue length
    times the current inter-packet delay. For example if tx_qlen0 and a delay
    of 15 ms is used for each packet, then the application would have to wait
    for a minimum of 1.5 seconds before being allowed to exit.
 4) There is no way for the user/application to control this behaviour. It would
    be good to use the timeout argument of dccp_close() as an upper bound. Then
    the maximum time that an application is willing to wait for its CCIDs to can
    be set via the SO_LINGER option.

These problems are addressed by giving the CCID a grace period of up to the
`timeout' value.

The wait-for-ccid function is, as before, used when the application
 (a) has read all the data in its receive buffer and
 (b) if SO_LINGER was set with a non-zero linger time, or
 (c) the socket is either in the OPEN (active close) or in the PASSIVE_CLOSEREQ
     state (client application closes after receiving CloseReq).

In addition, there is a catch-all case by calling __skb_queue_purge() after
waiting for the CCID. This is necessary since the write queue may still have
data when
 (a) the host has been passively-closed,
 (b) abnormal termination (unread data, zero linger time),
 (c) wait-for-ccid could not finish within the given time limit.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/dccp.h   |    3 +-
 net/dccp/output.c |  122 ++++++++++++++++++++++++++++++-----------------------
 net/dccp/proto.c  |   15 ++++++-
 net/dccp/timer.c  |    2 +-
 4 files changed, 86 insertions(+), 56 deletions(-)

--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -215,8 +215,9 @@ extern void dccp_reqsk_send_ack(struct sk_buff *sk, struct request_sock *rsk);
 extern void dccp_send_sync(struct sock *sk, const u64 seq,
 			   const enum dccp_pkt_type pkt_type);
 
-extern void dccp_write_xmit(struct sock *sk, int block);
+extern void dccp_write_xmit(struct sock *sk);
 extern void dccp_write_space(struct sock *sk);
+extern void dccp_flush_write_queue(struct sock *sk, long *time_budget);
 
 extern void dccp_init_xmit_timers(struct sock *sk);
 static inline void dccp_clear_xmit_timers(struct sock *sk)
--- a/net/dccp/output.c
+++ b/net/dccp/output.c
@@ -204,49 +204,29 @@ void dccp_write_space(struct sock *sk)
 }
 
 /**
- * dccp_wait_for_ccid - Wait for ccid to tell us we can send a packet
+ * dccp_wait_for_ccid  -  Await CCID send permission
  * @sk:    socket to wait for
- * @skb:   current skb to pass on for waiting
- * @delay: sleep timeout in milliseconds (> 0)
- * This function is called by default when the socket is closed, and
- * when a non-zero linger time is set on the socket. For consistency
+ * @delay: timeout in jiffies
+ * This is used by CCIDs which need to delay the send time in process context.
  */
-static int dccp_wait_for_ccid(struct sock *sk, struct sk_buff *skb, int delay)
+static int dccp_wait_for_ccid(struct sock *sk, unsigned long delay)
 {
-	struct dccp_sock *dp = dccp_sk(sk);
 	DEFINE_WAIT(wait);
-	unsigned long jiffdelay;
-	int rc;
-
-	do {
-		dccp_pr_debug("delayed send by %d msec\n", delay);
-		jiffdelay = msecs_to_jiffies(delay);
-
-		prepare_to_wait(sk->sk_sleep, &wait, TASK_INTERRUPTIBLE);
+	long remaining;
 
-		sk->sk_write_pending++;
-		release_sock(sk);
-		schedule_timeout(jiffdelay);
-		lock_sock(sk);
-		sk->sk_write_pending--;
+	prepare_to_wait(sk->sk_sleep, &wait, TASK_INTERRUPTIBLE);
+	sk->sk_write_pending++;
+	release_sock(sk);
 
-		if (sk->sk_err)
-			goto do_error;
-		if (signal_pending(current))
-			goto do_interrupted;
+	remaining = schedule_timeout(delay);
 
-		rc = ccid_hc_tx_send_packet(dp->dccps_hc_tx_ccid, sk, skb);
-	} while ((delay = rc) > 0);
-out:
+	lock_sock(sk);
+	sk->sk_write_pending--;
 	finish_wait(sk->sk_sleep, &wait);
-	return rc;
-
-do_error:
-	rc = -EPIPE;
-	goto out;
-do_interrupted:
-	rc = -EINTR;
-	goto out;
+
+	if (signal_pending(current) || sk->sk_err)
+		return -1;
+	return remaining;
 }
 
 /**
@@ -296,7 +276,53 @@ static void dccp_xmit_packet(struct sock *sk)
 		dccp_send_sync(sk, dp->dccps_gsr, DCCP_PKT_SYNC);
 }
 
-void dccp_write_xmit(struct sock *sk, int block)
+/**
+ * dccp_flush_write_queue  -  Drain queue at end of connection
+ * Since dccp_sendmsg queues packets without waiting for them to be sent, it may
+ * happen that the TX queue is not empty at the end of a connection. We give the
+ * HC-sender CCID a grace period of up to @time_budget jiffies. If this function
+ * returns with a non-empty write queue, it will be purged later.
+ */
+void dccp_flush_write_queue(struct sock *sk, long *time_budget)
+{
+	struct dccp_sock *dp = dccp_sk(sk);
+	struct sk_buff *skb;
+	long delay, rc;
+
+	while (*time_budget > 0 && (skb = skb_peek(&sk->sk_write_queue))) {
+		rc = ccid_hc_tx_send_packet(dp->dccps_hc_tx_ccid, sk, skb);
+
+		switch (ccid_packet_dequeue_eval(rc)) {
+		case CCID_PACKET_WILL_DEQUEUE_LATER:
+			/*
+			 * If the CCID determines when to send, the next sending
+			 * time is unknown or the CCID may not even send again
+			 * (e.g. remote host crashes or lost Ack packets).
+			 */
+			DCCP_WARN("CCID did not manage to send all packets");
+			return;
+		case CCID_PACKET_DELAY:
+			delay = msecs_to_jiffies(rc);
+			if (delay > *time_budget)
+				return;
+			rc = dccp_wait_for_ccid(sk, delay);
+			if (rc < 0)
+				return;
+			*time_budget -= (delay - rc);
+			/* check again if we can send now */
+			break;
+		case CCID_PACKET_SEND_AT_ONCE:
+			dccp_xmit_packet(sk);
+			break;
+		case CCID_PACKET_ERR:
+			skb_dequeue(&sk->sk_write_queue);
+			kfree_skb(skb);
+			dccp_pr_debug("packet discarded due to err=%ld\n", rc);
+		}
+	}
+}
+
+void dccp_write_xmit(struct sock *sk)
 {
 	struct dccp_sock *dp = dccp_sk(sk);
 	struct sk_buff *skb;
@@ -308,19 +334,9 @@ void dccp_write_xmit(struct sock *sk, int block)
 		case CCID_PACKET_WILL_DEQUEUE_LATER:
 			return;
 		case CCID_PACKET_DELAY:
-			if (!block) {
-				sk_reset_timer(sk, &dp->dccps_xmit_timer,
-						msecs_to_jiffies(rc)+jiffies);
-				return;
-			}
-			rc = dccp_wait_for_ccid(sk, skb, rc);
-			if (rc && rc != -EINTR) {
-				DCCP_BUG("err=%d after dccp_wait_for_ccid", rc);
-				skb_dequeue(&sk->sk_write_queue);
-				kfree_skb(skb);
-				break;
-			}
-			/* fall through */
+			sk_reset_timer(sk, &dp->dccps_xmit_timer, (jiffies +
+							msecs_to_jiffies(rc)));
+			return;
 		case CCID_PACKET_SEND_AT_ONCE:
 			dccp_xmit_packet(sk);
 			break;
@@ -631,9 +647,8 @@ void dccp_send_close(struct sock *sk, const int active)
 		DCCP_SKB_CB(skb)->dccpd_type = DCCP_PKT_CLOSE;
 
 	if (active) {
-		dccp_write_xmit(sk, 1);
 		dccp_skb_entail(sk, skb);
-		dccp_transmit_skb(sk, skb_clone(skb, prio));
+		skb = skb_clone(skb, prio);
 		/*
 		 * Retransmission timer for active-close: RFC 4340, 8.3 requires
 		 * to retransmit the Close/CloseReq until the CLOSING/CLOSEREQ
@@ -646,6 +661,7 @@ void dccp_send_close(struct sock *sk, const int active)
 		 */
 		inet_csk_reset_xmit_timer(sk, ICSK_TIME_RETRANS,
 					  DCCP_TIMEOUT_INIT, DCCP_RTO_MAX);
-	} else
-		dccp_transmit_skb(sk, skb);
+	}
+
+	dccp_transmit_skb(sk, skb);
 }
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -756,7 +756,7 @@ int dccp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 		goto out_discard;
 
 	skb_queue_tail(&sk->sk_write_queue, skb);
-	dccp_write_xmit(sk,0);
+	dccp_write_xmit(sk);
 out_release:
 	release_sock(sk);
 	return rc ? : len;
@@ -979,9 +979,22 @@ void dccp_close(struct sock *sk, long timeout)
 		/* Check zero linger _after_ checking for unread data. */
 		sk->sk_prot->disconnect(sk, 0);
 	} else if (sk->sk_state != DCCP_CLOSED) {
+		/*
+		 * Normal connection termination. May need to wait if there are
+		 * still packets in the TX queue that are delayed by the CCID.
+		 */
+		dccp_flush_write_queue(sk, &timeout);
 		dccp_terminate_connection(sk);
 	}
 
+	/*
+	 * Flush write queue. This may be necessary in several cases:
+	 * - we have been closed by the peer but still have application data;
+	 * - abortive termination (unread data or zero linger time),
+	 * - normal termination but queue could not be flushed within time limit
+	 */
+	__skb_queue_purge(&sk->sk_write_queue);
+
 	sk_stream_wait_close(sk, timeout);
 
 adjudge_to_death:
--- a/net/dccp/timer.c
+++ b/net/dccp/timer.c
@@ -261,7 +261,7 @@ static void dccp_write_xmitlet(unsigned long data)
 	if (sock_owned_by_user(sk))
 		sk_reset_timer(sk, &dccp_sk(sk)->dccps_xmit_timer, jiffies + 1);
 	else
-		dccp_write_xmit(sk, 0);
+		dccp_write_xmit(sk);
 	bh_unlock_sock(sk);
 }
 
