From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 03 Oct 2007 14:02:45 +0000
Subject: [PATCH 8/14]: Remove manual influence on NDP Count feature
Message-Id: <200710031502.45403@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[DCCP]: Remove manual influence on NDP Count feature

The NDP count feature is handled automatically now by the feature negotiation code:
 * for CCID2 it is disabled, since the code does not use or even refer to NDP counts;
 * for CCID3 it is enabled, since NDP counts are used to determine loss lengths (RFC 4342, 6.1).

Allowing the user to change these values leads to unpredictable and failing behaviour, since it 
is then possible to disable NDP counts even when they are needed (e.g. in CCID3). This means that
only those user settings are sensible that agree with the values for Send NDP Count implied by the
choice of CCID. But those settings are already activated by the feature negotiation (CCID dependency
tracking), which means that the user settings are redundant. 

I thus think that it is the best choice to remove this sysctl. Leaving it in brings no
advantages, but opens a door to creating non-operable conditions.

At startup the initialisation of the NDP count feature is with the default value of 0, which is
done implicitly by the zeroing-out of the socket when it is allocated. If the choice of CCID or
feature negotiation enables NDP count, this will then be updated via the NDP activation handler.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 Documentation/networking/dccp.txt |    3 ---
 net/dccp/dccp.h                   |    1 -
 net/dccp/minisocks.c              |    1 -
 net/dccp/sysctl.c                 |    8 --------
 4 files changed, 13 deletions(-)

--- a/net/dccp/sysctl.c
+++ b/net/dccp/sysctl.c
@@ -20,7 +20,6 @@ int sysctl_dccp_feat_rx_ccid	     = DCCP
 int sysctl_dccp_feat_tx_ccid	     = DCCPF_INITIAL_CCID;
 int sysctl_dccp_feat_ack_ratio	     = DCCPF_INITIAL_ACK_RATIO;
 int sysctl_dccp_feat_send_ack_vector = DCCPF_INITIAL_SEND_ACK_VECTOR;
-int sysctl_dccp_feat_send_ndp_count  = DCCPF_INITIAL_SEND_NDP_COUNT;
 
 /* the maximum queue length for tx in packets. 0 is no limit */
 int sysctl_dccp_tx_qlen		__read_mostly = 5;
@@ -72,13 +71,6 @@ static struct ctl_table dccp_default_tab
 		.proc_handler	= proc_dointvec,
 	},
 	{
-		.procname	= "send_ndp",
-		.data		= &sysctl_dccp_feat_send_ndp_count,
-		.maxlen		= sizeof(sysctl_dccp_feat_send_ndp_count),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec,
-	},
-	{
 		.procname	= "request_retries",
 		.data		= &sysctl_dccp_request_retries,
 		.maxlen		= sizeof(sysctl_dccp_request_retries),
--- a/Documentation/networking/dccp.txt
+++ b/Documentation/networking/dccp.txt
@@ -133,9 +133,6 @@ retries2
 	importance for retransmitted acknowledgments and feature negotiation,
 	data packets are never retransmitted. Analogue of tcp_retries2.
 
-send_ndp = 1
-	Whether or not to send NDP count options (sec. 7.7.2).
-
 tx_ccid = 2
 	Default CCID for the sender-receiver half-connection. Depending on the
 	choice of CCID, the Send Ack Vector feature is enabled automatically.
--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -100,7 +100,6 @@ extern int  sysctl_dccp_feat_rx_ccid;
 extern int  sysctl_dccp_feat_tx_ccid;
 extern int  sysctl_dccp_feat_ack_ratio;
 extern int  sysctl_dccp_feat_send_ack_vector;
-extern int  sysctl_dccp_feat_send_ndp_count;
 extern int  sysctl_dccp_tx_qlen;
 extern int  sysctl_dccp_sync_ratelimit;
 
--- a/net/dccp/minisocks.c
+++ b/net/dccp/minisocks.c
@@ -47,7 +47,6 @@ void dccp_minisock_init(struct dccp_mini
 	dmsk->dccpms_sequence_window = sysctl_dccp_feat_sequence_window;
 	dmsk->dccpms_ack_ratio	     = sysctl_dccp_feat_ack_ratio;
 	dmsk->dccpms_send_ack_vector = sysctl_dccp_feat_send_ack_vector;
-	dmsk->dccpms_send_ndp_count  = sysctl_dccp_feat_send_ndp_count;
 }
 
 void dccp_time_wait(struct sock *sk, int state, int timeo)
