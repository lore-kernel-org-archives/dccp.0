From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 12 Oct 2010 05:15:48 +0000
Subject: [PATCH 3/6] dccp: remove unused argument in CCID tx function
Message-Id: <1286860551-6809-4-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This removes the argument `more' from ccid_hc_tx_packet_sent, since it was
nowhere used in the entire code.

(Btw, this argument was not even used in the original KAME code where the
 function initially came from; compare the variable moreToSend in the
 freebsd61-dccp-kame-28.08.2006.patch kept by Emmanuel Lochin.)

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccid.h        |    6 +++---
 net/dccp/ccids/ccid2.c |    2 +-
 net/dccp/ccids/ccid3.c |    3 +--
 net/dccp/output.c      |    2 +-
 4 files changed, 6 insertions(+), 7 deletions(-)

--- a/net/dccp/ccid.h
+++ b/net/dccp/ccid.h
@@ -73,7 +73,7 @@ struct ccid_operations {
 	int		(*ccid_hc_tx_send_packet)(struct sock *sk,
 						  struct sk_buff *skb);
 	void		(*ccid_hc_tx_packet_sent)(struct sock *sk,
-						  int more, unsigned int len);
+						  unsigned int len);
 	void		(*ccid_hc_rx_get_info)(struct sock *sk,
 					       struct tcp_info *info);
 	void		(*ccid_hc_tx_get_info)(struct sock *sk,
@@ -144,10 +144,10 @@ static inline int ccid_hc_tx_send_packet(struct ccid *ccid, struct sock *sk,
 }
 
 static inline void ccid_hc_tx_packet_sent(struct ccid *ccid, struct sock *sk,
-					  int more, unsigned int len)
+					  unsigned int len)
 {
 	if (ccid->ccid_ops->ccid_hc_tx_packet_sent != NULL)
-		ccid->ccid_ops->ccid_hc_tx_packet_sent(sk, more, len);
+		ccid->ccid_ops->ccid_hc_tx_packet_sent(sk, len);
 }
 
 static inline void ccid_hc_rx_packet_recv(struct ccid *ccid, struct sock *sk,
--- a/net/dccp/ccids/ccid2.c
+++ b/net/dccp/ccids/ccid2.c
@@ -151,7 +151,7 @@ out:
 	sock_put(sk);
 }
 
-static void ccid2_hc_tx_packet_sent(struct sock *sk, int more, unsigned int len)
+static void ccid2_hc_tx_packet_sent(struct sock *sk, unsigned int len)
 {
 	struct dccp_sock *dp = dccp_sk(sk);
 	struct ccid2_hc_tx_sock *hc = ccid2_hc_tx_sk(sk);
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -351,8 +351,7 @@ static int ccid3_hc_tx_send_packet(struct sock *sk, struct sk_buff *skb)
 	return 0;
 }
 
-static void ccid3_hc_tx_packet_sent(struct sock *sk, int more,
-				    unsigned int len)
+static void ccid3_hc_tx_packet_sent(struct sock *sk, unsigned int len)
 {
 	struct ccid3_hc_tx_sock *hc = ccid3_hc_tx_sk(sk);
 
--- a/net/dccp/output.c
+++ b/net/dccp/output.c
@@ -304,7 +304,7 @@ void dccp_write_xmit(struct sock *sk, int block)
 				dcb->dccpd_type = DCCP_PKT_DATA;
 
 			err = dccp_transmit_skb(sk, skb);
-			ccid_hc_tx_packet_sent(dp->dccps_hc_tx_ccid, sk, 0, len);
+			ccid_hc_tx_packet_sent(dp->dccps_hc_tx_ccid, sk, len);
 			if (err)
 				DCCP_BUG("err=%d after ccid_hc_tx_packet_sent",
 					 err);
