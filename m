From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 18 Mar 2011 21:06:50 +0000
Subject: dccp test-tree [PATCH 1/1] ccid-2: still stuck with RFC 3390
Message-Id: <20110318210650.GA1248@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

There was a discussion earlier with Leandro to keep the current status of
using RFC 3390 initial window settings, so I am updating accordingly.

Ultimately it would be great to consider larger initial windows also for
CCID-2, perhaps as a configurable compilation option. With 1GB/10GB ethernet,
this would make a conceivable difference.

>>>>>>>>>>>>>>>>>>>>>>>>>>>> Patch <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
dccp ccid-2: move rfc 3390 function into header file

This moves the initial-window function, which came back when TCP's window
was increased, into the header file. Several patches in the test tree 
rely on this function. Until there is agreement to put larger windows 
also into CCID-2, the function needs to be available in a top-level place.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
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
@@ -88,6 +88,15 @@ static inline bool ccid2_cwnd_network_li
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

-- 
