From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 13 Aug 2010 05:21:39 +0000
Subject: [PATCH 1/3] dccp ccid-2: Share TCP's minimum RTO code
Message-Id: <1281676901-7018-2-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Over the same link, DCCP and TCP face similar problems; and DCCP's
CCID-2 is in fact a restricted form of TCP.

Using the same RTO_MIN of 0.2 seconds was found to cause problems for CCID-2
over 802.11g: at least once per session there is a spurious timeout. It helped
to then increase the the value of RTO_MIN over this link.

Since the problem is the same as in TCP, this patch makes the solution from
commit "05bb1fad1cde025a864a90cfeb98dcbefe78a44a"
       "[TCP]: Allow minimum RTO to be configurable via routing metrics."
available to DCCP.

This avoids reinventing the wheel, so that e.g. the following works in the
expected way now also for DCCP:

> ip route change 10.0.0.2 rto_min 800 dev ath0

Luckily this useful rto_min function was recently moved to net/tcp.h,
which simplifies sharing code originating from TCP.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/ccid2.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

--- a/net/dccp/ccids/ccid2.c
+++ b/net/dccp/ccids/ccid2.c
@@ -267,8 +267,9 @@ static void ccid2_rtt_estimator(struct sock *sk, const long mrtt)
 		hc->tx_srtt = m << 3;
 		hc->tx_mdev = m << 1;
 
-		hc->tx_mdev_max = max(TCP_RTO_MIN, hc->tx_mdev);
+		hc->tx_mdev_max = max(hc->tx_mdev, tcp_rto_min(sk));
 		hc->tx_rttvar   = hc->tx_mdev_max;
+
 		hc->tx_rtt_seq  = dccp_sk(sk)->dccps_gss;
 	} else {
 		/* Update scaled SRTT as SRTT += 1/8 * (m - SRTT) */
@@ -309,7 +310,7 @@ static void ccid2_rtt_estimator(struct sock *sk, const long mrtt)
 				hc->tx_rttvar -= (hc->tx_rttvar -
 						  hc->tx_mdev_max) >> 2;
 			hc->tx_rtt_seq  = dccp_sk(sk)->dccps_gss;
-			hc->tx_mdev_max = TCP_RTO_MIN;
+			hc->tx_mdev_max = tcp_rto_min(sk);
 		}
 	}
 
