From: Arnaldo Carvalho de Melo <acme@mandriva.com>
Date: Sun, 26 Nov 2006 03:18:55 +0000
Subject: [PATCH 3/4] [DCCP] ackvec: Split long ack vectors across multiple options
Message-Id: <20061126031855.GD17851@mandriva.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Ack vectors grow proportional to the window size.  If an ack vector does not fit
into a single option, it must be spread across multiple options.  This patch
will allow for windows to grow larger.

Committer note: Simplified the patch a bit, original algorithm kept.

Signed-off-by: Andrea Bittau <a.bittau@cs.ucl.ac.uk>
Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>
---
 net/dccp/ackvec.c |   46 ++++++++++++++++++++++++++++++++--------------
 1 files changed, 32 insertions(+), 14 deletions(-)

diff --git a/net/dccp/ackvec.c b/net/dccp/ackvec.c
index 41d34d1..bdf1bb7 100644
--- a/net/dccp/ackvec.c
+++ b/net/dccp/ackvec.c
@@ -68,10 +68,15 @@ int dccp_insert_option_ackvec(struct soc
 {
 	struct dccp_sock *dp = dccp_sk(sk);
 	struct dccp_ackvec *av = dp->dccps_hc_rx_ackvec;
-	int len = av->dccpav_vec_len + 2;
+	/* Figure out how many options do we need to represent the ackvec */
+	const u16 nr_opts = (av->dccpav_vec_len +
+			     DCCP_MAX_ACKVEC_OPT_LEN - 1) /
+			    DCCP_MAX_ACKVEC_OPT_LEN;
+	u16 len = av->dccpav_vec_len + 2 * nr_opts, i;
 	struct timeval now;
 	u32 elapsed_time;
-	unsigned char *to, *from;
+	const unsigned char *tail, *from;
+	unsigned char *to;
 	struct dccp_ackvec_record *avr;
 
 	if (DCCP_SKB_CB(skb)->dccpd_opt_len + len > DCCP_MAX_OPT_LEN)
@@ -90,24 +95,37 @@ int dccp_insert_option_ackvec(struct soc
 
 	DCCP_SKB_CB(skb)->dccpd_opt_len += len;
 
-	to    = skb_push(skb, len);
-	*to++ = DCCPO_ACK_VECTOR_0;
-	*to++ = len;
-
+	to   = skb_push(skb, len);
 	len  = av->dccpav_vec_len;
 	from = av->dccpav_buf + av->dccpav_buf_head;
+	tail = av->dccpav_buf + DCCP_MAX_ACKVEC_LEN;
+
+	for (i = 0; i < nr_opts; ++i) {
+		int copylen = len;
+
+		if (len > DCCP_MAX_ACKVEC_OPT_LEN)
+			copylen = DCCP_MAX_ACKVEC_OPT_LEN;
 
-	/* Check if buf_head wraps */
-	if ((int)av->dccpav_buf_head + len > DCCP_MAX_ACKVEC_LEN) {
-		const u32 tailsize = DCCP_MAX_ACKVEC_LEN - av->dccpav_buf_head;
+		*to++ = DCCPO_ACK_VECTOR_0;
+		*to++ = copylen + 2;
+
+		/* Check if buf_head wraps */
+		if (from + copylen > tail) {
+			const u16 tailsize = tail - from;
+
+			memcpy(to, from, tailsize);
+			to	+= tailsize;
+			len	-= tailsize;
+			copylen	-= tailsize;
+			from	= av->dccpav_buf;
+		}
 
-		memcpy(to, from, tailsize);
-		to   += tailsize;
-		len  -= tailsize;
-		from = av->dccpav_buf;
+		memcpy(to, from, copylen);
+		from += copylen;
+		to   += copylen;
+		len  -= copylen;
 	}
 
-	memcpy(to, from, len);
 	/*
 	 *	From RFC 4340, A.2:
 	 *
-- 
1.4.2.1.g3d5c

