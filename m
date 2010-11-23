From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 23 Nov 2010 12:36:56 +0000
Subject: net-2.6 [Patch 1/1][BUG-FIX] dccp: advancing the Ack window
Message-Id: <20101123123656.GB3915@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Dave,

please can you consider the following bug fix (applies on both net-2.6 and
net-next-2.6). I have no other dccp patches this week -- the second one that
follows is for the test tree only and is meant for RFC.

Best regards
Gerrit

(also on git://eden-feed.erg.abdn.ac.uk/net-next-2.6  [subtree 'dccp'])

>>>>>>>>>>>>>>>>>>>>>>>>>>>>  Patch / Fix <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
dccp: fix error in updating the GAR

This fixes a bug in updating the Greatest Acknowledgment number Received (GAR): 
the current implementation does not track the greatest received value -
lower values in the range AWL..AWH (RFC 4340, 7.5.1) erase higher ones.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/input.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

--- a/net/dccp/input.c
+++ b/net/dccp/input.c
@@ -241,7 +241,8 @@ static int dccp_check_seqno(struct sock 
 		dccp_update_gsr(sk, seqno);
 
 		if (dh->dccph_type != DCCP_PKT_SYNC &&
-		    (ackno != DCCP_PKT_WITHOUT_ACK_SEQ))
+		    ackno != DCCP_PKT_WITHOUT_ACK_SEQ &&
+		    after48(ackno, dp->dccps_gar))
 			dp->dccps_gar = ackno;
 	} else {
 		unsigned long now = jiffies;
