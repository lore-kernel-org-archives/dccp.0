From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Mon, 02 Jan 2006 16:53:56 +0000
Subject: [PATCH 1/3][DCCP]: Do not process a packet twice when it's received in a state != DCCP_OPEN
Message-Id: <39e6f6c70601020853u6c5345e5oae495bc3fa42c020@mail.gmail.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----=_Part_14004_31820136.1136220836415"
List-Id: <dccp.vger.kernel.org>
To: dccp@vger.kernel.org

------=_Part_14004_31820136.1136220836415
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Hi David,

 Please consider pulling from:

master.kernel.org:/pub/scm/linux/kernel/git/acme/net-2.6.16.git

Best Regards,

- Arnaldo

------=_Part_14004_31820136.1136220836415
Content-Type: text/x-patch; name=1.patch; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="1.patch"

tree 66fbefd8cb4805458e537a3ea143006f8f242d8c
parent a90860f526898b77e91b6b38e8d266b0bcd6c443
author Arnaldo Carvalho de Melo <acme@mandriva.com> 1136217256 -0200
committer Arnaldo Carvalho de Melo <acme@mandriva.com> 1136217256 -0200

[DCCP]: Do not process a packet twice when it's received in a state != DCCP_OPEN.

When packets are received, the connection is either in DCCP_OPEN [fast-path] or
it isn't.  If it's not [e.g. DCCP_PARTOPEN] upper layers will perform sanity
checks and parse options.  If it is in DCCP_OPEN, dccp_rcv_established() will do
it.  It is important not to re-parse options in dccp_rcv_established() when it
is not called from the fast-path.  Else, fore example, the ack vector will be
added twice and the CCID will see the packet twice.

The solution is to always enfore sanity checks from the upper layers.  When
packets arrive in the fast-path, sanity checks will be performed before calling
dccp_rcv_established().

Note(acme): I rewrote the patch to achieve the same result but keeping
dccp_rcv_established with the previous semantics and having it split into
__dccp_rcv_established, that doesn't does do any sanity check, code in state
!= DCCP_OPEN use this lighter version as they already do the sanity checks.

Signed-off-by: Andrea Bittau <a.bittau@cs.ucl.ac.uk>
Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>

------------------------------------------------------------------------------

 input.c |   56 ++++++++++++++++++++++++++++++++++----------------------
 1 file changed, 34 insertions(+), 22 deletions(-)

------------------------------------------------------------------------------

diff --git a/net/dccp/input.c b/net/dccp/input.c
index 55e921b..5e312b0 100644
--- a/net/dccp/input.c
+++ b/net/dccp/input.c
@@ -151,29 +151,12 @@ static int dccp_check_seqno(struct sock 
 	return 0;
 }
 
-int dccp_rcv_established(struct sock *sk, struct sk_buff *skb,
-			 const struct dccp_hdr *dh, const unsigned len)
+static inline int __dccp_rcv_established(struct sock *sk, struct sk_buff *skb,
+					 const struct dccp_hdr *dh,
+					 const unsigned len)
 {
 	struct dccp_sock *dp = dccp_sk(sk);
 
-	if (dccp_check_seqno(sk, skb))
-		goto discard;
-
-	if (dccp_parse_options(sk, skb))
-		goto discard;
-
-	if (DCCP_SKB_CB(skb)->dccpd_ack_seq != DCCP_PKT_WITHOUT_ACK_SEQ)
-		dccp_event_ack_recv(sk, skb);
-
-	if (dp->dccps_options.dccpo_send_ack_vector &&
-	    dccp_ackvec_add(dp->dccps_hc_rx_ackvec, sk,
-			    DCCP_SKB_CB(skb)->dccpd_seq,
-			    DCCP_ACKVEC_STATE_RECEIVED))
-		goto discard;
-
-	ccid_hc_rx_packet_recv(dp->dccps_hc_rx_ccid, sk, skb);
-	ccid_hc_tx_packet_recv(dp->dccps_hc_tx_ccid, sk, skb);
-
 	switch (dccp_hdr(skb)->dccph_type) {
 	case DCCP_PKT_DATAACK:
 	case DCCP_PKT_DATA:
@@ -250,6 +233,35 @@ discard:
 	return 0;
 }
 
+int dccp_rcv_established(struct sock *sk, struct sk_buff *skb,
+			 const struct dccp_hdr *dh, const unsigned len)
+{
+	struct dccp_sock *dp = dccp_sk(sk);
+
+	if (dccp_check_seqno(sk, skb))
+		goto discard;
+
+	if (dccp_parse_options(sk, skb))
+		goto discard;
+
+	if (DCCP_SKB_CB(skb)->dccpd_ack_seq != DCCP_PKT_WITHOUT_ACK_SEQ)
+		dccp_event_ack_recv(sk, skb);
+
+	if (dp->dccps_options.dccpo_send_ack_vector &&
+	    dccp_ackvec_add(dp->dccps_hc_rx_ackvec, sk,
+			    DCCP_SKB_CB(skb)->dccpd_seq,
+			    DCCP_ACKVEC_STATE_RECEIVED))
+		goto discard;
+
+	ccid_hc_rx_packet_recv(dp->dccps_hc_rx_ccid, sk, skb);
+	ccid_hc_tx_packet_recv(dp->dccps_hc_tx_ccid, sk, skb);
+
+	return __dccp_rcv_established(sk, skb, dh, len);
+discard:
+	__kfree_skb(skb);
+	return 0;
+}
+
 EXPORT_SYMBOL_GPL(dccp_rcv_established);
 
 static int dccp_rcv_request_sent_state_process(struct sock *sk,
@@ -400,9 +412,9 @@ static int dccp_rcv_respond_partopen_sta
 
 		if (dh->dccph_type == DCCP_PKT_DATAACK ||
 		    dh->dccph_type == DCCP_PKT_DATA) {
-			dccp_rcv_established(sk, skb, dh, len);
+			__dccp_rcv_established(sk, skb, dh, len);
 			queued = 1; /* packet was queued
-				       (by dccp_rcv_established) */
+				       (by __dccp_rcv_established) */
 		}
 		break;
 	}


------=_Part_14004_31820136.1136220836415--
