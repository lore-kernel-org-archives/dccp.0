From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Sat, 04 Feb 2006 02:39:01 +0000
Subject: [PATCH 11/11][DCCP] CCID2: Initial CCID2 (TCP-Like) implementation
Message-Id: <39e6f6c70602031839t1933aedsbb005493913d911a@mail.gmail.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----=_Part_11498_10444243.1139020741156"
List-Id: <dccp.vger.kernel.org>
To: dccp@vger.kernel.org

------=_Part_11498_10444243.1139020741156
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Hi David,

    Please consider pulling from:

master.kernel.org:/pub/scm/linux/kernel/git/acme/net-2.6.17.git

Best Regards,

- Arnaldo

------=_Part_11498_10444243.1139020741156
Content-Type: text/x-patch; name=11.patch; charset=us-ascii
Content-Transfer-Encoding: 7bit
X-Attachment-Id: f_ej9bgab8
Content-Disposition: attachment; filename="11.patch"

tree e73f9cbf3042bd195be05fd1793431fcc3e8d077
parent 7546412b4ec28b4aee1e52140b60ade3671ff6bc
author Andrea Bittau <a.bittau@cs.ucl.ac.uk> 1138989401 -0200
committer Arnaldo Carvalho de Melo <acme@mandriva.com> 1138989401 -0200

[DCCP] CCID2: Initial CCID2 (TCP-Like) implementation

Original work by Andrea Bittau, Arnaldo Melo cleaned up and fixed several
issues on the merge process.

For now CCID2 was turned the default for all SOCK_DCCP connections, but this
will be remedied soon with the merge of the feature negotiation code.

Signed-off-by: Andrea Bittau <a.bittau@cs.ucl.ac.uk>
Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>

------------------------------------------------------------------------------

 include/linux/dccp.h    |    8 
 net/dccp/Kconfig        |    4 
 net/dccp/ccids/Kconfig  |   39 ++
 net/dccp/ccids/Makefile |    4 
 net/dccp/ccids/ccid2.c  |  838 ++++++++++++++++++++++++++++++++++++++++++++++++
 net/dccp/ccids/ccid2.h  |   69 +++
 net/dccp/ipv4.c         |    1 
 7 files changed, 957 insertions(+), 6 deletions(-)

------------------------------------------------------------------------------

