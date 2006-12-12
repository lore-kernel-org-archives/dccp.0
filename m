From: Arnaldo Carvalho de Melo <acme@mandriva.com>
Date: Tue, 12 Dec 2006 22:47:56 +0000
Subject: [PATCH 1/1][DCCP] ccid3: return value in ccid3_hc_rx_calc_first_li
Message-Id: <20061212224756.GA6888@mandriva.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

David,

	Please consider pulling from:

master.kernel.org:/pub/scm/linux/kernel/git/acme/net-2.6.git

Thanks a lot,

- Arnaldo

-------------------------------- 8< -------------------------------

In a recent patch we introduced invalid return codes which will result in the
opposite of what is intended (i.e. send more packets in face of peculiar
network conditions).

This fixes it by returning ~0 which means not calculated as per
dccp_li_hist_calc_i_mean.

Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>
---
 net/dccp/ccids/ccid3.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/dccp/ccids/ccid3.c b/net/dccp/ccids/ccid3.c
index fa6b753..40402c5 100644
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -845,8 +845,8 @@ found:
 	 * Find some p such that f(p) = fval; return 1/p [RFC 3448, 6.3.1].
 	 */
 	if (rtt = 0) {			/* would result in divide-by-zero */
-		DCCP_WARN("RTT=0, returning 1/p = 1\n");
-		return 1000000;
+		DCCP_WARN("RTT=0\n");
+		return ~0;
 	}
 
 	dccp_timestamp(sk, &tstamp);
@@ -858,7 +858,7 @@ found:
 		DCCP_WARN("X_recv=0\n");
 		if ((x_recv = hcrx->ccid3hcrx_x_recv) = 0) {
 			DCCP_BUG("stored value of X_recv is zero");
-			return 1000000;
+			return ~0;
 		}
 	}
 
-- 
1.4.2.1.g3d5c


