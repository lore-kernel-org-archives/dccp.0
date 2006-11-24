From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 24 Nov 2006 16:20:18 +0000
Subject: [PATCH 10/10]: Simplify dccp_rcv_state_process
Message-Id: <200611241620.18283@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[DCCP]: Simplify dccp_rcv_state_process

This patch does not change the algorithm, it just simplifies control flow a bit.

The main changes are:
 * cleanup after dccp_rcv_request_sent_state_process is now done within that function,
   not in dccp_rcv_state_process
 * as a result the control flow in dccp_rcv_request becomes a bit simpler  

Background:
  The information as to whether an skb is (still) queued is passed
  by dccp_rcv_state_process and some of the function it calls via the
  return value.  A return value of 1 means that the calling function
  (dccp_v{4,6}_do_rcv, possibly via dccp_child_process) needs to do some
  post-processing (discard the datagram and send a reset).

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/input.c |   34 +++++++++++++++++-----------------
 1 file changed, 17 insertions(+), 17 deletions(-)

--- a/net/dccp/input.c
+++ b/net/dccp/input.c
@@ -361,11 +361,11 @@ static int dccp_rcv_request_sent_state_p
 			 * schedule an ack here, as dccp_sendmsg does this for
 			 * us, also stated in the draft. -acme
 			 */
-			__kfree_skb(skb);
-			return 0;
-		} 
-		dccp_send_ack(sk);
-		return -1;
+		} else
+			dccp_send_ack(sk);
+
+		__kfree_skb(skb);
+		return 0;
 	}
 
 out_invalid_packet:
@@ -418,13 +418,17 @@ static int dccp_rcv_respond_partopen_sta
 	return queued;
 }
 
+/*
+ * returns
+ *    > 0: if skb is still queued and must be deleted later
+ *   = 0: if skb does not need any further processing
+ */
 int dccp_rcv_state_process(struct sock *sk, struct sk_buff *skb,
 			   struct dccp_hdr *dh, unsigned len)
 {
 	struct dccp_sock *dp = dccp_sk(sk);
 	struct dccp_skb_cb *dcb = DCCP_SKB_CB(skb);
 	const int old_state = sk->sk_state;
-	int queued = 0;
 
 	/*
 	 *  Step 3: Process LISTEN state
@@ -543,17 +547,15 @@ int dccp_rcv_state_process(struct sock *
 	case DCCP_REQUESTING:
 		/* FIXME: do congestion control initialization */
 
-		queued = dccp_rcv_request_sent_state_process(sk, skb, dh, len);
-		if (queued >= 0)
-			return queued;
-
-		__kfree_skb(skb);
-		return 0;
+		if (dccp_rcv_request_sent_state_process(sk, skb, dh, len))
+			return 1;
+		break;
 
 	case DCCP_RESPOND:
 	case DCCP_PARTOPEN:
-		queued = dccp_rcv_respond_partopen_state_process(sk, skb,
-								 dh, len);
+		if (dccp_rcv_respond_partopen_state_process(sk, skb,
+							    dh, len))
+			return 1;
 		break;
 	}
 
@@ -567,10 +569,8 @@ int dccp_rcv_state_process(struct sock *
 		}
 	}
 
-	if (!queued) { 
 discard:
-		__kfree_skb(skb);
-	}
+	__kfree_skb(skb);
 	return 0;
 }
 
