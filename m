From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 19 Dec 2007 14:25:44 +0000
Subject: [PATCH 03/14] [ACKVEC]: Use Elapsed Time separately
Message-Id: <1198074355-18842-4-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This decouples the use of Elapsed Time options from the use of Ack Vectors, so
that Elapsed Time options are no longer added automatically to each Ack Vector.

There are three reasons for this:
 1. The Elapsed Time information is nowhere used in the code.

 2. DCCP does not implement rate-based pacing of acknowledgments. The only
    recommendation for always including Elapsed Time is in section 11.3 of
    RFC 4340: "Receivers that rate-pace acknowledgements SHOULD [...]
    include Elapsed Time options". But such is not the case here.

 3. It does not really improve estimation accuracy. The Elapsed Time field only
    records the time between the arrival of the last acknowledgeable packet and
    the time the Ack Vector is sent out. Since Linux does not (yet) implement
    delayed Acks, the time difference will typically be small, since often the
    arrival of a data packet triggers sending feedback at the HC-receiver.
    If the Ack Vector has a wide coverage (up to 16192) then the Elapsed Time is
    not very meaningful for older packets.
    If indeed elapsed time is required by the endpoint or CCID, then using
    Timestamp options can provide the same information (elapsed time field
    in the Timestamp Echo option).

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ackvec.c |   11 -----------
 net/dccp/ackvec.h |    3 ---
 2 files changed, 0 insertions(+), 14 deletions(-)

--- a/net/dccp/ackvec.h
+++ b/net/dccp/ackvec.h
@@ -12,7 +12,6 @@
  */
 
 #include <linux/compiler.h>
-#include <linux/ktime.h>
 #include <linux/list.h>
 #include <linux/types.h>
 
@@ -46,7 +45,6 @@
  * @av_buf_nonce:  ECN nonce sums, each covering subsequent segments of up to
  *		   %DCCP_SINGLE_OPT_MAXLEN cells in the live portion of @av_buf
  * @av_records:	   list of %dccp_ackvec_record (Ack Vectors sent previously)
- * @av_time:	   the time in usecs
  * @av_veclen:	   length of the live portion of @av_buf
  */
 struct dccp_ackvec {
@@ -56,7 +54,6 @@ struct dccp_ackvec {
 	u64			av_buf_ackno:48;
 	bool			av_buf_nonce[DCCPAV_NUM_ACKVECS];
 	struct list_head	av_records;
-	ktime_t			av_time;
 	u16			av_vec_len;
 };
 
--- a/net/dccp/ackvec.c
+++ b/net/dccp/ackvec.c
@@ -71,18 +71,9 @@ int dccp_insert_option_ackvec(struct sock *sk, struct sk_buff *skb)
 	const u16 nr_opts = DIV_ROUND_UP(av->av_vec_len, DCCP_SINGLE_OPT_MAXLEN);
 	u16 len = av->av_vec_len + 2 * nr_opts;
 	u8 i, nonce = 0;
-	u32 elapsed_time;
 	const unsigned char *tail, *from;
 	unsigned char *to;
 	struct dccp_ackvec_record *avr;
-	suseconds_t delta;
-
-	delta = ktime_us_delta(ktime_get_real(), av->av_time);
-	elapsed_time = delta / 10;
-
-	if (elapsed_time != 0 &&
-	    dccp_insert_option_elapsed_time(sk, skb, elapsed_time))
-		return -1;
 
 	if (DCCP_SKB_CB(skb)->dccpd_opt_len + len > DCCP_MAX_OPT_LEN) {
 		/*
@@ -162,7 +153,6 @@ struct dccp_ackvec *dccp_ackvec_alloc(const gfp_t priority)
 
 	if (av != NULL) {
 		av->av_buf_head	 = DCCPAV_MAX_ACKVEC_LEN - 1;
-		av->av_time	 = ktime_set(0, 0);
 		av->av_vec_len	 = 0;
 		memset(av->av_buf_nonce, 0, sizeof(av->av_buf_nonce));
 		INIT_LIST_HEAD(&av->av_records);
@@ -321,7 +311,6 @@ int dccp_ackvec_add(struct dccp_ackvec *av, const struct sock *sk,
 	}
 
 	av->av_buf_ackno = ackno;
-	av->av_time = ktime_get_real();
 out:
 	return 0;
 
