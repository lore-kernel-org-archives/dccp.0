From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Thu, 12 Apr 2007 21:14:10 +0000
Subject: [PATCH 02/29] Avoid accumulation of large send credit
Message-Id: <20070412211409.GC21292@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Problem:
 Large backlogs of packets will accumulate in the CCID3 TX module when
  (i)   the application idles and/or
  (ii)  the application emits at a rate slower than the allowed rate X/s and/or
  (iii) due to scheduling inaccuracy (resolution only up to HZ).

 The consequence is that a huge burst of packets can be sent immediately, which
 violates the allowed sending rate and can (worst case) choke the network.
 Furthermore (iii) is especially likely when using high-speed (Gbit) links.

Fix:
 Avoid any backlog of sending time which is greater than one whole t_ipi. This
 is a conservative tight bound which will ensure safe operation with regard to
 the allowed fair-share rate in a wide range of possible hardware configurations.
 The value is derived below with a simple model, showing that this choice is safe
 from an operational point of view.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Signed-off-by: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
---
 net/dccp/ccids/ccid3.c |   12 ++++++++++--
 1 files changed, 10 insertions(+), 2 deletions(-)

diff --git a/net/dccp/ccids/ccid3.c b/net/dccp/ccids/ccid3.c
index d7d9ce7..c623761 100644
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -362,7 +362,15 @@ static int ccid3_hc_tx_send_packet(struct sock *sk, struct sk_buff *skb)
 	case TFRC_SSTATE_NO_FBACK:
 	case TFRC_SSTATE_FBACK:
 		delay = timeval_delta(&hctx->ccid3hctx_t_nom, &now);
-		ccid3_pr_debug("delay=%ld\n", (long)delay);
+		/*
+		 * Lagging behind for more than a full t_ipi: when this occurs,
+		 * a send credit accrues which causes packet storms, violating
+		 * even the average allowed sending rate. This case happens if
+		 * the application idles for some time, or if it emits packets
+		 * at a rate smaller than X/s. Avoid such accumulation.
+		 */
+		if (delay + (suseconds_t)hctx->ccid3hctx_t_ipi < 0)
+			hctx->ccid3hctx_t_nom = now;
 		/*
 		 *	Scheduling of packet transmissions [RFC 3448, 4.6]
 		 *
@@ -371,7 +379,7 @@ static int ccid3_hc_tx_send_packet(struct sock *sk, struct sk_buff *skb)
 		 * else
 		 *       // send the packet in (t_nom - t_now) milliseconds.
 		 */
-		if (delay - (suseconds_t)hctx->ccid3hctx_delta >= 0)
+		else if (delay - (suseconds_t)hctx->ccid3hctx_delta >= 0)
 			return delay / 1000L;
 
 		ccid3_hc_tx_update_win_count(hctx, &now);
-- 
1.5.0.6

