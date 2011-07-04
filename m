From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 04 Jul 2011 19:01:17 +0000
Subject: [PATCH 4/6] dccp ccid-2: move rfc 3390 function into header file
Message-Id: <1309806079-21604-5-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This moves CCID-2's initial window function into the header file, since several
parts throughout the CCID-2 code need to call it (CCID-2 still uses RFC 3390).

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Acked-by: Leandro Melo de Sales <leandro@ic.ufal.br>
---
 net/dccp/ccids/ccid2.c |    9 ---------
 net/dccp/ccids/ccid2.h |    9 +++++++++
 2 files changed, 9 insertions(+), 9 deletions(-)

--- a/net/dccp/ccids/ccid2.c
+++ b/net/dccp/ccids/ccid2.c
@@ -583,15 +583,6 @@ done:
 	dccp_ackvec_parsed_cleanup(&hc->tx_av_chunks);
 }
 
-/*
- * Convert RFC 3390 larger initial window into an equivalent number of packets.
- * This is based on the numbers specified in RFC 5681, 3.1.
- */
-static inline u32 rfc3390_bytes_to_packets(const u32 smss)
-{
-	return smss <= 1095 ? 4 : (smss > 2190 ? 2 : 3);
-}
-
 static int ccid2_hc_tx_init(struct ccid *ccid, struct sock *sk)
 {
 	struct ccid2_hc_tx_sock *hc = ccid_priv(ccid);
--- a/net/dccp/ccids/ccid2.h
+++ b/net/dccp/ccids/ccid2.h
@@ -88,6 +88,15 @@ static inline bool ccid2_cwnd_network_limited(struct ccid2_hc_tx_sock *hc)
 	return hc->tx_pipe >= hc->tx_cwnd;
 }
 
+/*
+ * Convert RFC 3390 larger initial window into an equivalent number of packets.
+ * This is based on the numbers specified in RFC 5681, 3.1.
+ */
+static inline u32 rfc3390_bytes_to_packets(const u32 smss)
+{
+	return smss <= 1095 ? 4 : (smss > 2190 ? 2 : 3);
+}
+
 struct ccid2_hc_rx_sock {
 	int	rx_data;
 };
