From: Andrea Bittau <a.bittau@cs.ucl.ac.uk>
Date: Tue, 13 Dec 2005 09:34:02 +0000
Subject: [PATCH 3/3] DCCP: fix connect() race condition upon short connections
Message-Id: <20051213093402.GC8532@tribal.sorbonet.org>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

The connect system call will initiate a connection, poll whether the connection
has occured and right before returning, it will check whether the connection was
shut-down.  In such cases, it will return -1.  If a connection is really short,
it is possible that the connection occurs and terminates before connect()
returns.  Upon checking that the connection is closed, connect() will
incorrectly return -1 when the transfer did occur.

I was able to reproduce this race condition consistently by having a server send
3 packets upon connection and disconnect right after.  I believe this issue
might exist in TCP too although mitigated by the higher number of CLOSE states.

I believe there is a better solution than the one I proposed [simplest I could
think of].

Signed-off-by: Andrea Bittau <a.bittau@cs.ucl.ac.uk>

---

diff --git a/include/linux/dccp.h b/include/linux/dccp.h
index f5ddd89..44c7de6 100644
--- a/include/linux/dccp.h
+++ b/include/linux/dccp.h
@@ -451,6 +451,7 @@ struct dccp_sock {
 	__u8				dccps_hc_tx_insert_options:1;
 	int				dccps_l_ackr;
 	int				dccps_r_ackr;
+	struct tasklet_struct		dccps_delayed_ack;
 };
  
 static inline struct dccp_sock *dccp_sk(const struct sock *sk)
diff --git a/net/dccp/input.c b/net/dccp/input.c
index 757539a..168f55b 100644
--- a/net/dccp/input.c
+++ b/net/dccp/input.c
@@ -261,6 +261,24 @@ discard:
 
 EXPORT_SYMBOL_GPL(dccp_rcv_established);
 
+static void delayed_ack(unsigned long x) {
+        struct sock* sk;
+        struct dccp_sock *dp;
+
+        sk = (struct sock*) x;
+        dp = dccp_sk(sk);
+
+        bh_lock_sock(sk);
+        if (sk->sk_socket->state != SS_CONNECTING) {
+                dccp_send_ack(sk);
+		dp->dccps_delayed_ack.data = 0;
+        }
+        else {
+                tasklet_schedule(&dp->dccps_delayed_ack);
+        }
+        bh_unlock_sock(sk);
+}
+
 static int dccp_rcv_request_sent_state_process(struct sock *sk,
 					       struct sk_buff *skb,
 					       const struct dccp_hdr *dh,
@@ -371,7 +389,25 @@ static int dccp_rcv_request_sent_state_p
 			__kfree_skb(skb);
 			return 0;
 		} 
-		dccp_send_ack(sk);
+
+                /* There is a race condition in which the connect system call
+                 * returns after a short connection occured and finished.  In
+                 * such a case, connect will think the socket is closed and
+                 * return -1.  We prevent a backlog from occuring by checking
+                 * that the connect returned here.
+		 * -sorbo
+		 */
+                if (sk->sk_socket->state = SS_CONNECTING) {
+			/* check whether we already scheduled tasklet */
+			if (!dp->dccps_delayed_ack.data) {
+                        	tasklet_init(&dp->dccps_delayed_ack, 
+				             &delayed_ack, (unsigned long) sk);
+                        	tasklet_schedule(&dp->dccps_delayed_ack);
+			} else {
+				BUG_TRAP(dp->dccps_delayed_ack.data = 
+					 (unsigned long) sk);
+			}
+                }
 		return -1;
 	}
 
diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index 4331cda..e5e874b 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -1101,6 +1101,7 @@ int dccp_v4_init_sock(struct sock *sk)
 	dp->dccps_service = DCCP_SERVICE_INVALID_VALUE;
 	dp->dccps_l_ackr = 0;
 	dp->dccps_r_ackr = 0;
+	dp->dccps_delayed_ack.data = 0;
 
 	return 0;
 }
@@ -1136,6 +1137,9 @@ int dccp_v4_destroy_sock(struct sock *sk
 	ccid_exit(dp->dccps_hc_rx_ccid, sk);
 	ccid_exit(dp->dccps_hc_tx_ccid, sk);
 	dp->dccps_hc_rx_ccid = dp->dccps_hc_tx_ccid = NULL;
+
+	/* XXX need to kill tasklet if it's there! */
+	BUG_TRAP(!dp->dccps_delayed_ack.data);
 
 	return 0;
 }
