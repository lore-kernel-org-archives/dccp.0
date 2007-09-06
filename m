From: Ian McDonald <ian.mcdonald@jandi.co.nz>
Date: Thu, 06 Sep 2007 03:07:06 +0000
Subject: [PATCH 5/6] DCCP: Check if faster restart is on
Message-Id: <200709061507.07014.ian.mcdonald@jandi.co.nz>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This adds new helper functions to check if faster restart is turned on.

Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
---
diff --git a/net/dccp/ccids/ccid3.h b/net/dccp/ccids/ccid3.h
index c77c8fb..7edbf70 100644
--- a/net/dccp/ccids/ccid3.h
+++ b/net/dccp/ccids/ccid3.h
@@ -182,4 +182,11 @@ static inline struct ccid3_hc_rx_sock *ccid3_hc_rx_sk(const struct sock *sk)
 	return ccid3_rx_priv;
 }
 
+static inline bool ccid3_hc_tx_faster_restart_on(
+	const struct ccid3_hc_tx_sock *hctx)
+{
+	return ((hctx->ccid3hctx_extensions & TFRC_EXT_FASTER_RESTART)
+		= TFRC_EXT_FASTER_RESTART);
+}
+
 #endif /* _DCCP_CCID3_H_ */
