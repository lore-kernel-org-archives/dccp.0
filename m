From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sat, 27 Oct 2007 11:34:21 +0000
Subject: [PATCH 2/6]: Bug in reading Ack Vectors
Message-Id: <200710271234.21096@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[CCID2]: Bug in reading Ack Vectors

In CCID2 the receiver-history is sorted in ascending order of sequence number,
but the processing of received Ack Vectors requires the list traversal in the
opposite direction.

The current code has a bug in this regard: the list traversal is upwards. As a
consequence, only Ack Vectors with a run length of 1 will pass, in all other
Ack Vectors the remaining (acked) sequence numbers are missed, and may later
falsely be identified as lost.

Note: This bug is only visible when Ack Ratio > 1, since otherwise the run
      lengths of Ack Vectors are 0.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/ccid2.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- a/net/dccp/ccids/ccid2.c
+++ b/net/dccp/ccids/ccid2.c
@@ -666,7 +666,7 @@ static void ccid2_hc_tx_packet_recv(stru
 					done = 1;
 					break;
 				}
-				seqp = seqp->ccid2s_next;
+				seqp = seqp->ccid2s_prev;
 			}
 			if (done)
 				break;
