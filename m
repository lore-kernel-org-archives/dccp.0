From: Eric Dumazet <edumazet@google.com>
Date: Fri, 22 Jun 2018 13:44:15 +0000
Subject: [PATCH net 2/2] net: dccp: switch rx_tstamp_last_feedback to monotonic clock
Message-Id: <20180622134415.104266-3-edumazet@google.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

To compute delays, better not use time of the day which can
be changed by admins or malicious programs.

Also change ccid3_first_li() to use s64 type for delta variable
to avoid potential overflows.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Cc: dccp@vger.kernel.org
---
 net/dccp/ccids/ccid3.c | 11 +++++++----
 1 file changed, 7 insertions(+), 4 deletions(-)

diff --git a/net/dccp/ccids/ccid3.c b/net/dccp/ccids/ccid3.c
index d57a2be1e2e09aee89347e286aca538303b7dee1..12877a1514e7b8e873cd26529e58f7ebaae99c1a 100644
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -600,7 +600,7 @@ static void ccid3_hc_rx_send_feedback(struct sock *sk,
 {
 	struct ccid3_hc_rx_sock *hc = ccid3_hc_rx_sk(sk);
 	struct dccp_sock *dp = dccp_sk(sk);
-	ktime_t now = ktime_get_real();
+	ktime_t now = ktime_get();
 	s64 delta = 0;
 
 	switch (fbtype) {
@@ -632,7 +632,7 @@ static void ccid3_hc_rx_send_feedback(struct sock *sk,
 		return;
 	}
 
-	ccid3_pr_debug("Interval %ldusec, X_recv=%u, 1/p=%u\n", (long)delta,
+	ccid3_pr_debug("Interval %lldusec, X_recv=%u, 1/p=%u\n", delta,
 		       hc->rx_x_recv, hc->rx_pinv);
 
 	hc->rx_tstamp_last_feedback = now;
@@ -679,7 +679,8 @@ static int ccid3_hc_rx_insert_options(struct sock *sk, struct sk_buff *skb)
 static u32 ccid3_first_li(struct sock *sk)
 {
 	struct ccid3_hc_rx_sock *hc = ccid3_hc_rx_sk(sk);
-	u32 x_recv, p, delta;
+	u32 x_recv, p;
+	s64 delta;
 	u64 fval;
 
 	if (hc->rx_rtt = 0) {
@@ -687,7 +688,9 @@ static u32 ccid3_first_li(struct sock *sk)
 		hc->rx_rtt = DCCP_FALLBACK_RTT;
 	}
 
-	delta  = ktime_to_us(net_timedelta(hc->rx_tstamp_last_feedback));
+	delta = ktime_us_delta(ktime_get(), hc->rx_tstamp_last_feedback);
+	if (delta <= 0)
+		delta = 1;
 	x_recv = scaled_div32(hc->rx_bytes_recv, delta);
 	if (x_recv = 0) {		/* would also trigger divide-by-zero */
 		DCCP_WARN("X_recv=0\n");
-- 
2.18.0.rc2.346.g013aa6912e-goog

