From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 08 Jan 2007 15:41:03 +0000
Subject: [PATCH 1/1]: Safe usage of before48/after48 in the DCCP code
Message-Id: <200701081541.04026@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Here is as promised the patch to take care of the two ambiguous cases
stated in http://www.mail-archive.com/dccp@vger.kernel.org/msg01295.html

I have compile-tested it and below is a detailed justification why the use
of the (newer variant of) dccp_delta_seqno is equivalent to the old condition.

(NB: It might be possible to use a macro instead.)

--------------------> Patch <-------------------------------------------------
[DCCP]: Remove ambiguity in the way before48 is used

This removes two ambiguities in employing the new definition of before48,
following the analysis on http://www.mail-archive.com/dccp@vger.kernel.org/msg01295.html

 (1) Updating GSR when P.seqno >= S.SWL
     With the old definition we did not update when P.seqno and S.SWL are 2^47 apart. To
     ensure the same behaviour as with the old definition, this is replaced with the
     equivalent condition dccp_delta_seqno(S.SWL, P.seqno) >= 0

 (2) Sending SYNC when P.seqno >= S.OSR
     Here it is debatable whether the new definition causes an ambiguity: the case is
     similar to (1); and to have consistency with the case (1), we use the equivalent
     condition dccp_delta_seqno(S.OSR, P.seqno) >=  0

 Detailed Justification [not necessarily commit message]:
 --------------------------------------------------------
     dccp_delta_seqno(a, b) returns a value >= 0 if either a is `before' b or a = b, 
     using the new definition: a `before' b   <=>  1 <= (b - a) mod 2^48 <= 2^47 - 1.

     The old and new definition of `before' are identical as long as the modulo-2^48
     difference between a and b is not equal to 2^47. In both cases, a test of the
     form !before(x, y) has been replaced by dccp_delta_seqno(y, x) >= 0. 
     For all values excluding y = (x + 2^47) % 2^48, the equivalence is clear to see. 
     When y = (x + 2^47) % 2^48 then !before(x, y) returned false in the new definition.
     However, 'dccp_delta_seqno(x, (x+2^47) % 2^48) >= 0' also returns false; hence we
     have full equivalence.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/input.c |    6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

--- a/net/dccp/input.c
+++ b/net/dccp/input.c
@@ -86,7 +86,8 @@ static int dccp_check_seqno(struct sock 
 	    dh->dccph_type = DCCP_PKT_SYNCACK) {
 		if (between48(DCCP_SKB_CB(skb)->dccpd_ack_seq,
 			      dp->dccps_awl, dp->dccps_awh) &&
-		    !before48(DCCP_SKB_CB(skb)->dccpd_seq, dp->dccps_swl))
+		    dccp_delta_seqno(dp->dccps_swl,
+				     DCCP_SKB_CB(skb)->dccpd_seq) >= 0)
 			dccp_update_gsr(sk, DCCP_SKB_CB(skb)->dccpd_seq);
 		else
 			return -1;
@@ -203,7 +204,8 @@ static int __dccp_rcv_established(struct
 		if (dp->dccps_role != DCCP_ROLE_CLIENT)
 			goto send_sync;
 check_seq:
-		if (!before48(DCCP_SKB_CB(skb)->dccpd_seq, dp->dccps_osr)) {
+		if (dccp_delta_seqno(dp->dccps_osr,
+				     DCCP_SKB_CB(skb)->dccpd_seq) >=  0) {
 send_sync:
 			dccp_send_sync(sk, DCCP_SKB_CB(skb)->dccpd_seq,
 				       DCCP_PKT_SYNC);
