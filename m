From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Mon, 18 Jun 2007 02:07:33 +0000
Subject: [PATCH 4/4] [CCID3]: Fix a bug in the send time processing
Message-Id: <20070618020733.GE4226@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

ccid3_hc_tx_send_packet currently returns 0 when the time difference between
current time and t_nom is less than 1000 microseconds.

In this case the packet is sent immediately; but, unlike other packets that can
be emitted on first attempt, it will not have its window counter updated and
its options set as required. This is a bug.

Fix: Require the time difference to be at least 1000 microseconds. The
algorithm then converges: time differences > 1000 microseconds trigger the
timer in dccp_write_xmit; after timer expiry this function is tried again; when
the time difference is less than 1000, the packet will have its options added
and window counter updated as required.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Signed-off-by: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
---
 net/dccp/ccids/ccid3.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/dccp/ccids/ccid3.c b/net/dccp/ccids/ccid3.c
index 94b3a1a..e91c2b9 100644
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -363,7 +363,7 @@ static int ccid3_hc_tx_send_packet(struct sock *sk, struct sk_buff *skb)
 		 * else
 		 *       // send the packet in (t_nom - t_now) milliseconds.
 		 */
-		if (delay - (s64)hctx->ccid3hctx_delta >= 0)
+		if (delay - (s64)hctx->ccid3hctx_delta >= 1000)
 			return (u32)delay / 1000L;
 
 		ccid3_hc_tx_update_win_count(hctx, now);
-- 
1.5.0.6

