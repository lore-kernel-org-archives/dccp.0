From: Leandro <leandroal@gmail.com>
Date: Fri, 21 Dec 2007 04:34:36 +0000
Subject: [PATCHv2 8/8] Remove inline modifier from tfrc_ccids.c functions
Message-Id: <200712210134.36159.leandroal@gmail.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[TFRC_CCIDS] Remove inline modifier from tfrc_ccids.c functions and let the compile decide it, as commented by Gerrit in the mailing list.

Signed-off-by: Leandro Melo de Sales <leandro@embedded.ufcg.edu.br>

-------------------> Patch v2 <------------------------

Index: ccid4.latest/net/dccp/ccids/lib/tfrc_ccids.c
=================================--- ccid4.latest.orig/net/dccp/ccids/lib/tfrc_ccids.c
+++ ccid4.latest/net/dccp/ccids/lib/tfrc_ccids.c
@@ -27,7 +27,7 @@ extern int tfrc_debug;
  * (rev-02) clarifies the use of RFC 3390 with regard to the above formula.
  * For consistency with other parts of the code, X_init is scaled by 2^6.
  */
-inline u64 rfc3390_initial_rate(struct sock *sk)
+u64 rfc3390_initial_rate(struct sock *sk)
 {
 	const struct tfrc_hc_tx_sock *hctx = tfrc_hc_tx_sk(sk);
 	const __u32 w_init = min_t(__u32, 4 * hctx->ttx_s,
@@ -51,7 +51,7 @@ EXPORT_SYMBOL_GPL(tfrc_hc_tx_idle_rtt);
  *	Update Window Counter using the algorithm from [RFC 4342, 8.1].
  *	The algorithm is not applicable if RTT < 4 microseconds.
  */
-inline void tfrc_hc_tx_update_win_count(struct tfrc_hc_tx_sock *hctx,
+void tfrc_hc_tx_update_win_count(struct tfrc_hc_tx_sock *hctx,
 				          ktime_t now)
 {
 	u32 quarter_rtts;
