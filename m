From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 01 Oct 2007 14:18:11 +0000
Subject: [PATCH 1/11]: Auxiliary function for smallest-fit option lengths
Message-Id: <200710011518.11436@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[DCCP]: Auxiliary function for smallest-fit option lengths

This introduces a function to determine the smallest-fit data type to carry options,
which is used by the feature-negotiation code to insert option values.

While doing this, I found that the same code is required to set the NDP length,
whose length is variable between 1..6 bytes (RFC 4340, 7.7). 

There seem to be remains of the old code base when apparently NDP count was only 3 
bytes long. I have removed the annotations, as well as an unused constant limiting
the maximum NDP value to 3 bytes, and added a FIXME to increase the data type for
NDP up to u64. I didn't want to add this to this patch also, since various other
parts (e.g. CCID3) implicitly rely on u32. For the moment, u32 seems to more than
ample anyway, so the FIXME could even remain until there is a `high-speed' CCID.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 include/linux/dccp.h |    4 +---
 net/dccp/feat.h      |    8 ++++++++
 net/dccp/options.c   |   13 ++++++-------
 3 files changed, 15 insertions(+), 10 deletions(-)

--- a/net/dccp/feat.h
+++ b/net/dccp/feat.h
@@ -112,4 +112,12 @@ extern int  dccp_feat_clone(struct sock 
 extern int  dccp_feat_clone_list(struct list_head const *, struct list_head *);
 extern int  dccp_feat_init(struct sock *sk);
 
+/* Find smallest-fit for @value, but not more than 6 bytes (current maximum) */
+static inline u8 dccp_bytes_per_value(const u64 value)
+{
+	if (value > 0xFFFFFFFFull)
+		return 6;
+	return value > 0xFFFF? 4 : (value > 0xFF? 2 : 1);
+}
+
 #endif /* _DCCP_FEAT_H */
--- a/net/dccp/options.c
+++ b/net/dccp/options.c
@@ -115,7 +115,7 @@ int dccp_parse_options(struct sock *sk, 
 				mandatory = 1;
 			break;
 		case DCCPO_NDP_COUNT:
-			if (len > 3)
+			if (len > 6)	/* FIXME: make dccpor_ndp u64 */
 				goto out_invalid_option;
 
 			opt_recv->dccpor_ndp = dccp_decode_value_var(value, len);
@@ -299,11 +299,6 @@ static void dccp_encode_value_var(const 
 		*to++ = (value & 0xFF);
 }
 
-static inline int dccp_ndp_len(const int ndp)
-{
-	return likely(ndp <= 0xFF) ? 1 : ndp <= 0xFFFF ? 2 : 3;
-}
-
 int dccp_insert_option(struct sock *sk, struct sk_buff *skb,
 			const unsigned char option,
 			const void *value, const unsigned char len)
@@ -337,7 +332,11 @@ static int dccp_insert_option_ndp(struct
 
 	if (ndp > 0) {
 		unsigned char *ptr;
-		const int ndp_len = dccp_ndp_len(ndp);
+		const int ndp_len = dccp_bytes_per_value(ndp);
+		/*
+		 * FIXME: increase the data type of dccps_ndp_count to u64 and
+		 * track changes in code - NDP is up to 6 bytes (RFC 4340, 7.7)
+		 */
 		const int len = ndp_len + 2;
 
 		if (DCCP_SKB_CB(skb)->dccpd_opt_len + len > DCCP_MAX_OPT_LEN)
--- a/include/linux/dccp.h
+++ b/include/linux/dccp.h
@@ -374,8 +374,6 @@ static inline unsigned int dccp_hdr_len(
 /* FIXME: for now we're default to 1 but it should really be 0 */
 #define DCCPF_INITIAL_SEND_NDP_COUNT		1
 
-#define DCCP_NDP_LIMIT 0xFFFFFF
-
 /**
   * struct dccp_minisock - Minimal DCCP connection representation
   *
@@ -456,7 +454,7 @@ extern int dccp_parse_options(struct soc
 			      struct sk_buff *skb);
 
 struct dccp_options_received {
-	u32	dccpor_ndp; /* only 24 bits */
+	u32	dccpor_ndp;		/* FIXME: can be up to 6 bytes (7.7) */
 	u32	dccpor_timestamp;
 	u32	dccpor_timestamp_echo;
 	u32	dccpor_elapsed_time;
