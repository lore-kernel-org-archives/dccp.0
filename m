From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Fri, 14 Dec 2007 01:42:02 +0000
Subject: [PATCH 3/3] [DCCP]: Introducing CCMPS
Message-Id: <1197596522-14600-4-git-send-email-acme@redhat.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>

This introduces a CCMPS field for setting a CCID-specific upper bound on the application payload
size, as is defined in RFC 4340, section 14.

Only the TX CCID is considered in setting this limit, since the RX CCID generates comparatively
small (DCCP-Ack) feedback packets. The CCMPS field includes network and transport layer header
lengths. The only current CCMPS customer is CCID4 (via RFC 4828).

A wrapper is used to allow querying the CCMPS even at times where the CCID modules may not have
been fully negotiated yet.

In dccp_sync_mss() the variable `mss_now' has been renamed into `cur_mps', to reflect that we are
dealing with an MPS, but not an MSS.
Since the DCCP code closely follows the TCP code, the identifiers `dccp_sync_mss' and
`dccps_mss_cache' have been kept, as they have direct TCP counterparts.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 net/dccp/ccid.h   |    2 ++
 net/dccp/output.c |   30 +++++++++++++++++++++++-------
 2 files changed, 25 insertions(+), 7 deletions(-)

diff --git a/net/dccp/ccid.h b/net/dccp/ccid.h
index e3cdd8a..fdeae7b 100644
--- a/net/dccp/ccid.h
+++ b/net/dccp/ccid.h
@@ -27,6 +27,7 @@ struct tcp_info;
  *  struct ccid_operations  -  Interface to Congestion-Control Infrastructure
  *
  *  @ccid_id: numerical CCID ID (up to %CCID_MAX, cf. table 5 in RFC 4340, 10.)
+ *  @ccid_ccmps: the CCMPS including network/transport headers (0 when disabled)
  *  @ccid_name: alphabetical identifier string for @ccid_id
  *  @ccid_owner: module which implements/owns this CCID
  *  @ccid_hc_{r,t}x_slab: memory pool for the receiver/sender half-connection
@@ -45,6 +46,7 @@ struct tcp_info;
  */
 struct ccid_operations {
 	unsigned char		ccid_id;
+	__u32			ccid_ccmps;
 	const char		*ccid_name;
 	struct module		*ccid_owner;
 	struct kmem_cache	*ccid_hc_rx_slab,
diff --git a/net/dccp/output.c b/net/dccp/output.c
index 5589a5e..3b763db 100644
--- a/net/dccp/output.c
+++ b/net/dccp/output.c
@@ -133,15 +133,31 @@ static int dccp_transmit_skb(struct sock *sk, struct sk_buff *skb)
 	return -ENOBUFS;
 }
 
+/**
+ * dccp_determine_ccmps  -  Find out about CCID-specfic packet-size limits
+ * We only consider the HC-sender CCID for setting the CCMPS (RFC 4340, 14.),
+ * since the RX CCID is restricted to feedback packets (Acks), which are small
+ * in comparison with the data traffic. A value of 0 means "no current CCMPS".
+ */
+static u32 dccp_determine_ccmps(const struct dccp_sock *dp)
+{
+	const struct ccid *tx_ccid = dp->dccps_hc_tx_ccid;
+
+	if (tx_ccid = NULL || tx_ccid->ccid_ops = NULL)
+		return 0;
+	return tx_ccid->ccid_ops->ccid_ccmps;
+}
+
 unsigned int dccp_sync_mss(struct sock *sk, u32 pmtu)
 {
 	struct inet_connection_sock *icsk = inet_csk(sk);
 	struct dccp_sock *dp = dccp_sk(sk);
-	int mss_now = (pmtu - icsk->icsk_af_ops->net_header_len -
-		       sizeof(struct dccp_hdr) - sizeof(struct dccp_hdr_ext));
+	u32 ccmps = dccp_determine_ccmps(dp);
+	int cur_mps = ccmps ? min(pmtu, ccmps) : pmtu;
 
-	/* Now subtract optional transport overhead */
-	mss_now -= icsk->icsk_ext_hdr_len;
+	/* Account for header lengths and IPv4/v6 option overhead */
+	cur_mps -= (icsk->icsk_af_ops->net_header_len + icsk->icsk_ext_hdr_len +
+		    sizeof(struct dccp_hdr) + sizeof(struct dccp_hdr_ext));
 
 	/*
 	 * FIXME: this should come from the CCID infrastructure, where, say,
@@ -151,13 +167,13 @@ unsigned int dccp_sync_mss(struct sock *sk, u32 pmtu)
 	 * make it a multiple of 4
 	 */
 
-	mss_now -= ((5 + 6 + 10 + 6 + 6 + 6 + 3) / 4) * 4;
+	cur_mps -= ((5 + 6 + 10 + 6 + 6 + 6 + 3) / 4) * 4;
 
 	/* And store cached results */
 	icsk->icsk_pmtu_cookie = pmtu;
-	dp->dccps_mss_cache = mss_now;
+	dp->dccps_mss_cache = cur_mps;
 
-	return mss_now;
+	return cur_mps;
 }
 
 EXPORT_SYMBOL_GPL(dccp_sync_mss);
-- 
1.5.3.4

