From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Sun, 19 Aug 2007 23:53:41 +0000
Subject: [PATCH 15/15] Nuke the timeval helpers now that we fully converted
Message-Id: <20070819235341.GS24792@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Signed-off-by: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
---
 net/dccp/dccp.h |   39 ---------------------------------------
 1 files changed, 0 insertions(+), 39 deletions(-)

diff --git a/net/dccp/dccp.h b/net/dccp/dccp.h
index 6fbe293..ddacc23 100644
--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -402,45 +402,6 @@ extern int dccp_insert_option(struct sock *sk, struct sk_buff *skb,
 			       unsigned char option,
 			       const void *value, unsigned char len);
 
-static inline suseconds_t timeval_usecs(const struct timeval *tv)
-{
-	return tv->tv_sec * USEC_PER_SEC + tv->tv_usec;
-}
-
-static inline suseconds_t timeval_delta(const struct timeval *large,
-					const struct timeval *small)
-{
-	time_t	    secs  = large->tv_sec  - small->tv_sec;
-	suseconds_t usecs = large->tv_usec - small->tv_usec;
-
-	if (usecs < 0) {
-		secs--;
-		usecs += USEC_PER_SEC;
-	}
-	return secs * USEC_PER_SEC + usecs;
-}
-
-static inline void timeval_add_usecs(struct timeval *tv,
-				     const suseconds_t usecs)
-{
-	tv->tv_usec += usecs;
-	while (tv->tv_usec >= USEC_PER_SEC) {
-		tv->tv_sec++;
-		tv->tv_usec -= USEC_PER_SEC;
-	}
-}
-
-static inline void timeval_sub_usecs(struct timeval *tv,
-				     const suseconds_t usecs)
-{
-	tv->tv_usec -= usecs;
-	while (tv->tv_usec < 0) {
-		tv->tv_sec--;
-		tv->tv_usec += USEC_PER_SEC;
-	}
-	DCCP_BUG_ON(tv->tv_sec < 0);
-}
-
 #ifdef CONFIG_SYSCTL
 extern int dccp_sysctl_init(void);
 extern void dccp_sysctl_exit(void);
-- 
1.5.2.2

