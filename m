From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 20 Jun 2007 09:55:39 +0000
Subject: [PATCH 2/5]: Fix Reset/Sync-Flood Bug
Message-Id: <200706201055.39795@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[DCCP]: Fix Reset/Sync-Flood Bug

This updates sequence number checking with regard to RFC 4340, 7.5.4.
Missing in the code was an exception for sequence-invalid Reset packets, 
which get a Sync acknowledging GSR, instead of (as usual) P.seqno.

This can lead to an oscillating ping-pong flood of Reset packets. 

In fact, it has been observed on the wire as follows:

 1. client establishes connection to server;
 2. before server can write to client, client crashes without notifying
    the server (NB: now no longer possible due to ABORT function);
 3. server sends DCCP-Data packet (has no ackno);
 4. client generates Reset "No Connection", seqno=0, increments seqno;
 5. server replies with Sync, using ackno = P.seqno;
 6. client generates Reset "No Connection" with seqno = ackno + 1;
 7. goto (5).

The difference is that now in (5) the server uses GSR.  This causes the
Reset sent by the client in (6) to become sequence-valid, so that in (7)
the vicious circle is broken; the Reset is then enqueued and causes the
socket to enter TIMEWAIT state.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/input.c |   14 +++++++++++---
 1 file changed, 11 insertions(+), 3 deletions(-)

--- a/net/dccp/input.c
+++ b/net/dccp/input.c
@@ -102,9 +102,6 @@ static int dccp_check_seqno(struct sock 
 	 *	  Update S.GSR, S.SWL, S.SWH
 	 *	  If P.type != Sync,
 	 *	     Update S.GAR
-	 *      Otherwise,
-	 *	  Send Sync packet acknowledging P.seqno
-	 *	  Drop packet and return
 	 */
 	lswl = dp->dccps_swl;
 	lawl = dp->dccps_awl;
@@ -135,6 +132,17 @@ static int dccp_check_seqno(struct sock 
 							      : "exists",
 			  (unsigned long long) lawl, (unsigned long long) ackno,
 			  (unsigned long long) dp->dccps_awh);
+		/*
+		 *   Step 6: Check sequence numbers
+		 *      Otherwise,
+		 *         If P.type = Reset,
+		 *            Send Sync packet acknowledging S.GSR
+		 *         Otherwise,
+		 *            Send Sync packet acknowledging P.seqno
+		 *      Drop packet and return
+		 */
+		if (dh->dccph_type = DCCP_PKT_RESET)
+			seqno = dp->dccps_gsr;
 		dccp_send_sync(sk, seqno, DCCP_PKT_SYNC);
 		return -1;
 	}
