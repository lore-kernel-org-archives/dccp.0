From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 28 Nov 2006 14:34:31 +0000
Subject: [RFC] [PATCH 1/2]: Remove small typo
Message-Id: <200611281434.31175@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[CCID 3]: Remove small typo

This removes a small typo introduced by an earlier patch.

===> It is sent as RFC since it would be a much better idea to
       revise this so that the nofeedback timer expires after 
             max(4*R, 2 * s/X) 
       instead of after 
        max(t_rto, 2 * s/X)  =  max(max(4*R, 1 second), 2 *s/X)
       as is currently the case.

===> Advantage:
           * the current solution is non-standard
           * simulation experience suggest that  max(4*R, 2 * s/X)
             is better, especially if R is small

===>  OK with this suggestion?


Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/ccid3.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -246,7 +246,7 @@ static void ccid3_hc_tx_no_feedback_time
 		}
 		/*
 		 * Schedule no feedback timer to expire in
-		 * max(4 * t_RTO, 2 * s/X)  =  max(4 * t_RTO, 2 * t_ipi)
+		 * max(t_RTO, 2 * s/X)  =  max(t_RTO, 2 * t_ipi)
 		 * XXX This is non-standard, RFC 3448, 4.3 uses 4 * R
 		 */
 		next_tmout = max(hctx->ccid3hctx_t_rto, 2*hctx->ccid3hctx_t_ipi);
@@ -523,7 +523,7 @@ static void ccid3_hc_tx_packet_recv(stru
 					      	   USEC_PER_SEC            );
 		/*
 		 * Schedule no feedback timer to expire in
-		 * max(4 * t_RTO, 2 * s/X)  =  max(4 * t_RTO, 2 * t_ipi)
+		 * max(t_RTO, 2 * s/X)  =  max(t_RTO, 2 * t_ipi)
 		 * XXX This is non-standard, RFC 3448, 4.3 uses 4 * R
 		 */
 		next_tmout = max(hctx->ccid3hctx_t_rto, 2*hctx->ccid3hctx_t_ipi);
