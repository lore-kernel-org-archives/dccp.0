From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 30 Dec 2010 06:31:54 +0000
Subject: Re: Sequence Number Validation Bug Fixes 2/2
Message-Id: <20101230063154.GB5119@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <1293393024.22785.1.camel@jero-laptop>
In-Reply-To: <1293393024.22785.1.camel@jero-laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

| --- a/net/dccp/input.c
| +++ b/net/dccp/input.c
| @@ -252,7 +253,10 @@ static int dccp_check_seqno(struct sock *sk, struct
| sk_buff *skb)
| if (between48(seqno, lswl, dp->dccps_swh) &&
|     (ackno = DCCP_PKT_WITHOUT_ACK_SEQ ||
|      between48(ackno, lawl, dp->dccps_awh))) {
| - dccp_update_gsr(sk, seqno);
| +
| + if(after48(seqno, dp->dccps_gsr)){
| + dccp_update_gsr(sk, seqno);
| + }
| 
| if (dh->dccph_type != DCCP_PKT_SYNC &&
|     ackno != DCCP_PKT_WITHOUT_ACK_SEQ && 

I would like to move that change from dccp_check_seqno() into
dccp_update_gsr(), since the latter function is also called for Sync/SyncAck
packets, where the same problem exists.

The edited patch is below -- please have a look. This allows to safely call
dccp_update_gsr() without moving the window backwards. Calling that function
may be required not only when GSR changes, but also when the Sequence Window
value is updated, which requires to update the SWL/SWH boundaries.


>>>>>>>>>>>>>>>>>>>>>> Patch v2 <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
dccp: fix bug in updating the GSR

Currently dccp_check_seqno allows any valid packet to update the Greatest
Sequence Number Received, even if that packet's sequence number is less than
the current GSR. This patch adds a check to make sure that the new packet's
sequence number is greater than GSR.

Signed-off-by: Samuel Jero <sj323707@ohio.edu>
Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/dccp.h |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -426,7 +426,8 @@ static inline void dccp_update_gsr(struc
 {
 	struct dccp_sock *dp = dccp_sk(sk);
 
-	dp->dccps_gsr = seq;
+	if (after48(seq, dp->dccps_gsr))
+		dp->dccps_gsr = seq;
 	/* Sequence validity window depends on remote Sequence Window (7.5.1) */
 	dp->dccps_swl = SUB48(ADD48(dp->dccps_gsr, 1), dp->dccps_r_seq_win / 4);
 	/*
