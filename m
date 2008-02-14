From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 14 Feb 2008 13:48:26 +0000
Subject: [PATCH 5/5] [CCID]: Unused argument
Message-Id: <1202996906-29652-6-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This removes the argument `more' from ccid_hc_tx_packet_sent, since it was
nowhere used in the entire code.

(Anecdotally, this argument was not even used in the original KAME code where
 the function originally came from; compare the variable moreToSend in the
 freebsd61-dccp-kame-28.08.2006.patch now maintained by Emmanuel Lochin.)

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccid.h        |    6 +++---
 net/dccp/ccids/ccid2.c |    2 +-
 net/dccp/ccids/ccid3.c |    3 +--
 net/dccp/output.c      |    2 +-
 4 files changed, 6 insertions(+), 7 deletions(-)

--- a/net/dccp/ccid.h
+++ b/net/dccp/ccid.h
@@ -75,7 +75,7 @@ struct ccid_operations {
 	int		(*ccid_hc_tx_send_packet)(struct sock *sk,
 						  struct sk_buff *skb);
 	void		(*ccid_hc_tx_packet_sent)(struct sock *sk,
-						  int more, unsigned int len);
+						  unsigned int len);
 	void		(*ccid_hc_rx_get_info)(struct sock *sk,
 					       struct tcp_info *info);
 	void		(*ccid_hc_tx_get_info)(struct sock *sk,
@@ -165,10 +165,10 @@ static inline int ccid_hc_tx_send_packet(struct ccid *ccid, struct sock *sk,
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
@@ -224,7 +224,7 @@ static void ccid2_start_rto_timer(struct sock *sk)
 		       jiffies + hctx->ccid2hctx_rto);
 }
 
-static void ccid2_hc_tx_packet_sent(struct sock *sk, int more, unsigned int len)
+static void ccid2_hc_tx_packet_sent(struct sock *sk, unsigned int len)
 {
 	struct dccp_sock *dp = dccp_sk(sk);
 	struct ccid2_hc_tx_sock *hctx = ccid2_hc_tx_sk(sk);
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -376,8 +376,7 @@ static int ccid3_hc_tx_send_packet(struct sock *sk, struct sk_buff *skb)
 	return CCID_PACKET_SEND_AT_ONCE;
 }
 
-static void ccid3_hc_tx_packet_sent(struct sock *sk, int more,
-				    unsigned int len)
+static void ccid3_hc_tx_packet_sent(struct sock *sk, unsigned int len)
 {
 	struct ccid3_hc_tx_sock *hctx = ccid3_hc_tx_sk(sk);
 
--- a/net/dccp/output.c
+++ b/net/dccp/output.c
@@ -264,7 +264,7 @@ static void dccp_xmit_packet(struct sock *sk)
 	 * end this error is indistinguishable from loss, so that finally (if
 	 * the peer has no bugs) the drop is reported via receiver feedback.
 	 */
-	ccid_hc_tx_packet_sent(dp->dccps_hc_tx_ccid, sk, 0, len);
+	ccid_hc_tx_packet_sent(dp->dccps_hc_tx_ccid, sk, len);
 
 	/*
 	 * If the CCID needs to transfer additional header options out-of-band
