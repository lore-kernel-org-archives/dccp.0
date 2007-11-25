From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Sun, 25 Nov 2007 00:21:27 +0000
Subject: [PATCH 02/18] [CCID2]: Bug in reading Ack Vectors
Message-Id: <1195950103-18102-3-git-send-email-acme@redhat.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>

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
Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 net/dccp/ccids/ccid2.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/dccp/ccids/ccid2.c b/net/dccp/ccids/ccid2.c
index c9c465e..7873dc7 100644
--- a/net/dccp/ccids/ccid2.c
+++ b/net/dccp/ccids/ccid2.c
@@ -666,7 +666,7 @@ static void ccid2_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
 					done = 1;
 					break;
 				}
-				seqp = seqp->ccid2s_next;
+				seqp = seqp->ccid2s_prev;
 			}
 			if (done)
 				break;
-- 
1.5.3.4

