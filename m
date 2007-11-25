From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Sun, 25 Nov 2007 00:21:31 +0000
Subject: [PATCH 06/18] [DCCP]: Initialize dccp_sock before calling the ccid constructors
Message-Id: <1195950103-18102-7-git-send-email-acme@redhat.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This is because in the next patch CCID2 will assume that dccps_mss_cache is
non-zero.

Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 net/dccp/proto.c |   25 +++++++++++++------------
 1 files changed, 13 insertions(+), 12 deletions(-)

diff --git a/net/dccp/proto.c b/net/dccp/proto.c
index 0aec735..d48005f 100644
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -174,6 +174,19 @@ int dccp_init_sock(struct sock *sk, const __u8 ctl_sock_initialized)
 
 	dccp_minisock_init(&dp->dccps_minisock);
 
+	icsk->icsk_rto		= DCCP_TIMEOUT_INIT;
+	icsk->icsk_syn_retries	= sysctl_dccp_request_retries;
+	sk->sk_state		= DCCP_CLOSED;
+	sk->sk_write_space	= dccp_write_space;
+	icsk->icsk_sync_mss	= dccp_sync_mss;
+	dp->dccps_mss_cache	= 536;
+	dp->dccps_rate_last	= jiffies;
+	dp->dccps_role		= DCCP_ROLE_UNDEFINED;
+	dp->dccps_service	= DCCP_SERVICE_CODE_IS_ABSENT;
+	dp->dccps_l_ack_ratio	= dp->dccps_r_ack_ratio = 1;
+
+	dccp_init_xmit_timers(sk);
+
 	/*
 	 * FIXME: We're hardcoding the CCID, and doing this at this point makes
 	 * the listening (master) sock get CCID control blocks, which is not
@@ -213,18 +226,6 @@ int dccp_init_sock(struct sock *sk, const __u8 ctl_sock_initialized)
 		INIT_LIST_HEAD(&dmsk->dccpms_conf);
 	}
 
-	dccp_init_xmit_timers(sk);
-	icsk->icsk_rto		= DCCP_TIMEOUT_INIT;
-	icsk->icsk_syn_retries	= sysctl_dccp_request_retries;
-	sk->sk_state		= DCCP_CLOSED;
-	sk->sk_write_space	= dccp_write_space;
-	icsk->icsk_sync_mss	= dccp_sync_mss;
-	dp->dccps_mss_cache	= 536;
-	dp->dccps_rate_last	= jiffies;
-	dp->dccps_role		= DCCP_ROLE_UNDEFINED;
-	dp->dccps_service	= DCCP_SERVICE_CODE_IS_ABSENT;
-	dp->dccps_l_ack_ratio	= dp->dccps_r_ack_ratio = 1;
-
 	return 0;
 }
 
-- 
1.5.3.4

