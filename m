From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 04 Oct 2007 14:02:22 +0000
Subject: [PATCH 5/5]: Use feature-negotiation to report Ack Ratio changes
Message-Id: <200710041502.22109@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[CCID2]: Use feature-negotiation to report Ack Ratio changes

This uses the new feature-negotiation framework to signal Ack Ratio changes,
as required by RFC 4341, sec. 6.1.2. 

This raises some problems for CCID2 since it can at the moment not cope grace-
fully with Ack Ratio of e.g. 2. A FIXME has thus been added which reverts to
the previous policy of bypassing the Ack Ratio sysctl.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 Documentation/networking/dccp.txt |    4 +++-
 net/dccp/minisocks.c              |   12 ++++++++++++
 net/dccp/proto.c                  |    1 -
 3 files changed, 15 insertions(+), 2 deletions(-)

--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -190,7 +190,6 @@ int dccp_init_sock(struct sock *sk, cons
 	dp->dccps_rate_last	= jiffies;
 	dp->dccps_role		= DCCP_ROLE_UNDEFINED;
 	dp->dccps_service	= DCCP_SERVICE_CODE_IS_ABSENT;
-	dp->dccps_l_ack_ratio	= dp->dccps_r_ack_ratio = 1;
 
 	return 0;
 }
--- a/net/dccp/minisocks.c
+++ b/net/dccp/minisocks.c
@@ -323,10 +323,22 @@ int dccp_hdlr_seq_win(struct sock *sk, u
 
 int dccp_hdlr_ack_ratio(struct sock *sk, u64 ratio, bool rx)
 {
+#ifndef __CCID2_COPES_GRACEFULLY_WITH_DYNAMIC_ACK_RATIO_UPDATES__
+	/*
+	 * FIXME: This hack is required to remain bug-compatible with CCID2.
+	 * Using Ack Ratios > 1 lead to hangups and long RTO timeouts
+	 * (1..3 seconds). CCID2 code needs to be fixed first before being
+	 * able to use dynamic updates of Ack Ratio.
+	 */
+	DCCP_WARN("Not changing %s Ack Ratio from 1 to %u\n", rx ? "RX" : "TX",
+		  (u16)ratio);
+	dccp_sk(sk)->dccps_l_ack_ratio = dccp_sk(sk)->dccps_r_ack_ratio = 1;
+#else
 	if (rx)
 		dccp_sk(sk)->dccps_r_ack_ratio = ratio;
 	else
 		dccp_sk(sk)->dccps_l_ack_ratio = ratio;
+#endif
 	return 0;
 }
 
--- a/Documentation/networking/dccp.txt
+++ b/Documentation/networking/dccp.txt
@@ -144,7 +144,9 @@ send_ackvec = 1
 	Whether or not to send Ack Vector options (sec. 11.5).
 
 ack_ratio = 2
-	The default Ack Ratio (sec. 11.3) to use.
+	The default local (sender) Ack Ratio (sec. 11.3). This will only be used
+	if the active TX CCID supports it (currently only CCID2). The receiver
+	Ack Ratio is set automatically from the sender Ack Ratio of the	peer.
 
 seq_window = 100
 	The initial sequence window (sec. 7.5.2) of the sender. This influences
