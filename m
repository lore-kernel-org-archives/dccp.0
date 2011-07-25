From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 25 Jul 2011 13:36:35 +0000
Subject: [PATCH 6/7] dccp ccid-2: increment cwnd correctly
Message-Id: <1311600996-6712-7-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Samuel Jero <sj323707@ohio.edu>

This patch fixes an issue where CCID-2 will not increase the congestion
window for numerous RTTs after an idle period, application-limited period,
or a loss once the algorithm is in Congestion Avoidance.

What happens is that, when CCID-2 is in Congestion Avoidance mode, it will
increase hc->tx_packets_acked by one for every packet and will increment cwnd
every cwnd packets. However, if there is now an idle period in the connection,
cwnd will be reduced, possibly below the slow start threshold. This will
cause the connection to go into Slow Start. However, in Slow Start CCID-2
performs this test to increment cwnd every second ack:

	++hc->tx_packets_acked = 2

Unfortunately, this will be incorrect, if cwnd previous to the idle period
was larger than 2 and if tx_packets_acked was close to cwnd. For example:
	cwndP  and  tx_packets_ackedE.

In this case, the current code, will increment tx_packets_acked until it
equals two, which will only be once tx_packets_acked (an unsigned 32-bit
integer) overflows.

My fix is simply to change that test for tx_packets_acked greater than or
equal to two in slow start.

Signed-off-by: Samuel Jero <sj323707@ohio.edu>
Acked-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/ccid2.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

--- a/net/dccp/ccids/ccid2.c
+++ b/net/dccp/ccids/ccid2.c
@@ -411,7 +411,7 @@ static void ccid2_new_ack(struct sock *sk, struct ccid2_seq *seqp,
 	if (hc->tx_cwnd < dp->dccps_l_seq_win &&
 	    r_seq_used < dp->dccps_r_seq_win) {
 		if (hc->tx_cwnd < hc->tx_ssthresh) {
-			if (*maxincr > 0 && ++hc->tx_packets_acked = 2) {
+			if (*maxincr > 0 && ++hc->tx_packets_acked >= 2) {
 				hc->tx_cwnd += 1;
 				*maxincr    -= 1;
 				hc->tx_packets_acked = 0;
