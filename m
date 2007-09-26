From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Wed, 26 Sep 2007 23:08:03 +0000
Subject: [PATCH 2/2] [CCID3]: Remove ifdef surrounding BUG_ON
Message-Id: <20070926230803.GQ10932@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

As suggested by DaveM.

Signed-off-by: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
---
 net/dccp/ccids/ccid3.h |    4 ----
 1 files changed, 0 insertions(+), 4 deletions(-)

diff --git a/net/dccp/ccids/ccid3.h b/net/dccp/ccids/ccid3.h
index ae99ec4..0cdc982 100644
--- a/net/dccp/ccids/ccid3.h
+++ b/net/dccp/ccids/ccid3.h
@@ -120,9 +120,7 @@ struct ccid3_hc_tx_sock {
 static inline struct ccid3_hc_tx_sock *ccid3_hc_tx_sk(const struct sock *sk)
 {
     struct ccid3_hc_tx_sock *hctx = ccid_priv(dccp_sk(sk)->dccps_hc_tx_ccid);
-#ifdef CONFIG_IP_DCCP_CCID3_DEBUG
     BUG_ON(hctx = NULL);
-#endif
     return hctx;
 }
 
@@ -173,9 +171,7 @@ struct ccid3_hc_rx_sock {
 static inline struct ccid3_hc_rx_sock *ccid3_hc_rx_sk(const struct sock *sk)
 {
     struct ccid3_hc_rx_sock *hcrx = ccid_priv(dccp_sk(sk)->dccps_hc_rx_ccid);
-#ifdef CONFIG_IP_DCCP_CCID3_DEBUG
     BUG_ON(hcrx = NULL);
-#endif
     return hcrx;
 }
 
-- 
1.5.2.2

