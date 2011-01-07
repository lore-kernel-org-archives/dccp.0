From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 07 Jan 2011 11:35:29 +0000
Subject: [PATCH 2/3] dccp: fix bug in updating the GSR
Message-Id: <1294400130-5604-3-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Samuel Jero <sj323707@ohio.edu>

Currently dccp_check_seqno allows any valid packet to update the Greatest
Sequence Number Received, even if that packet's sequence number is less than
the current GSR. This patch adds a check to make sure that the new packet's
sequence number is greater than GSR.

Signed-off-by: Samuel Jero <sj323707@ohio.edu>
Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/dccp.h |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -426,7 +426,8 @@ static inline void dccp_update_gsr(struct sock *sk, u64 seq)
 {
 	struct dccp_sock *dp = dccp_sk(sk);
 
-	dp->dccps_gsr = seq;
+	if (after48(seq, dp->dccps_gsr))
+		dp->dccps_gsr = seq;
 	/* Sequence validity window depends on remote Sequence Window (7.5.1) */
 	dp->dccps_swl = SUB48(ADD48(dp->dccps_gsr, 1), dp->dccps_r_seq_win / 4);
 	/*
