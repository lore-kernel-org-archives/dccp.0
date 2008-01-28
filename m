From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 28 Jan 2008 10:16:12 +0000
Subject: [PATCH 2/6] [DCCP]: Bug in initial acknowledgment number assignment
Message-Id: <1201515376-8280-3-git-send-email-gerrit@erg.abdn.ac.uk>
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
 net/dccp/minisocks.c |    7 +++----
 1 files changed, 3 insertions(+), 4 deletions(-)

--- a/net/dccp/minisocks.c
+++ b/net/dccp/minisocks.c
@@ -122,13 +122,12 @@ struct sock *dccp_create_openreq_child(struct sock *sk,
 		 *    Initialize S.GAR := S.ISS
 		 *    Set S.ISR, S.GSR, S.SWL, S.SWH from packet or Init Cookies
 		 */
+		newdp->dccps_gar = newdp->dccps_iss = dreq->dreq_iss;
+		dccp_update_gss(newsk, dreq->dreq_iss);
 
-		newdp->dccps_gar = newdp->dccps_isr = dreq->dreq_isr;
+		newdp->dccps_isr = dreq->dreq_isr;
 		dccp_update_gsr(newsk, dreq->dreq_isr);
 
-		newdp->dccps_iss = dreq->dreq_iss;
-		dccp_update_gss(newsk, dreq->dreq_iss);
-
 		/*
 		 * SWL and AWL are initially adjusted so that they are not less than
 		 * the initial Sequence Numbers received and sent, respectively:
