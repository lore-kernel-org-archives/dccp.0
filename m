From: Kees Cook <keescook@chromium.org>
Date: Wed, 18 Aug 2021 06:05:12 +0000
Subject: [PATCH v2 42/63] net: dccp: Use memset_startat() for TP zeroing
Message-Id: <20210818060533.3569517-43-keescook@chromium.org>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

In preparation for FORTIFY_SOURCE performing compile-time and run-time
field bounds checking for memset(), avoid intentionally writing across
neighboring fields.

Use memset_startat() so memset() doesn't get confused about writing
beyond the destination member that is intended to be the starting point
of zeroing through the end of the struct.

Cc: "David S. Miller" <davem@davemloft.net>
Cc: Jakub Kicinski <kuba@kernel.org>
Cc: dccp@vger.kernel.org
Cc: netdev@vger.kernel.org
Signed-off-by: Kees Cook <keescook@chromium.org>
---
 net/dccp/trace.h | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/net/dccp/trace.h b/net/dccp/trace.h
index 5062421beee9..5a43b3508c7f 100644
--- a/net/dccp/trace.h
+++ b/net/dccp/trace.h
@@ -60,9 +60,7 @@ TRACE_EVENT(dccp_probe,
 			__entry->tx_t_ipi = hc->tx_t_ipi;
 		} else {
 			__entry->tx_s = 0;
-			memset(&__entry->tx_rtt, 0, (void *)&__entry->tx_t_ipi -
-			       (void *)&__entry->tx_rtt +
-			       sizeof(__entry->tx_t_ipi));
+			memset_startat(__entry, 0, tx_rtt);
 		}
 	),
 
-- 
2.30.2
