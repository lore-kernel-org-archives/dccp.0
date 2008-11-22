From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sat, 22 Nov 2008 10:30:39 +0000
Subject: [PATCH 3/5] dccp: Increase the scope of variable-length htonl/ntohl functions
Message-Id: <1227349841-9440-4-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This extends the scope of two available functions, encode|decode_value_var,
to work up to 6 (8) bytes, to match maximum requirements in the RFC.

These functions are going to be used both by general option processing and
feature negotiation code, hence declarations have been put into feat.h.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
Acked-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 net/dccp/feat.h    |   14 ++++++++++++++
 net/dccp/options.c |   21 ++++++++++++++-------
 2 files changed, 28 insertions(+), 7 deletions(-)

--- a/net/dccp/feat.h
+++ b/net/dccp/feat.h
@@ -124,4 +124,18 @@ extern int  dccp_feat_clone(struct sock *oldsk, struct sock *newsk);
 extern int  dccp_feat_clone_list(struct list_head const *, struct list_head *);
 extern int  dccp_feat_init(struct sock *sk);
 
+/*
+ * Encoding variable-length options and their maximum length.
+ *
+ * This affects NN options (SP options are all u8) and other variable-length
+ * options (see table 3 in RFC 4340). The limit is currently given the Sequence
+ * Window NN value (sec. 7.5.2) and the NDP count (sec. 7.7) option, all other
+ * options consume less than 6 bytes (timestamps are 4 bytes).
+ * When updating this constant (e.g. due to new internet drafts / RFCs), make
+ * sure that you also update all code which refers to it.
+ */
+#define DCCP_OPTVAL_MAXLEN	6
+
+extern void dccp_encode_value_var(const u64 value, u8 *to, const u8 len);
+extern u64  dccp_decode_value_var(const u8 *bf, const u8 len);
 #endif /* _DCCP_FEAT_H */
--- a/net/dccp/options.c
+++ b/net/dccp/options.c
@@ -29,16 +29,20 @@ int sysctl_dccp_feat_tx_ccid	      = DCCPF_INITIAL_CCID;
 int sysctl_dccp_feat_send_ack_vector = DCCPF_INITIAL_SEND_ACK_VECTOR;
 int sysctl_dccp_feat_send_ndp_count  = DCCPF_INITIAL_SEND_NDP_COUNT;
 
-static u32 dccp_decode_value_var(const unsigned char *bf, const u8 len)
+u64 dccp_decode_value_var(const u8 *bf, const u8 len)
 {
-	u32 value = 0;
+	u64 value = 0;
 
+	if (len >= DCCP_OPTVAL_MAXLEN)
+		value += ((u64)*bf++) << 40;
+	if (len > 4)
+		value += ((u64)*bf++) << 32;
 	if (len > 3)
-		value += *bf++ << 24;
+		value += ((u64)*bf++) << 24;
 	if (len > 2)
-		value += *bf++ << 16;
+		value += ((u64)*bf++) << 16;
 	if (len > 1)
-		value += *bf++ << 8;
+		value += ((u64)*bf++) << 8;
 	if (len > 0)
 		value += *bf;
 
@@ -298,9 +302,12 @@ out_invalid_option:
 
 EXPORT_SYMBOL_GPL(dccp_parse_options);
 
-static void dccp_encode_value_var(const u32 value, unsigned char *to,
-				  const unsigned int len)
+void dccp_encode_value_var(const u64 value, u8 *to, const u8 len)
 {
+	if (len >= DCCP_OPTVAL_MAXLEN)
+		*to++ = (value & 0xFF0000000000ull) >> 40;
+	if (len > 4)
+		*to++ = (value & 0xFF00000000ull) >> 32;
 	if (len > 3)
 		*to++ = (value & 0xFF000000) >> 24;
 	if (len > 2)
