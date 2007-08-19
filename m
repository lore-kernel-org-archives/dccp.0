From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Sun, 19 Aug 2007 23:53:00 +0000
Subject: [PATCH 14/15] [DCCP]: Nuke dccp_timestamp and dccps_epoch, not
Message-Id: <20070819235300.GR24792@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Signed-off-by: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
---
 include/linux/dccp.h |    1 -
 net/dccp/dccp.h      |    2 --
 net/dccp/minisocks.c |    1 -
 net/dccp/options.c   |   16 ----------------
 net/dccp/proto.c     |    1 -
 5 files changed, 0 insertions(+), 21 deletions(-)

diff --git a/include/linux/dccp.h b/include/linux/dccp.h
index 3a4b96b..a044119 100644
--- a/include/linux/dccp.h
+++ b/include/linux/dccp.h
@@ -512,7 +512,6 @@ struct dccp_sock {
 	struct ccid			*dccps_hc_rx_ccid;
 	struct ccid			*dccps_hc_tx_ccid;
 	struct dccp_options_received	dccps_options_received;
-	struct timeval			dccps_epoch;
 	enum dccp_role			dccps_role:2;
 	__u8				dccps_hc_rx_insert_options:1;
 	__u8				dccps_hc_tx_insert_options:1;
diff --git a/net/dccp/dccp.h b/net/dccp/dccp.h
index 20a7bed..6fbe293 100644
--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -402,8 +402,6 @@ extern int dccp_insert_option(struct sock *sk, struct sk_buff *skb,
 			       unsigned char option,
 			       const void *value, unsigned char len);
 
-extern void dccp_timestamp(const struct sock *sk, struct timeval *tv);
-
 static inline suseconds_t timeval_usecs(const struct timeval *tv)
 {
 	return tv->tv_sec * USEC_PER_SEC + tv->tv_usec;
diff --git a/net/dccp/minisocks.c b/net/dccp/minisocks.c
index e18e249..9168599 100644
--- a/net/dccp/minisocks.c
+++ b/net/dccp/minisocks.c
@@ -112,7 +112,6 @@ struct sock *dccp_create_openreq_child(struct sock *sk,
 		newdp->dccps_service_list  = NULL;
 		newdp->dccps_service	   = dreq->dreq_service;
 		newicsk->icsk_rto	   = DCCP_TIMEOUT_INIT;
-		do_gettimeofday(&newdp->dccps_epoch);
 
 		if (dccp_feat_clone(sk, newsk))
 			goto out_free;
diff --git a/net/dccp/options.c b/net/dccp/options.c
index 439e25d..1674156 100644
--- a/net/dccp/options.c
+++ b/net/dccp/options.c
@@ -370,22 +370,6 @@ int dccp_insert_option_elapsed_time(struct sock *sk, struct sk_buff *skb,
 
 EXPORT_SYMBOL_GPL(dccp_insert_option_elapsed_time);
 
-void dccp_timestamp(const struct sock *sk, struct timeval *tv)
-{
-	const struct dccp_sock *dp = dccp_sk(sk);
-
-	do_gettimeofday(tv);
-	tv->tv_sec  -= dp->dccps_epoch.tv_sec;
-	tv->tv_usec -= dp->dccps_epoch.tv_usec;
-
-	while (tv->tv_usec < 0) {
-		tv->tv_sec--;
-		tv->tv_usec += USEC_PER_SEC;
-	}
-}
-
-EXPORT_SYMBOL_GPL(dccp_timestamp);
-
 int dccp_insert_option_timestamp(struct sock *sk, struct sk_buff *skb)
 {
 	__be32 now = htonl(((suseconds_t)ktime_to_us(ktime_get_real())) / 10);
diff --git a/net/dccp/proto.c b/net/dccp/proto.c
index 04b59ec..8d545da 100644
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -172,7 +172,6 @@ int dccp_init_sock(struct sock *sk, const __u8 ctl_sock_initialized)
 	struct inet_connection_sock *icsk = inet_csk(sk);
 
 	dccp_minisock_init(&dp->dccps_minisock);
-	do_gettimeofday(&dp->dccps_epoch);
 
 	/*
 	 * FIXME: We're hardcoding the CCID, and doing this at this point makes
-- 
1.5.2.2