diff --git a/include/linux/dccp.h b/include/linux/dccp.h
index 088529f..268b457 100644
--- a/include/linux/dccp.h
+++ b/include/linux/dccp.h
@@ -314,9 +314,9 @@ static inline unsigned int dccp_hdr_len(
 
 /* initial values for each feature */
 #define DCCPF_INITIAL_SEQUENCE_WINDOW		100
-/* FIXME: for now we're using CCID 3 (TFRC) */
-#define DCCPF_INITIAL_CCID			3
-#define DCCPF_INITIAL_SEND_ACK_VECTOR		0
+/* FIXME: for now we're using CCID 2 (TCP-Like) */
+#define DCCPF_INITIAL_CCID			2
+#define DCCPF_INITIAL_SEND_ACK_VECTOR		1
 /* FIXME: for now we're default to 1 but it should really be 0 */
 #define DCCPF_INITIAL_SEND_NDP_COUNT		1
 
@@ -430,6 +430,8 @@ struct dccp_sock {
 	struct timeval			dccps_timestamp_time;
 	__u32				dccps_timestamp_echo;
 	__u32				dccps_packet_size;
+	__u16				dccps_l_ack_ratio;
+	__u16				dccps_r_ack_ratio;
 	unsigned long			dccps_ndp_count;
 	__u32				dccps_mss_cache;
 	struct dccp_options		dccps_options;
diff --git a/net/dccp/Kconfig b/net/dccp/Kconfig
index 187ac18..24a6981 100644
--- a/net/dccp/Kconfig
+++ b/net/dccp/Kconfig
@@ -24,6 +24,10 @@ config INET_DCCP_DIAG
 	def_tristate y if (IP_DCCP = y && INET_DIAG = y)
 	def_tristate m
 
+config IP_DCCP_ACKVEC
+	depends on IP_DCCP
+	def_bool N
+
 source "net/dccp/ccids/Kconfig"
 
 menu "DCCP Kernel Hacking"
diff --git a/net/dccp/ccids/Kconfig b/net/dccp/ccids/Kconfig
index 7684d83..422af19 100644
--- a/net/dccp/ccids/Kconfig
+++ b/net/dccp/ccids/Kconfig
@@ -1,6 +1,34 @@
 menu "DCCP CCIDs Configuration (EXPERIMENTAL)"
 	depends on IP_DCCP && EXPERIMENTAL
 
+config IP_DCCP_CCID2
+	tristate "CCID2 (TCP) (EXPERIMENTAL)"
+	depends on IP_DCCP
+	select IP_DCCP_ACKVEC
+	---help---
+	  CCID 2, TCP-like Congestion Control, denotes Additive Increase,
+	  Multiplicative Decrease (AIMD) congestion control with behavior
+	  modelled directly on TCP, including congestion window, slow start,
+	  timeouts, and so forth [RFC 2581].  CCID 2 achieves maximum
+	  bandwidth over the long term, consistent with the use of end-to-end
+	  congestion control, but halves its congestion window in response to
+	  each congestion event.  This leads to the abrupt rate changes
+	  typical of TCP.  Applications should use CCID 2 if they prefer
+	  maximum bandwidth utilization to steadiness of rate.  This is often
+	  the case for applications that are not playing their data directly
+	  to the user.  For example, a hypothetical application that
+	  transferred files over DCCP, using application-level retransmissions
+	  for lost packets, would prefer CCID 2 to CCID 3.  On-line games may
+	  also prefer CCID 2.
+
+	  CCID 2 is further described in:
+	  http://www.icir.org/kohler/dccp/draft-ietf-dccp-ccid2-10.txt
+
+	  This text was extracted from:
+	  http://www.icir.org/kohler/dccp/draft-ietf-dccp-spec-13.txt
+
+	  If in doubt, say M.
+
 config IP_DCCP_CCID3
 	tristate "CCID3 (TFRC) (EXPERIMENTAL)"
 	depends on IP_DCCP
@@ -15,10 +43,15 @@ config IP_DCCP_CCID3
 	  suitable than CCID 2 for applications such streaming media where a
 	  relatively smooth sending rate is of importance.
 
-	  CCID 3 is further described in [CCID 3 PROFILE]. The TFRC
-	  congestion control algorithms were initially described in RFC 3448.
+	  CCID 3 is further described in:
+
+	  http://www.icir.org/kohler/dccp/draft-ietf-dccp-ccid3-11.txt.
+
+	  The TFRC congestion control algorithms were initially described in
+	  RFC 3448.
 
-	  This text was extracted from draft-ietf-dccp-spec-11.txt.
+	  This text was extracted from:
+	  http://www.icir.org/kohler/dccp/draft-ietf-dccp-spec-13.txt
 	  
 	  If in doubt, say M.
 
diff --git a/net/dccp/ccids/Makefile b/net/dccp/ccids/Makefile
index 956f79f..438f20b 100644
--- a/net/dccp/ccids/Makefile
+++ b/net/dccp/ccids/Makefile
@@ -2,4 +2,8 @@ obj-$(CONFIG_IP_DCCP_CCID3) += dccp_ccid
 
 dccp_ccid3-y := ccid3.o
 
+obj-$(CONFIG_IP_DCCP_CCID2) += dccp_ccid2.o
+
+dccp_ccid2-y := ccid2.o
+
 obj-y += lib/
diff --git a/net/dccp/ccids/ccid2.c b/net/dccp/ccids/ccid2.c
new file mode 100644
index 0000000..5495980
--- /dev/null
+++ b/net/dccp/ccids/ccid2.c
@@ -0,0 +1,838 @@
+/*
+ *  net/dccp/ccids/ccid2.c
+ *
+ *  Copyright (c) 2005, 2006 Andrea Bittau <a.bittau@cs.ucl.ac.uk>
+ *
+ *  Changes to meet Linux coding standards, and DCCP infrastructure fixes.
+ *
+ *  Copyright (c) 2006 Arnaldo Carvalho de Melo <acme@conectiva.com.br>
+ *
+ *  This program is free software; you can redistribute it and/or modify
+ *  it under the terms of the GNU General Public License as published by
+ *  the Free Software Foundation; either version 2 of the License, or
+ *  (at your option) any later version.
+ *
+ *  This program is distributed in the hope that it will be useful,
+ *  but WITHOUT ANY WARRANTY; without even the implied warranty of
+ *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ *  GNU General Public License for more details.
+ *
+ *  You should have received a copy of the GNU General Public License
+ *  along with this program; if not, write to the Free Software
+ *  Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
+ */
+
+/*
+ * This implementation should follow: draft-ietf-dccp-ccid2-10.txt
+ *
+ * BUGS:
+ * - sequence number wrapping
+ * - jiffies wrapping
+ */
+
+#include <linux/config.h>
+#include "../ccid.h"
+#include "../dccp.h"
+#include "ccid2.h"
+
+static int ccid2_debug;
+
+#if 0
+#define CCID2_DEBUG
+#endif
+
+#ifdef CCID2_DEBUG
+#define ccid2_pr_debug(format, a...) \
+        do { if (ccid2_debug) \
+                printk(KERN_DEBUG "%s: " format, __FUNCTION__, ##a); \
+        } while (0)
+#else
+#define ccid2_pr_debug(format, a...)
+#endif
+
+static const int ccid2_seq_len = 128;
+
+static inline struct ccid2_hc_tx_sock *ccid2_hc_tx_sk(const struct sock *sk)
+{
+	return dccp_sk(sk)->dccps_hc_tx_ccid_private;
+}
+
+static inline struct ccid2_hc_rx_sock *ccid2_hc_rx_sk(const struct sock *sk)
+{
+	return dccp_sk(sk)->dccps_hc_rx_ccid_private;
+}
+
+#ifdef CCID2_DEBUG
+static void ccid2_hc_tx_check_sanity(const struct ccid2_hc_tx_sock *hctx)
+{
+	int len = 0;
+	struct ccid2_seq *seqp;
+	int pipe = 0;
+
+	seqp = hctx->ccid2hctx_seqh;
+
+	/* there is data in the chain */
+	if (seqp != hctx->ccid2hctx_seqt) {
+		seqp = seqp->ccid2s_prev;
+		len++;
+		if (!seqp->ccid2s_acked)
+			pipe++;
+	
+		while (seqp != hctx->ccid2hctx_seqt) {
+			struct ccid2_seq *prev;
+
+			prev = seqp->ccid2s_prev;
+			len++;
+			if (!prev->ccid2s_acked)
+				pipe++;
+
+			/* packets are sent sequentially */
+			BUG_ON(seqp->ccid2s_seq <= prev->ccid2s_seq);
+			BUG_ON(seqp->ccid2s_sent < prev->ccid2s_sent);
+			BUG_ON(len > ccid2_seq_len);
+
+			seqp = prev;
+		}
+	}
+
+	BUG_ON(pipe != hctx->ccid2hctx_pipe);
+	ccid2_pr_debug("len of chain=%d\n", len);
+
+	do {
+		seqp = seqp->ccid2s_prev;
+		len++;
+		BUG_ON(len > ccid2_seq_len);
+	} while(seqp != hctx->ccid2hctx_seqh);
+
+	BUG_ON(len != ccid2_seq_len);
+	ccid2_pr_debug("total len=%d\n", len);
+}
+#else
+#define ccid2_hc_tx_check_sanity(hctx) do {} while (0)
+#endif
+
+static int ccid2_hc_tx_send_packet(struct sock *sk,
+				   struct sk_buff *skb, int len)
+{
+	struct ccid2_hc_tx_sock *hctx;
+	
+	switch (DCCP_SKB_CB(skb)->dccpd_type) {
+	case 0: /* XXX data packets from userland come through like this */
+	case DCCP_PKT_DATA:
+	case DCCP_PKT_DATAACK:
+		break;
+	/* No congestion control on other packets */
+	default:
+		return 0;
+	}
+
+        hctx = ccid2_hc_tx_sk(sk);
+
+	ccid2_pr_debug("pipe=%d cwnd=%d\n", hctx->ccid2hctx_pipe,
+		       hctx->ccid2hctx_cwnd);
+	
+	if (hctx->ccid2hctx_pipe < hctx->ccid2hctx_cwnd) {
+		/* OK we can send... make sure previous packet was sent off */
+		if (!hctx->ccid2hctx_sendwait) {
+			hctx->ccid2hctx_sendwait = 1;
+			return 0;
+		}
+	}
+
+	return 100; /* XXX */
+}
+
+static void ccid2_change_l_ack_ratio(struct sock *sk, int val)
+{
+	struct dccp_sock *dp = dccp_sk(sk);
+	/*
+	 * XXX I don't really agree with val != 2.  If cwnd is 1, ack ratio
+	 * should be 1... it shouldn't be allowed to become 2.
+	 * -sorbo.
+	 */
+	if (val != 2) {
+		struct ccid2_hc_tx_sock *hctx = ccid2_hc_tx_sk(sk);
+		int max = hctx->ccid2hctx_cwnd / 2;
+
+		/* round up */
+		if (hctx->ccid2hctx_cwnd & 1)
+			max++;
+
+		if (val > max)
+			val = max;
+	}
+
+	ccid2_pr_debug("changing local ack ratio to %d\n", val);
+	WARN_ON(val <= 0);
+	dp->dccps_l_ack_ratio = val;
+}
+
+static void ccid2_change_cwnd(struct sock *sk, int val)
+{
+	struct ccid2_hc_tx_sock *hctx = ccid2_hc_tx_sk(sk);
+
+	if (val == 0)
+		val = 1;
+
+	/* XXX do we need to change ack ratio? */
+	ccid2_pr_debug("change cwnd to %d\n", val);
+	
+	BUG_ON(val < 1);
+	hctx->ccid2hctx_cwnd = val;
+}
+
+static void ccid2_start_rto_timer(struct sock *sk);
+
+static void ccid2_hc_tx_rto_expire(unsigned long data)
+{
+	struct sock *sk = (struct sock *)data;
+	struct ccid2_hc_tx_sock *hctx = ccid2_hc_tx_sk(sk);
+	long s;
+
+	/* XXX I don't think i'm locking correctly
+	 * -sorbo.
+	 */
+	bh_lock_sock(sk);
+	if (sock_owned_by_user(sk)) {
+		sk_reset_timer(sk, &hctx->ccid2hctx_rtotimer,
+			       jiffies + HZ / 5);
+		goto out;
+	}
+
+	ccid2_pr_debug("RTO_EXPIRE\n");
+
+	ccid2_hc_tx_check_sanity(hctx);
+
+	/* back-off timer */
+	hctx->ccid2hctx_rto <<= 1;
+
+	s = hctx->ccid2hctx_rto / HZ;
+	if (s > 60)
+		hctx->ccid2hctx_rto = 60 * HZ;
+
+	ccid2_start_rto_timer(sk);
+
+	/* adjust pipe, cwnd etc */
+	hctx->ccid2hctx_pipe = 0;
+	hctx->ccid2hctx_ssthresh = hctx->ccid2hctx_cwnd >> 1;
+	if (hctx->ccid2hctx_ssthresh < 2)
+		hctx->ccid2hctx_ssthresh = 2;
+	ccid2_change_cwnd(sk, 1);
+
+	/* clear state about stuff we sent */
+	hctx->ccid2hctx_seqt	= hctx->ccid2hctx_seqh;
+	hctx->ccid2hctx_ssacks	= 0;
+	hctx->ccid2hctx_acks	= 0;
+	hctx->ccid2hctx_sent	= 0;
+
+	/* clear ack ratio state. */
+	hctx->ccid2hctx_arsent	 = 0;
+	hctx->ccid2hctx_ackloss  = 0;
+	hctx->ccid2hctx_rpseq	 = 0;
+	hctx->ccid2hctx_rpdupack = -1;
+	ccid2_change_l_ack_ratio(sk, 1);
+	ccid2_hc_tx_check_sanity(hctx);
+out:
+	bh_unlock_sock(sk);
+/*	sock_put(sk); */
+}
+
+static void ccid2_start_rto_timer(struct sock *sk)
+{
+	struct ccid2_hc_tx_sock *hctx = ccid2_hc_tx_sk(sk);
+
+	ccid2_pr_debug("setting RTO timeout=%ld\n", hctx->ccid2hctx_rto);
+
+	BUG_ON(timer_pending(&hctx->ccid2hctx_rtotimer));
+	sk_reset_timer(sk, &hctx->ccid2hctx_rtotimer,
+		       jiffies + hctx->ccid2hctx_rto);
+}
+
+static void ccid2_hc_tx_packet_sent(struct sock *sk, int more, int len)
+{
+	struct dccp_sock *dp = dccp_sk(sk);
+	struct ccid2_hc_tx_sock *hctx = ccid2_hc_tx_sk(sk);
+	u64 seq;
+
+	ccid2_hc_tx_check_sanity(hctx);
+
+	BUG_ON(!hctx->ccid2hctx_sendwait);
+	hctx->ccid2hctx_sendwait = 0;
+	hctx->ccid2hctx_pipe++;
+	BUG_ON(hctx->ccid2hctx_pipe < 0);
+
+	/* There is an issue.  What if another packet is sent between
+	 * packet_send() and packet_sent().  Then the sequence number would be
+	 * wrong.
+	 * -sorbo.
+	 */
+	seq = dp->dccps_gss;
+
+	hctx->ccid2hctx_seqh->ccid2s_seq   = seq;
+	hctx->ccid2hctx_seqh->ccid2s_acked = 0;
+	hctx->ccid2hctx_seqh->ccid2s_sent  = jiffies;
+	hctx->ccid2hctx_seqh = hctx->ccid2hctx_seqh->ccid2s_next;
+
+	ccid2_pr_debug("cwnd=%d pipe=%d\n", hctx->ccid2hctx_cwnd, 
+		       hctx->ccid2hctx_pipe);
+	
+	if (hctx->ccid2hctx_seqh == hctx->ccid2hctx_seqt) {
+		/* XXX allocate more space */
+		WARN_ON(1);
+	}
+
+	hctx->ccid2hctx_sent++;
+
+	/* Ack Ratio.  Need to maintain a concept of how many windows we sent */
+	hctx->ccid2hctx_arsent++;
+	/* We had an ack loss in this window... */
+	if (hctx->ccid2hctx_ackloss) {
+		if (hctx->ccid2hctx_arsent >= hctx->ccid2hctx_cwnd) {
+			hctx->ccid2hctx_arsent = 0;
+			hctx->ccid2hctx_ackloss = 0;
+		}
+	}
+	/* No acks lost up to now... */
+	else {
+		/* decrease ack ratio if enough packets were sent */
+		if (dp->dccps_l_ack_ratio > 1) {
+			/* XXX don't calculate denominator each time */
+			int denom;
+
+			denom = dp->dccps_l_ack_ratio * dp->dccps_l_ack_ratio - 
+				dp->dccps_l_ack_ratio;
+			denom = hctx->ccid2hctx_cwnd * hctx->ccid2hctx_cwnd / denom;
+
+			if (hctx->ccid2hctx_arsent >= denom) {
+				ccid2_change_l_ack_ratio(sk, dp->dccps_l_ack_ratio - 1);
+				hctx->ccid2hctx_arsent = 0;
+			}
+		}
+		/* we can't increase ack ratio further [1] */
+		else {
+			hctx->ccid2hctx_arsent = 0; /* or maybe set it to cwnd*/
+		}
+	}
+
+	/* setup RTO timer */
+	if (!timer_pending(&hctx->ccid2hctx_rtotimer)) {
+		ccid2_start_rto_timer(sk);
+	}
+#ifdef CCID2_DEBUG
+	ccid2_pr_debug("pipe=%d\n", hctx->ccid2hctx_pipe);
+	ccid2_pr_debug("Sent: seq=%llu\n", seq);
+	do {
+		struct ccid2_seq *seqp = hctx->ccid2hctx_seqt;
+
+		while (seqp != hctx->ccid2hctx_seqh) {
+			ccid2_pr_debug("out seq=%llu acked=%d time=%lu\n",
+			       	       seqp->ccid2s_seq, seqp->ccid2s_acked, 
+				       seqp->ccid2s_sent);
+			seqp = seqp->ccid2s_next;
+		}
+	} while(0);
+	ccid2_pr_debug("=========\n");
+	ccid2_hc_tx_check_sanity(hctx);
+#endif
+}
+
+/* XXX Lame code duplication!
+ * returns -1 if none was found.
+ * else returns the next offset to use in the function call.
+ */
+static int ccid2_ackvector(struct sock *sk, struct sk_buff *skb, int offset,
+			   unsigned char **vec, unsigned char *veclen)
+{
+        const struct dccp_hdr *dh = dccp_hdr(skb);
+        unsigned char *options = (unsigned char *)dh + dccp_hdr_len(skb);
+        unsigned char *opt_ptr;
+        const unsigned char *opt_end = (unsigned char *)dh +
+                                        (dh->dccph_doff * 4);
+        unsigned char opt, len;
+        unsigned char *value;
+
+	BUG_ON(offset < 0);
+	options += offset;
+	opt_ptr = options;
+	if (opt_ptr >= opt_end)
+		return -1;
+
+	while (opt_ptr != opt_end) {
+                opt   = *opt_ptr++;
+                len   = 0;
+                value = NULL;
+
+                /* Check if this isn't a single byte option */
+                if (opt > DCCPO_MAX_RESERVED) {
+                        if (opt_ptr == opt_end)
+                                goto out_invalid_option;
+
+                        len = *opt_ptr++;
+                        if (len < 3)
+                                goto out_invalid_option;
+                        /*
+                         * Remove the type and len fields, leaving
+                         * just the value size
+                         */
+                        len     -= 2;
+                        value   = opt_ptr;
+                        opt_ptr += len;
+
+                        if (opt_ptr > opt_end)
+                                goto out_invalid_option;
+                }
+
+		switch (opt) {
+		case DCCPO_ACK_VECTOR_0:
+		case DCCPO_ACK_VECTOR_1:
+			*vec	= value;
+			*veclen = len;
+			return offset + (opt_ptr - options);
+			break;
+		}
+	}
+
+	return -1;
+	
+out_invalid_option:
+	BUG_ON(1); /* should never happen... options were previously parsed ! */
+	return -1;
+}
+
+static void ccid2_hc_tx_kill_rto_timer(struct ccid2_hc_tx_sock *hctx)
+{
+	if (del_timer(&hctx->ccid2hctx_rtotimer))
+		ccid2_pr_debug("deleted RTO timer\n");
+}
+
+static inline void ccid2_new_ack(struct sock *sk, 
+			         struct ccid2_seq *seqp,
+				 unsigned int *maxincr)
+{
+	struct ccid2_hc_tx_sock *hctx = ccid2_hc_tx_sk(sk);
+
+	/* slow start */
+	if (hctx->ccid2hctx_cwnd < hctx->ccid2hctx_ssthresh) {
+		hctx->ccid2hctx_acks = 0;
+
+		/* We can increase cwnd at most maxincr [ack_ratio/2] */
+		if (*maxincr) {
+			/* increase every 2 acks */
+			hctx->ccid2hctx_ssacks++;
+			if (hctx->ccid2hctx_ssacks == 2) {
+				ccid2_change_cwnd(sk, hctx->ccid2hctx_cwnd + 1);
+				hctx->ccid2hctx_ssacks = 0;
+				*maxincr = *maxincr - 1;
+			}
+		}
+		/* increased cwnd enough for this single ack */
+		else {
+			hctx->ccid2hctx_ssacks = 0;
+		}
+	}
+	else {
+		hctx->ccid2hctx_ssacks = 0;
+		hctx->ccid2hctx_acks++;
+
+		if (hctx->ccid2hctx_acks >= hctx->ccid2hctx_cwnd) {
+			ccid2_change_cwnd(sk, hctx->ccid2hctx_cwnd + 1);
+			hctx->ccid2hctx_acks = 0;
+		}
+	}
+
+	/* update RTO */
+	if (hctx->ccid2hctx_srtt == -1 ||
+	    (jiffies - hctx->ccid2hctx_lastrtt) >= hctx->ccid2hctx_srtt) {
+		unsigned long r = jiffies - seqp->ccid2s_sent;
+		int s;
+
+		/* first measurement */
+		if (hctx->ccid2hctx_srtt == -1) {
+			ccid2_pr_debug("R: %lu Time=%lu seq=%llu\n", 
+			       	       r, jiffies, seqp->ccid2s_seq);
+			hctx->ccid2hctx_srtt = r;
+			hctx->ccid2hctx_rttvar = r >> 1;
+		}
+		else {
+			/* RTTVAR */
+			long tmp = hctx->ccid2hctx_srtt - r;
+			if (tmp < 0)
+				tmp *= -1;
+			
+			tmp >>= 2;
+			hctx->ccid2hctx_rttvar *= 3;
+			hctx->ccid2hctx_rttvar >>= 2;
+			hctx->ccid2hctx_rttvar += tmp;
+
+			/* SRTT */
+			hctx->ccid2hctx_srtt *= 7;
+			hctx->ccid2hctx_srtt >>= 3;
+			tmp = r >> 3;
+			hctx->ccid2hctx_srtt += tmp;
+		}
+		s = hctx->ccid2hctx_rttvar << 2;
+		/* clock granularity is 1 when based on jiffies */
+		if (!s)
+			s = 1;
+		hctx->ccid2hctx_rto = hctx->ccid2hctx_srtt + s;
+
+		/* must be at least a second */
+		s = hctx->ccid2hctx_rto / HZ;
+		/* DCCP doesn't require this [but I like it cuz my code sux] */
+#if 1
+		if (s < 1)
+			hctx->ccid2hctx_rto = HZ;
+#endif			
+		/* max 60 seconds */	
+		if (s > 60)
+			hctx->ccid2hctx_rto = HZ * 60;
+
+		hctx->ccid2hctx_lastrtt = jiffies;
+
+		ccid2_pr_debug("srtt: %ld rttvar: %ld rto: %ld (HZ=%d) R=%lu\n",
+		       	       hctx->ccid2hctx_srtt, hctx->ccid2hctx_rttvar,
+		       	       hctx->ccid2hctx_rto, HZ, r);
+		hctx->ccid2hctx_sent = 0;
+	}
+
+	/* we got a new ack, so re-start RTO timer */
+	ccid2_hc_tx_kill_rto_timer(hctx);
+	ccid2_start_rto_timer(sk);
+}
+
+static void ccid2_hc_tx_dec_pipe(struct ccid2_hc_tx_sock *hctx)
+{
+	hctx->ccid2hctx_pipe--;
+	BUG_ON(hctx->ccid2hctx_pipe < 0);
+
+	if (hctx->ccid2hctx_pipe == 0)
+		ccid2_hc_tx_kill_rto_timer(hctx);
+}
+
+static void ccid2_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
+{
+	struct dccp_sock *dp = dccp_sk(sk);
+	struct ccid2_hc_tx_sock *hctx = ccid2_hc_tx_sk(sk);
+	u64 ackno, seqno;
+	struct ccid2_seq *seqp;
+	unsigned char *vector;
+	unsigned char veclen;
+	int offset = 0;
+	int done = 0;
+	int loss = 0;
+	unsigned int maxincr = 0;
+
+	ccid2_hc_tx_check_sanity(hctx);
+	/* check reverse path congestion */
+	seqno = DCCP_SKB_CB(skb)->dccpd_seq;
+
+	/* XXX this whole "algorithm" is broken.  Need to fix it to keep track
+	 * of the seqnos of the dupacks so that rpseq and rpdupack are correct
+	 * -sorbo.
+	 */
+	/* need to bootstrap */
+	if (hctx->ccid2hctx_rpdupack == -1) {
+		hctx->ccid2hctx_rpdupack = 0;
+		hctx->ccid2hctx_rpseq = seqno;
+	}
+	else {
+		/* check if packet is consecutive */
+		if ((hctx->ccid2hctx_rpseq + 1) == seqno) {
+			hctx->ccid2hctx_rpseq++;
+		}
+		/* it's a later packet */
+		else if (after48(seqno, hctx->ccid2hctx_rpseq)) {
+			hctx->ccid2hctx_rpdupack++;
+			
+			/* check if we got enough dupacks */
+			if (hctx->ccid2hctx_rpdupack >=
+			    hctx->ccid2hctx_numdupack) {
+
+				hctx->ccid2hctx_rpdupack = -1; /* XXX lame */
+				hctx->ccid2hctx_rpseq = 0;
+
+				ccid2_change_l_ack_ratio(sk, dp->dccps_l_ack_ratio << 1);
+			}
+		}
+	}
+
+	/* check forward path congestion */
+	/* still didn't send out new data packets */
+	if (hctx->ccid2hctx_seqh == hctx->ccid2hctx_seqt)
+		return;
+
+	switch (DCCP_SKB_CB(skb)->dccpd_type) {
+	case DCCP_PKT_ACK:
+	case DCCP_PKT_DATAACK:
+		break;
+	
+	default:
+		return;
+	}
+
+	ackno = DCCP_SKB_CB(skb)->dccpd_ack_seq;
+	seqp = hctx->ccid2hctx_seqh->ccid2s_prev;
+
+	/* If in slow-start, cwnd can increase at most Ack Ratio / 2 packets for
+	 * this single ack.  I round up.
+	 * -sorbo.
+	 */
+	maxincr = dp->dccps_l_ack_ratio >> 1;
+	maxincr++;
+
+	/* go through all ack vectors */
+	while ((offset = ccid2_ackvector(sk, skb, offset, 
+					 &vector, &veclen)) != -1) {
+		/* go through this ack vector */
+		while (veclen--) {
+			const u8 rl = *vector & DCCP_ACKVEC_LEN_MASK;
+			u64 ackno_end_rl;
+
+			dccp_set_seqno(&ackno_end_rl, ackno - rl);
+			ccid2_pr_debug("ackvec start:%llu end:%llu\n", ackno, 
+				       ackno_end_rl);
+			/* if the seqno we are analyzing is larger than the
+			 * current ackno, then move towards the tail of our
+			 * seqnos.
+			 */
+			while (after48(seqp->ccid2s_seq, ackno)) {
+				if (seqp == hctx->ccid2hctx_seqt) {
+					done = 1;
+					break;
+				}
+				seqp = seqp->ccid2s_prev;
+			}
+			if (done)
+				break;
+
+			/* check all seqnos in the range of the vector
+			 * run length 
+			 */
+			while (between48(seqp->ccid2s_seq,ackno_end_rl,ackno)) {
+				const u8 state = (*vector & 
+						  DCCP_ACKVEC_STATE_MASK) >> 6;
+			
+				/* new packet received or marked */
+				if (state != DCCP_ACKVEC_STATE_NOT_RECEIVED &&
+				    !seqp->ccid2s_acked) {
+				    	if (state == 
+					    DCCP_ACKVEC_STATE_ECN_MARKED) {
+						loss = 1;
+					}
+					else {
+						ccid2_new_ack(sk, seqp,
+							      &maxincr);
+					}
+
+					seqp->ccid2s_acked = 1;
+					ccid2_pr_debug("Got ack for %llu\n",
+					       	       seqp->ccid2s_seq);
+					ccid2_hc_tx_dec_pipe(hctx);
+				}
+				if (seqp == hctx->ccid2hctx_seqt) {
+					done = 1;
+					break;
+				}
+				seqp = seqp->ccid2s_next;
+			}
+			if (done)
+				break;
+			       
+
+			dccp_set_seqno(&ackno, ackno_end_rl - 1);
+			vector++;
+		}
+		if (done)
+			break;
+	}
+
+	/* The state about what is acked should be correct now
+	 * Check for NUMDUPACK
+	 */
+	seqp = hctx->ccid2hctx_seqh->ccid2s_prev;
+	done = 0;
+	while (1) {
+		if (seqp->ccid2s_acked) {
+			done++;
+			if (done == hctx->ccid2hctx_numdupack) {
+				break;
+			}	
+		}
+		if (seqp == hctx->ccid2hctx_seqt) {
+			break;
+		}
+		seqp = seqp->ccid2s_prev;
+	}
+
+	/* If there are at least 3 acknowledgements, anything unacknowledged
+	 * below the last sequence number is considered lost
+	 */
+	if (done == hctx->ccid2hctx_numdupack) {
+		struct ccid2_seq *last_acked = seqp;
+
+		/* check for lost packets */
+		while (1) {
+			if (!seqp->ccid2s_acked) {
+				loss = 1;
+				ccid2_hc_tx_dec_pipe(hctx);
+			}
+			if (seqp == hctx->ccid2hctx_seqt)
+				break;
+			seqp = seqp->ccid2s_prev;
+		}
+
+		hctx->ccid2hctx_seqt = last_acked;
+	}
+
+	/* trim acked packets in tail */
+	while (hctx->ccid2hctx_seqt != hctx->ccid2hctx_seqh) {
+		if (!hctx->ccid2hctx_seqt->ccid2s_acked)
+			break;
+		
+		hctx->ccid2hctx_seqt = hctx->ccid2hctx_seqt->ccid2s_next;
+	}
+
+	if (loss) {
+		/* XXX do bit shifts guarantee a 0 as the new bit? */
+		ccid2_change_cwnd(sk, hctx->ccid2hctx_cwnd >> 1);
+		hctx->ccid2hctx_ssthresh = hctx->ccid2hctx_cwnd;
+		if (hctx->ccid2hctx_ssthresh < 2)
+			hctx->ccid2hctx_ssthresh = 2;
+	}
+
+	ccid2_hc_tx_check_sanity(hctx);
+}
+
+static int ccid2_hc_tx_init(struct sock *sk)
+{
+	struct dccp_sock *dp = dccp_sk(sk);
+        struct ccid2_hc_tx_sock *hctx;
+	int seqcount = ccid2_seq_len;
+	int i;
+
+        dp->dccps_hc_tx_ccid_private = kzalloc(sizeof(*hctx), gfp_any());
+        if (dp->dccps_hc_tx_ccid_private == NULL)
+                return -ENOMEM;
+
+        hctx = ccid2_hc_tx_sk(sk);
+
+	/* XXX init variables with proper values */
+	hctx->ccid2hctx_cwnd	  = 1;
+	hctx->ccid2hctx_ssthresh  = 10;
+	hctx->ccid2hctx_numdupack = 3;
+
+	/* XXX init ~ to window size... */
+	hctx->ccid2hctx_seqbuf = kmalloc(sizeof(*hctx->ccid2hctx_seqbuf) *
+					 seqcount, gfp_any());
+	if (hctx->ccid2hctx_seqbuf == NULL) {
+		kfree(dp->dccps_hc_tx_ccid_private);
+		dp->dccps_hc_tx_ccid_private = NULL;
+		return -ENOMEM;
+	}
+	for (i = 0; i < (seqcount - 1); i++) {
+		hctx->ccid2hctx_seqbuf[i].ccid2s_next = 
+					&hctx->ccid2hctx_seqbuf[i + 1];
+		hctx->ccid2hctx_seqbuf[i + 1].ccid2s_prev = 
+					&hctx->ccid2hctx_seqbuf[i];
+	}
+	hctx->ccid2hctx_seqbuf[seqcount - 1].ccid2s_next =
+					hctx->ccid2hctx_seqbuf;
+	hctx->ccid2hctx_seqbuf->ccid2s_prev =
+					&hctx->ccid2hctx_seqbuf[seqcount - 1];
+
+	hctx->ccid2hctx_seqh	 = hctx->ccid2hctx_seqbuf;
+	hctx->ccid2hctx_seqt	 = hctx->ccid2hctx_seqh;
+	hctx->ccid2hctx_sent	 = 0;
+	hctx->ccid2hctx_rto	 = 3 * HZ;
+	hctx->ccid2hctx_srtt	 = -1;
+	hctx->ccid2hctx_rttvar	 = -1;
+	hctx->ccid2hctx_lastrtt  = 0;
+	hctx->ccid2hctx_rpdupack = -1;
+
+	hctx->ccid2hctx_rtotimer.function = &ccid2_hc_tx_rto_expire;
+	hctx->ccid2hctx_rtotimer.data	  = (unsigned long)sk;
+	init_timer(&hctx->ccid2hctx_rtotimer);
+
+	ccid2_hc_tx_check_sanity(hctx);
+	return 0;
+}
+
+static void ccid2_hc_tx_exit(struct sock *sk)
+{
+	struct dccp_sock *dp = dccp_sk(sk);
+        struct ccid2_hc_tx_sock *hctx = dp->dccps_hc_tx_ccid_private;
+
+	ccid2_hc_tx_kill_rto_timer(hctx);
+
+	kfree(hctx->ccid2hctx_seqbuf);
+
+	kfree(dp->dccps_hc_tx_ccid_private);
+	dp->dccps_hc_tx_ccid_private = NULL;
+}
+
+static void ccid2_hc_rx_packet_recv(struct sock *sk, struct sk_buff *skb)
+{
+	const struct dccp_sock *dp = dccp_sk(sk);
+	struct ccid2_hc_rx_sock *hcrx = ccid2_hc_rx_sk(sk);
+
+	switch (DCCP_SKB_CB(skb)->dccpd_type) {
+	case DCCP_PKT_DATA:
+	case DCCP_PKT_DATAACK:
+		hcrx->ccid2hcrx_data++;
+		if (hcrx->ccid2hcrx_data >= dp->dccps_r_ack_ratio) {
+			dccp_send_ack(sk);
+			hcrx->ccid2hcrx_data = 0;
+		}
+		break;
+	}
+}
+
+static int ccid2_hc_rx_init(struct sock *sk)
+{
+	struct dccp_sock *dp = dccp_sk(sk);
+        dp->dccps_hc_rx_ccid_private = kzalloc(sizeof(struct ccid2_hc_rx_sock),
+					       gfp_any());
+        return dp->dccps_hc_rx_ccid_private == NULL ? -ENOMEM : 0;
+}
+
+static void ccid2_hc_rx_exit(struct sock *sk)
+{
+	struct dccp_sock *dp = dccp_sk(sk);
+
+	kfree(dp->dccps_hc_rx_ccid_private);
+	dp->dccps_hc_rx_ccid_private = NULL;
+}
+
+static struct ccid ccid2 = {
+	.ccid_id		= 2,
+	.ccid_name		= "ccid2",
+	.ccid_owner		= THIS_MODULE,
+	.ccid_hc_tx_init	= ccid2_hc_tx_init,
+	.ccid_hc_tx_exit	= ccid2_hc_tx_exit,
+	.ccid_hc_tx_send_packet	= ccid2_hc_tx_send_packet,
+	.ccid_hc_tx_packet_sent	= ccid2_hc_tx_packet_sent,
+	.ccid_hc_tx_packet_recv	= ccid2_hc_tx_packet_recv,
+	.ccid_hc_rx_init	= ccid2_hc_rx_init,
+	.ccid_hc_rx_exit	= ccid2_hc_rx_exit,
+	.ccid_hc_rx_packet_recv	= ccid2_hc_rx_packet_recv,
+};
+
+module_param(ccid2_debug, int, 0444);
+MODULE_PARM_DESC(ccid2_debug, "Enable debug messages");
+ 
+static __init int ccid2_module_init(void)
+{
+	return ccid_register(&ccid2);
+}
+module_init(ccid2_module_init);
+
+static __exit void ccid2_module_exit(void)
+{
+	ccid_unregister(&ccid2);
+}
+module_exit(ccid2_module_exit);
+
+MODULE_AUTHOR("Andrea Bittau <a.bittau@cs.ucl.ac.uk>");
+MODULE_DESCRIPTION("DCCP TCP CCID2 CCID");
+MODULE_LICENSE("GPL");
+MODULE_ALIAS("net-dccp-ccid-2");
diff --git a/net/dccp/ccids/ccid2.h b/net/dccp/ccids/ccid2.h
new file mode 100644
index 0000000..0b08c90
--- /dev/null
+++ b/net/dccp/ccids/ccid2.h
@@ -0,0 +1,69 @@
+/*
+ *  net/dccp/ccids/ccid2.h
+ *
+ *  Copyright (c) 2005 Andrea Bittau <a.bittau@cs.ucl.ac.uk>
+ *
+ *  This program is free software; you can redistribute it and/or modify
+ *  it under the terms of the GNU General Public License as published by
+ *  the Free Software Foundation; either version 2 of the License, or
+ *  (at your option) any later version.
+ *
+ *  This program is distributed in the hope that it will be useful,
+ *  but WITHOUT ANY WARRANTY; without even the implied warranty of
+ *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ *  GNU General Public License for more details.
+ *
+ *  You should have received a copy of the GNU General Public License
+ *  along with this program; if not, write to the Free Software
+ *  Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
+ */
+#ifndef _DCCP_CCID2_H_
+#define _DCCP_CCID2_H_
+
+struct ccid2_seq {
+	u64			ccid2s_seq;
+	unsigned long		ccid2s_sent;
+	int			ccid2s_acked;
+	struct ccid2_seq	*ccid2s_prev;
+	struct ccid2_seq	*ccid2s_next;
+};
+
+/** struct ccid2_hc_tx_sock - CCID2 TX half connection
+ *
+ * @ccid2hctx_ssacks - ACKs recv in slow start
+ * @ccid2hctx_acks - ACKS recv in AI phase
+ * @ccid2hctx_sent - packets sent in this window
+ * @ccid2hctx_lastrtt -time RTT was last measured
+ * @ccid2hctx_arsent - packets sent [ack ratio]
+ * @ccid2hctx_ackloss - ack was lost in this win
+ * @ccid2hctx_rpseq - last consecutive seqno
+ * @ccid2hctx_rpdupack - dupacks since rpseq
+*/
+struct ccid2_hc_tx_sock {
+	int			ccid2hctx_cwnd;
+	int			ccid2hctx_ssacks;
+	int			ccid2hctx_acks;
+	int			ccid2hctx_ssthresh;
+	int			ccid2hctx_pipe;
+	int			ccid2hctx_numdupack;
+	struct ccid2_seq	*ccid2hctx_seqbuf;
+	struct ccid2_seq	*ccid2hctx_seqh;
+	struct ccid2_seq	*ccid2hctx_seqt;
+	long			ccid2hctx_rto;
+	long			ccid2hctx_srtt;
+	long			ccid2hctx_rttvar;
+	int			ccid2hctx_sent;
+	unsigned long		ccid2hctx_lastrtt;
+	struct timer_list	ccid2hctx_rtotimer;
+	unsigned long		ccid2hctx_arsent;
+	int			ccid2hctx_ackloss;
+	u64			ccid2hctx_rpseq;
+	int			ccid2hctx_rpdupack;
+	int			ccid2hctx_sendwait;
+};
+
+struct ccid2_hc_rx_sock {
+	int	ccid2hcrx_data;
+};
+
+#endif /* _DCCP_CCID2_H_ */
diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index fd5a615..605e9d5 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -1080,6 +1080,7 @@ int dccp_v4_init_sock(struct sock *sk)
 	dp->dccps_mss_cache = 536;
 	dp->dccps_role = DCCP_ROLE_UNDEFINED;
 	dp->dccps_service = DCCP_SERVICE_INVALID_VALUE;
+	dp->dccps_l_ack_ratio = dp->dccps_r_ack_ratio = 1;
 
 	return 0;
 }


------=_Part_11498_10444243.1139020741156--
