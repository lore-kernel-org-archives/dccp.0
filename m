From: Arnaldo Carvalho de Melo <acme@mandriva.com>
Date: Sun, 10 Dec 2006 03:00:38 +0000
Subject: [PATCH 5/22] [DCCP] ccid3: Fix two bugs in sending rate computation
Message-Id: <20061210030038.GG17909@mandriva.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This fixes
 1) a bug in the recomputation of the sending rate by the nofeedback
    timer when no feedback at all has so far been sent by the receiver:
    min_t was used instead of max_t, which is wrong (cf. RFC 3448, p. 10);

 2) an error in the computation of larger initial windows: instead of
    min(... max()) (cf. RFC 4342, 5.), the code had used max(... max()).

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>
---
 net/dccp/ccids/ccid3.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/dccp/ccids/ccid3.c b/net/dccp/ccids/ccid3.c
index 92e893e..c54663f 100644
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -193,7 +193,7 @@ static void ccid3_hc_tx_no_feedback_time
 	switch (hctx->ccid3hctx_state) {
 	case TFRC_SSTATE_NO_FBACK:
 		/* RFC 3448, 4.4: Halve send rate directly */
-		hctx->ccid3hctx_x = min_t(u32, hctx->ccid3hctx_x / 2,
+		hctx->ccid3hctx_x = max_t(u32, hctx->ccid3hctx_x / 2,
 					       hctx->ccid3hctx_s / TFRC_T_MBI);
 
 		ccid3_pr_debug("%s, sk=%p, state=%s, updated tx rate to %d "
@@ -477,7 +477,7 @@ static void ccid3_hc_tx_packet_recv(stru
 		if (hctx->ccid3hctx_state = TFRC_SSTATE_NO_FBACK) {
 			/* Use Larger Initial Windows [RFC 4342, sec. 5]
 			 * We deviate in that we use `s' instead of `MSS'. */
-			u16 w_init = max(    4 * hctx->ccid3hctx_s,
+			u16 w_init = min(    4 * hctx->ccid3hctx_s,
 					 max(2 * hctx->ccid3hctx_s, 4380));
 			hctx->ccid3hctx_rtt  = r_sample;
 			hctx->ccid3hctx_x    = usecs_div(w_init, r_sample);
-- 
1.4.2.1.g3d5c

