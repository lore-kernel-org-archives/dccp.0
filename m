From: Arnaldo Carvalho de Melo <acme@mandriva.com>
Date: Sun, 03 Dec 2006 22:07:29 +0000
Subject: [PATCH 2/10] [DCCP]: Fix BUG in retransmission delay calculation
Message-Id: <20061203220729.GH17803@mandriva.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This bug resulted in ccid3_hc_tx_send_packet returning negative
delay values, which in turn triggered silently dequeueing packets in
dccp_write_xmit. As a result, only a few out of the submitted packets made
it at all onto the network.  Occasionally, when dccp_wait_for_ccid was
involved, this also triggered a bug warning since ccid3_hc_tx_send_packet
returned a negative value (which in reality was a negative delay value).

The cause for this bug lies in the comparison

 if (delay >= hctx->ccid3hctx_delta)
	return delay / 1000L;

The type of `delay' is `long', that of ccid3hctx_delta is `u32'. When comparing
negative long values against u32 values, the test returned `true' whenever delay
was smaller than 0 (meaning the packet was overdue to send).

The fix is by casting, subtracting, and then testing the difference with
regard to 0.

This has been tested and shown to work.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>
---
 net/dccp/ccids/ccid3.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/dccp/ccids/ccid3.c b/net/dccp/ccids/ccid3.c
index 9980778..22a0724 100644
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -339,7 +339,7 @@ static int ccid3_hc_tx_send_packet(struc
 		 * else
 		 *       // send the packet in (t_nom - t_now) milliseconds.
 		 */
-		if (delay >= hctx->ccid3hctx_delta)
+		if (delay - (long)hctx->ccid3hctx_delta >= 0)
 			return delay / 1000L;
 		break;
 	case TFRC_SSTATE_TERM:
-- 
1.4.2.1.g3d5c

