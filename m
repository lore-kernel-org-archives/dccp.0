From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 05 Dec 2007 11:19:46 +0000
Subject: [PATCH v2 0/3][BUG-FIX]: Test tree updates and bug fixes
Message-Id: <11968535861367-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <11968535863312-git-send-email-gerrit@erg.abdn.ac.uk>
In-Reply-To: <11968535863312-git-send-email-gerrit@erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This patch removes the following redundancies:
  * ccid3_hc_rx_update_s() is only called for data packets (that is what it should be called for);
  * each call to ccid3_hc_rx_update_s() is wrapped inside a "if (is_data_packet)" test';
  * therefore testing each time if "len > 0" is redundant (pointed out by Arnaldo);
  * no other code calls this function, hence the inline function can go.

Also replaced the first call to updating s with direct assignment of `payload_size'; this has also
been pointed out by Arnaldo.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/ccid3.c |   13 +++++--------
 1 file changed, 5 insertions(+), 8 deletions(-)

--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -654,12 +654,6 @@ static void ccid3_hc_rx_set_state(struct
 	hcrx->ccid3hcrx_state = state;
 }
 
-static inline void ccid3_hc_rx_update_s(struct ccid3_hc_rx_sock *hcrx, int len)
-{
-	if (likely(len > 0))	/* don't update on empty packets (e.g. ACKs) */
-		hcrx->ccid3hcrx_s = tfrc_ewma(hcrx->ccid3hcrx_s, len, 9);
-}
-
 static void ccid3_hc_rx_send_feedback(struct sock *sk, struct sk_buff *skb,
 				      enum ccid3_fback_type fbtype)
 {
@@ -788,8 +782,8 @@ static void ccid3_hc_rx_packet_recv(stru
 	if (unlikely(hcrx->ccid3hcrx_state = TFRC_RSTATE_NO_DATA)) {
 		if (is_data_packet) {
 			do_feedback = FBACK_INITIAL;
+			hcrx->ccid3hcrx_s = payload_size;
 			ccid3_hc_rx_set_state(sk, TFRC_RSTATE_DATA);
-			ccid3_hc_rx_update_s(hcrx, payload_size);
 		}
 		goto update_records;
 	}
@@ -798,7 +792,10 @@ static void ccid3_hc_rx_packet_recv(stru
 		goto done_receiving;
 
 	if (is_data_packet) {
-		ccid3_hc_rx_update_s(hcrx, payload_size);
+		/*
+		 * Update moving-average of s and the sum of received payload bytes
+		 */
+		hcrx->ccid3hcrx_s = tfrc_ewma(hcrx->ccid3hcrx_s, payload_size, 9);
 		hcrx->ccid3hcrx_bytes_recv += payload_size;
 	}
 
