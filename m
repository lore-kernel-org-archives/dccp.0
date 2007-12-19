From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 19 Dec 2007 14:25:51 +0000
Subject: [PATCH 10/14] [ACKVEC]: Determine buffer length dynamically
Message-Id: <1198074355-18842-11-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

The length of the circular Ack Vector buffer is now determined dynamically,
as the span between head to tail.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ackvec.c  |   21 +++++++++++++++++++++
 net/dccp/ackvec.h  |    7 +++++++
 net/dccp/options.c |    7 ++++---
 3 files changed, 32 insertions(+), 3 deletions(-)

--- a/net/dccp/ackvec.h
+++ b/net/dccp/ackvec.h
@@ -22,6 +22,7 @@
  * the maximum size of a single Ack Vector. Setting %DCCPAV_NUM_ACKVECS to 1
  * will be sufficient for most cases of low Ack Ratios, using a value of 2 gives
  * more headroom if Ack Ratio is higher or when the sender acknowledges slowly.
+ * The maximum value is bounded by the u16 types for indices and functions.
  */
 #define DCCPAV_NUM_ACKVECS	2
 #define DCCPAV_MAX_ACKVEC_LEN	(DCCP_SINGLE_OPT_MAXLEN * DCCPAV_NUM_ACKVECS)
@@ -110,6 +111,7 @@ extern int dccp_ackvec_add(struct dccp_ackvec *av, const struct sock *sk,
 
 extern int  dccp_ackvec_update_records(struct dccp_ackvec *av, u64 seq, u8 sum);
 extern void dccp_ackvec_clear_state(struct dccp_ackvec *av, const u64 ackno);
+extern u16  dccp_ackvec_buflen(const struct dccp_ackvec *av);
 
 static inline bool dccp_ackvec_is_empty(const struct dccp_ackvec *av)
 {
@@ -149,6 +151,11 @@ static inline int dccp_ackvec_update_records(struct dccp_ackvec *av, u64 seq, u8
 	return -1;
 }
 
+static inline u16 dccp_ackvec_buflen(const struct dccp_ackvec *av)
+{
+	return 0;
+}
+
 static inline bool dccp_ackvec_is_empty(const struct dccp_ackvec *av)
 {
 	return true;
--- a/net/dccp/ackvec.c
+++ b/net/dccp/ackvec.c
@@ -114,6 +114,27 @@ static struct dccp_ackvec_record *dccp_ackvec_lookup(struct list_head *av_list,
 }
 
 /*
+ * Buffer index and length computation using modulo-buffersize arithmetic.
+ * Note that, as pointers move from right to left, head is `before' tail.
+ */
+static inline u16 dccp_ackvec_idx_add(const u16 a, const u16 b)
+{
+	return (a + b) % DCCPAV_MAX_ACKVEC_LEN;
+}
+
+static inline u16 dccp_ackvec_idx_sub(const u16 a, const u16 b)
+{
+	return dccp_ackvec_idx_add(a, DCCPAV_MAX_ACKVEC_LEN - b);
+}
+
+u16 dccp_ackvec_buflen(const struct dccp_ackvec *av)
+{
+	if (unlikely(av->av_overflow))
+		return DCCPAV_MAX_ACKVEC_LEN;
+	return dccp_ackvec_idx_sub(av->av_buf_tail, av->av_buf_head);
+}
+
+/*
  * If several packets are missing, the HC-Receiver may prefer to enter multiple
  * bytes with run length 0, rather than a single byte with a larger run length;
  * this simplifies table updates if one of the missing packets arrives.
--- a/net/dccp/options.c
+++ b/net/dccp/options.c
@@ -432,9 +432,10 @@ static int dccp_insert_option_timestamp_echo(struct dccp_sock *dp,
 int dccp_insert_option_ackvec(struct sock *sk, struct sk_buff *skb)
 {
 	struct dccp_ackvec *av = dccp_sk(sk)->dccps_hc_rx_ackvec;
+	const u16 buflen = dccp_ackvec_buflen(av);
 	/* Figure out how many options do we need to represent the ackvec */
-	const u16 nr_opts = DIV_ROUND_UP(av->av_vec_len, DCCP_SINGLE_OPT_MAXLEN);
-	u16 len = av->av_vec_len + 2 * nr_opts;
+	const u16 nr_opts = DIV_ROUND_UP(buflen, DCCP_SINGLE_OPT_MAXLEN);
+	u16 len = buflen + 2 * nr_opts;
 	u8 i, nonce = 0;
 	const unsigned char *tail, *from;
 	unsigned char *to;
@@ -451,7 +452,7 @@ int dccp_insert_option_ackvec(struct sock *sk, struct sk_buff *skb)
 	DCCP_SKB_CB(skb)->dccpd_opt_len += len;
 
 	to   = skb_push(skb, len);
-	len  = av->av_vec_len;
+	len  = buflen;
 	from = av->av_buf + av->av_buf_head;
 	tail = av->av_buf + DCCPAV_MAX_ACKVEC_LEN;
 
-- 
1.5.3.GIT

