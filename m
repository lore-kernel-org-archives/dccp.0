From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 07 Jan 2011 11:35:28 +0000
Subject: [PATCH 1/3] dccp: fix return value for sequence-invalid packets
Message-Id: <1294400130-5604-2-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Samuel Jero <sj323707@ohio.edu>

Currently dccp_check_seqno returns 0 (indicating a valid packet) if the
acknowledgment number is out of bounds and the sync that RFC 4340 mandates at
this point is currently being rate-limited. This function should return -1,
indicating an invalid packet.

Signed-off-by: Samuel Jero <sj323707@ohio.edu>
Acked-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/input.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

--- a/net/dccp/input.c
+++ b/net/dccp/input.c
@@ -260,7 +260,7 @@ static int dccp_check_seqno(struct sock *sk, struct sk_buff *skb)
 		 */
 		if (time_before(now, (dp->dccps_rate_last +
 				      sysctl_dccp_sync_ratelimit)))
-			return 0;
+			return -1;
 
 		DCCP_WARN("Step 6 failed for %s packet, "
 			  "(LSWL(%llu) <= P.seqno(%llu) <= S.SWH(%llu)) and "
