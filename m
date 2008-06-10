From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 10 Jun 2008 12:53:42 +0000
Subject: [PATCH 6/7] dccp: Bug in initial acknowledgment number assignment
Message-Id: <1213102423-27486-7-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Step 8.5 in RFC 4340 says for the newly cloned socket

           Initialize S.GAR := S.ISS,

but what in fact the code (minisocks.c) does is

           Initialize S.GAR := S.ISR,

which is wrong (typo?) -- fixed by the patch.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/minisocks.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

--- a/net/dccp/minisocks.c
+++ b/net/dccp/minisocks.c
@@ -165,12 +165,12 @@ out_free:
 		/* See dccp_v4_conn_request */
 		newdmsk->dccpms_sequence_window = req->rcv_wnd;
 
-		newdp->dccps_gar = newdp->dccps_isr = dreq->dreq_isr;
-		dccp_update_gsr(newsk, dreq->dreq_isr);
-
-		newdp->dccps_iss = dreq->dreq_iss;
+		newdp->dccps_gar = newdp->dccps_iss = dreq->dreq_iss;
 		dccp_update_gss(newsk, dreq->dreq_iss);
 
+		newdp->dccps_isr = dreq->dreq_isr;
+		dccp_update_gsr(newsk, dreq->dreq_isr);
+
 		/*
 		 * SWL and AWL are initially adjusted so that they are not less than
 		 * the initial Sequence Numbers received and sent, respectively:
