From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 04 Jul 2011 19:01:18 +0000
Subject: [PATCH 5/6] dccp ccid-2: Use existing function to test for data packets
Message-Id: <1309806079-21604-6-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This replaces a switch statement with a test, using the equivalent
function dccp_data_packet(skb).  It also doubles the range of the field
`rx_num_data_pkts' by changing the type from `int' to `u32', avoiding
signed/unsigned comparison with the u16 field `dccps_r_ack_ratio'.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/ccid2.c |   16 ++++++----------
 net/dccp/ccids/ccid2.h |    6 +++++-
 2 files changed, 11 insertions(+), 11 deletions(-)

--- a/net/dccp/ccids/ccid2.c
+++ b/net/dccp/ccids/ccid2.c
@@ -627,18 +627,14 @@ static void ccid2_hc_tx_exit(struct sock *sk)
 
 static void ccid2_hc_rx_packet_recv(struct sock *sk, struct sk_buff *skb)
 {
-	const struct dccp_sock *dp = dccp_sk(sk);
 	struct ccid2_hc_rx_sock *hc = ccid2_hc_rx_sk(sk);
 
-	switch (DCCP_SKB_CB(skb)->dccpd_type) {
-	case DCCP_PKT_DATA:
-	case DCCP_PKT_DATAACK:
-		hc->rx_data++;
-		if (hc->rx_data >= dp->dccps_r_ack_ratio) {
-			dccp_send_ack(sk);
-			hc->rx_data = 0;
-		}
-		break;
+	if (!dccp_data_packet(skb))
+		return;
+
+	if (++hc->rx_num_data_pkts >= dccp_sk(sk)->dccps_r_ack_ratio) {
+		dccp_send_ack(sk);
+		hc->rx_num_data_pkts = 0;
 	}
 }
 
--- a/net/dccp/ccids/ccid2.h
+++ b/net/dccp/ccids/ccid2.h
@@ -97,8 +97,12 @@ static inline u32 rfc3390_bytes_to_packets(const u32 smss)
 	return smss <= 1095 ? 4 : (smss > 2190 ? 2 : 3);
 }
 
+/**
+ * struct ccid2_hc_rx_sock  -  Receiving end of CCID-2 half-connection
+ * @rx_num_data_pkts: number of data packets received since last feedback
+ */
 struct ccid2_hc_rx_sock {
-	int	rx_data;
+	u32	rx_num_data_pkts;
 };
 
 static inline struct ccid2_hc_tx_sock *ccid2_hc_tx_sk(const struct sock *sk)
