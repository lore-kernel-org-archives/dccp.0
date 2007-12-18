From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 18 Dec 2007 12:41:08 +0000
Subject: [DCCP] [PATCH 1/1]: Whitespace / outdated documentation
Message-Id: <20071218124108.GA5968@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[CCID3]: Whitespace cleanups and outdated documentation

This removes outdated documentation which had been forgotten to be
removed (x_recv, rtt now appear twice, p was removed from rx_sock);
and removes new whitespace.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/ccid3.c |    6 +++---
 net/dccp/ccids/ccid3.h |    3 ---
 2 files changed, 3 insertions(+), 6 deletions(-)

--- a/net/dccp/ccids/ccid3.h
+++ b/net/dccp/ccids/ccid3.h
@@ -133,9 +133,6 @@ enum ccid3_hc_rx_states {
 
 /** struct ccid3_hc_rx_sock - CCID3 receiver half-connection socket
  *
- *  @ccid3hcrx_x_recv  -  Receiver estimate of send rate (RFC 3448 4.3)
- *  @ccid3hcrx_rtt  -  Receiver estimate of rtt (non-standard)
- *  @ccid3hcrx_p  -  Current loss event rate (RFC 3448 5.4)
  *  @ccid3hcrx_last_counter  -  Tracks window counter (RFC 4342, 8.1)
  *  @ccid3hcrx_state  -  Receiver state, one of %ccid3_hc_rx_states
  *  @ccid3hcrx_bytes_recv  -  Total sum of DCCP payload bytes
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -437,9 +437,9 @@ static void ccid3_hc_tx_packet_recv(stru
 		ccid3_hc_tx_set_state(sk, TFRC_SSTATE_FBACK);
 
 		if (hctx->ccid3hctx_t_rto = 0) {
- 			/*
+			/*
 			 * Initial feedback packet: Larger Initial Windows (4.2)
- 			 */
+			 */
 			hctx->ccid3hctx_x    = rfc3390_initial_rate(sk);
 			hctx->ccid3hctx_t_ld = now;
 
@@ -451,7 +451,7 @@ static void ccid3_hc_tx_packet_recv(stru
 			 * First feedback after nofeedback timer expiry (4.3)
 			 */
 			goto done_computing_x;
- 		}
+		}
 	}
 
 	/* Update sending rate (step 4 of [RFC 3448, 4.3]) */
-- 
