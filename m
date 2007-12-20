From: Leandro <leandroal@gmail.com>
Date: Thu, 20 Dec 2007 16:59:21 +0000
Subject: [PATCH 8/8] Remove inline modifier from tfrc_ccids.c functions
Message-Id: <200712201359.22024.leandroal@gmail.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[TFRC_CCIDS] Remove inline modifier from tfrc_ccids.c functions and let the compile decide it, as commented by Gerrit in the mailing list.

Signed-off-by: Leandro Melo de Sales <leandro@embedded.ufcg.edu.br>

Index: ccid4.latest/net/dccp/ccids/lib/tfrc_ccids.c
=================================--- ccid4.latest.orig/net/dccp/ccids/lib/tfrc_ccids.c
+++ ccid4.latest/net/dccp/ccids/lib/tfrc_ccids.c
@@ -20,7 +20,7 @@
  * (rev-02) clarifies the use of RFC 3390 with regard to the above formula.
  * For consistency with other parts of the code, X_init is scaled by 2^6.
  */
-inline u64 rfc3390_initial_rate(struct sock *sk)
+u64 rfc3390_initial_rate(struct sock *sk)
 {
 	const struct tfrc_hc_tx_sock *hctx = tfrc_hc_tx_sk(sk);
 	const __u32 w_init = min_t(__u32, 4 * hctx->ttx_s,
@@ -44,7 +44,7 @@ EXPORT_SYMBOL_GPL(tfrc_hc_tx_idle_rtt);
  *	Update Window Counter using the algorithm from [RFC 4342, 8.1].
  *	The algorithm is not applicable if RTT < 4 microseconds.
  */
-inline void tfrc_hc_tx_update_win_count(struct tfrc_hc_tx_sock *hctx,
+void tfrc_hc_tx_update_win_count(struct tfrc_hc_tx_sock *hctx,
 				          ktime_t now)
 {
 	u32 quarter_rtts;
