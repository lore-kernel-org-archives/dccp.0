From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 21 Mar 2007 18:45:20 +0000
Subject: [PATCH 15/25]: Disable softirq when sending and notifying CCID
Message-Id: <200703211845.20649@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[DCCP]: Disable softirq when sending and notifying CCID

This disables softirqs when performing the CCID-specific send operation
in dccp_write_xmit, so that actual sending, and calling the CCID post-send
routine becomes an atomic unit.

Why this needs to be done:
--------------------------
 The function dccp_write_xmit can be called both in user context (via
 dccp_sendmsg) and via timer softirq (dccp_write_xmit_timer). It does 

  1. call the CCID-specific `pre-send' routine ccid_hc_tx_send_packet()
  2. ship the skb via dccp_transmit_skb
  3. call the CCID-specific `post-send' routine ccid_hc_tx_packet_sent().

 The last one does e.g. accounting by updating data records (as in CCID 3).

 The transition from 2 ... 3 should be atomic and not be interrupted
 by softirqs.  The reason is that the TX and RX halves of the CCID modules
 share data structures and both halves change state. If the sending process is
 allowed to be interrupted by the reception of a DCCP packet via softirq
 handler, then state and data structures of the sender can become corrupted.

 Here is an actual example whose effects were observed and lead to this patch:
 in CCID 3 the sender records a timestamp when ccid_hc_tx_packet_sent() is called.
 If the application is sending via dccp_sendmsg, it may be interrupted and run a
 little while later. Suppose that such interruption happens between steps (2) and
 (3) above: the packet has been sent, and immediately afterwards dccp_sendmsg is
 interrupted. Meanwhile the transmitted skb reaches the other side, and an Ack
 comes back; this Ack is processed via softirq (which is allowed to interrupt 
 dccp_sendmsg); only then step (3) is performed, but too late: the timestamp
 taken in ccid3_hc_tx_packet_sent is now /after/ the Ack has come in.

 In the observed case, negative RTT samples (i.e. Acks arriving before the
 sent packet was registered) were the result.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/output.c |   13 ++++++++++---
 1 file changed, 10 insertions(+), 3 deletions(-)

--- a/net/dccp/output.c
+++ b/net/dccp/output.c
@@ -250,11 +250,18 @@ void dccp_write_xmit(struct sock *sk, in
 			else
 				dcb->dccpd_type = DCCP_PKT_DATA;
 
+			/*
+			 * Transmission and calling the post-send CCID operation
+			 * must not be interrupted by other processing (e.g.
+			 * packet reception), otherwise strange errors result.
+			 */
+			local_bh_disable();
 			err = dccp_transmit_skb(sk, skb);
 			ccid_hc_tx_packet_sent(dp->dccps_hc_tx_ccid, sk, 0, len);
-			if (err)
-				DCCP_BUG("err=%d after ccid_hc_tx_packet_sent",
-					 err);
+			local_bh_enable();
+
+			if (unlikely(err))
+				DCCP_BUG("dccp_transmit_skb returned %d", err);
 		} else {
 			dccp_pr_debug("packet discarded due to err=%d\n", err);
 			kfree_skb(skb);
