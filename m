From: Wei Yongjun <yjwei@cn.fujitsu.com>
Date: Mon, 18 Aug 2008 05:57:04 +0000
Subject: [PATCH] dccp: Do not send Dccp-Sync after received sequence-invalid
Message-Id: <48A90F30.9060203@cn.fujitsu.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

RFC4340 said:

7.5.4.  Handling Sequence-Invalid Packets

o  A sequence-invalid DCCP-Reset packet MUST elicit a DCCP-Sync
   packet in response (subject to a possible rate limit).  This
   response packet MUST use a new Sequence Number, and thus will
   increase GSS; GSR will not change, however, since the received
   packet was sequence-invalid.  The response packet's
   Acknowledgement Number MUST equal GSR.

But reponse to a sequence-invalid DCCP-Reset with acknowledgement
number equal to GSR will help to attack for sequence number. The
attack method as the following:

Endpoint A                                 Endpoint B
                                           (OPEN)
Dccp-Request      ---------------->
(SEQ=X)
                  <----------------        SYNC
                                           (SEQ=GSS+1, ACK=X)
Dccp-Reset        ---------------->
(SEQ=X+1, ACK=GSS+1)
                  <----------------        SYNC
                                           (SEQ=GSS+2, ACK=GSR)

X = invalid sequence number
GSS = sequence number of endpoint B
GSR = sequence number of endpoint A

After we received SYNC from endpoint B, we known the sequence number
of both side.

The best way to avoid this is not send Dccp-Sync after received
sequence-invalid Dccp-Reset.

Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
---
 net/dccp/input.c |    8 ++++++--
 1 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/net/dccp/input.c b/net/dccp/input.c
index 71b24d4..fdb3c2c 100644
--- a/net/dccp/input.c
+++ b/net/dccp/input.c
@@ -242,6 +242,12 @@ static int dccp_check_seqno(struct sock *sk, struct sk_buff *skb)
 		if (dh->dccph_type != DCCP_PKT_SYNC &&
 		    (ackno != DCCP_PKT_WITHOUT_ACK_SEQ))
 			dp->dccps_gar = ackno;
+	} else if (dh->dccph_type = DCCP_PKT_RESET) {
+		/*
+		 * Ignore sequence-invalid Dccp-Reset to avoid sequence numbers
+		 * attack. 
+		 */
+		return -1;
 	} else {
 		unsigned long now = jiffies;
 		/*
@@ -273,8 +279,6 @@ static int dccp_check_seqno(struct sock *sk, struct sk_buff *skb)
 
 		dp->dccps_rate_last = now;
 
-		if (dh->dccph_type = DCCP_PKT_RESET)
-			seqno = dp->dccps_gsr;
 		dccp_send_sync(sk, seqno, DCCP_PKT_SYNC);
 		return -1;
 	}
-- 
1.5.3.8





