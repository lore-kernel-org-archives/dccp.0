From: Leandro <leandroal@gmail.com>
Date: Thu, 01 Nov 2007 00:31:25 +0000
Subject: [PATCH 13/25] Share TFRC feedback types struct via tfrc_ccids
Message-Id: <200710312131.25680.leandroal@gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200710310959.15075@strip-the-willow>
In-Reply-To: <200710310959.15075@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[CCID-3/4] Share TFRC feedback types struct via tfrc_ccids

Signed-off-by: Leandro Melo de Sales <leandro@embedded.ufcg.edu.br>

Index: leandro.new/net/dccp/ccids/ccid3.c
=================================--- leandro.new.orig/net/dccp/ccids/ccid3.c
+++ leandro.new/net/dccp/ccids/ccid3.c
@@ -660,7 +660,7 @@ static inline void ccid3_hc_rx_update_s(
 }
 
 static void ccid3_hc_rx_send_feedback(struct sock *sk, struct sk_buff *skb,
-				      enum ccid3_fback_type fbtype)
+				      enum tfrc_fback_type fbtype)
 {
 	struct ccid3_hc_rx_sock *hcrx = ccid3_hc_rx_sk(sk);
 	struct dccp_sock *dp = dccp_sk(sk);
@@ -777,7 +777,7 @@ static u32 ccid3_first_li(struct sock *s
 static void ccid3_hc_rx_packet_recv(struct sock *sk, struct sk_buff *skb)
 {
 	struct ccid3_hc_rx_sock *hcrx = ccid3_hc_rx_sk(sk);
-	enum   ccid3_fback_type  do_feedback = FBACK_NONE;
+	enum   tfrc_fback_type  do_feedback = FBACK_NONE;
 	u64 ndp = dccp_sk(sk)->dccps_options_received.dccpor_ndp;
 	u32 sample, payload_size = skb->len - dccp_hdr(skb)->dccph_doff * 4;
 	u8  is_data_packet = dccp_data_packet(skb);
Index: leandro.new/net/dccp/ccids/ccid3.h
=================================--- leandro.new.orig/net/dccp/ccids/ccid3.h
+++ leandro.new/net/dccp/ccids/ccid3.h
@@ -88,14 +88,6 @@ static inline struct ccid3_hc_tx_sock *c
     return hctx;
 }
 
-/* CCID3 feedback types */
-enum ccid3_fback_type {
-	FBACK_NONE = 0,
-	FBACK_INITIAL,
-	FBACK_PERIODIC,
-	FBACK_PARAM_CHANGE
-};
-
 /** struct ccid3_hc_rx_sock - CCID3 receiver half-connection socket
  *
  *  @ccid3hcrx_last_counter  -  Tracks window counter (RFC 4342, 8.1)
Index: leandro.new/net/dccp/ccids/ccid4.c
=================================--- leandro.new.orig/net/dccp/ccids/ccid4.c
+++ leandro.new/net/dccp/ccids/ccid4.c
@@ -686,7 +686,7 @@ static inline void ccid4_hc_rx_update_s(
 }
 
 static void ccid4_hc_rx_send_feedback(struct sock *sk, struct sk_buff *skb,
-				      enum ccid4_fback_type fbtype)
+				      enum tfrc_fback_type fbtype)
 {
 	struct ccid4_hc_rx_sock *hcrx = ccid4_hc_rx_sk(sk);
 	struct dccp_sock *dp = dccp_sk(sk);
@@ -803,7 +803,7 @@ static u32 ccid4_first_li(struct sock *s
 static void ccid4_hc_rx_packet_recv(struct sock *sk, struct sk_buff *skb)
 {
 	struct ccid4_hc_rx_sock *hcrx = ccid4_hc_rx_sk(sk);
-	enum   ccid4_fback_type  do_feedback = FBACK_NONE;
+	enum   tfrc_fback_type  do_feedback = FBACK_NONE;
 	u64 ndp = dccp_sk(sk)->dccps_options_received.dccpor_ndp;
 	u32 sample, payload_size = skb->len - dccp_hdr(skb)->dccph_doff * 4;
 	u8  is_data_packet = dccp_data_packet(skb);
Index: leandro.new/net/dccp/ccids/ccid4.h
=================================--- leandro.new.orig/net/dccp/ccids/ccid4.h
+++ leandro.new/net/dccp/ccids/ccid4.h
@@ -111,14 +111,6 @@ static inline struct ccid4_hc_tx_sock *c
     return hctx;
 }
 
-/* CCID4 feedback types */
-enum ccid4_fback_type {
-	FBACK_NONE = 0,
-	FBACK_INITIAL,
-	FBACK_PERIODIC,
-	FBACK_PARAM_CHANGE
-};
-
 /** struct ccid4_hc_rx_sock - CCID4 receiver half-connection socket
  *
  *  @ccid4hcrx_last_counter  -  Tracks window counter (RFC 4342, 8.1)
Index: leandro.new/net/dccp/ccids/lib/tfrc_ccids.h
=================================--- leandro.new.orig/net/dccp/ccids/lib/tfrc_ccids.h
+++ leandro.new/net/dccp/ccids/lib/tfrc_ccids.h
@@ -61,3 +61,11 @@ enum tfrc_hc_rx_states {
 	TFRC_RSTATE_TERM    = 127,
 };
 
+/* CCID3/4 feedback types */
+enum tfrc_fback_type {
+	FBACK_NONE = 0,
+	FBACK_INITIAL,
+	FBACK_PERIODIC,
+	FBACK_PARAM_CHANGE
+};
+
