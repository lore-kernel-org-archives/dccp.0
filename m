From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 27 Sep 2007 14:21:27 +0000
Subject: [PATCH 10/11]: Limit feature negotiation to connection setup phase
Message-Id: <200709271521.27745@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[DCCP]: Limit feature negotiation to connection setup phase

Although it is theoretically possible to perform feature negotiation at any time (and RFC 4340
supports this), this is practically very complicated, since during feature negotiation the traffic
needs to be put on hold.

This patch disables anytime negotiation, subsequent patches work out full feature negotiation
support for connection setup. (The limitation is later lifted, but requires a different concept first).

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/feat.c |   13 ++++++++-----
 1 file changed, 8 insertions(+), 5 deletions(-)

--- a/net/dccp/feat.c
+++ b/net/dccp/feat.c
@@ -6,6 +6,8 @@
  *
  *  ASSUMPTIONS
  *  -----------
+ *  o Feature negotiation is coordinated with connection setup (as in TCP), wild
+ *    changes of parameters of an established connection are not supported.
  *  o All currently known SP features have 1-byte quantities. If in the future
  *    extensions of RFCs 4340..42 define features with item lengths larger than
  *    one byte, a feature-specific extension of the code will be required.
@@ -646,6 +648,9 @@ int dccp_feat_change_recv(struct sock *s
 {
 	int rc;
 
+	/* Ignore Change requests other than during connection setup */
+	if (sk->sk_state != DCCP_LISTEN && sk->sk_state != DCCP_REQUESTING)
+		return 0;
 	dccp_feat_debug(type, feature, *val);
 
 	/* figure out if it's SP or NN feature */
@@ -695,6 +700,9 @@ int dccp_feat_confirm_recv(struct sock *
 	int found = 0;
 	int all_confirmed = 1;
 
+	/* Ignore Confirm options other than during connection setup */
+	if (sk->sk_state != DCCP_LISTEN && sk->sk_state != DCCP_REQUESTING)
+		return 0;
 	dccp_feat_debug(type, feature, *val);
 
 	/* locate our change request */
@@ -730,11 +738,6 @@ int dccp_feat_confirm_recv(struct sock *
 	}
 
 	/* fix re-transmit timer */
-	/* XXX gotta make sure that no option negotiation occurs during
-	 * connection shutdown.  Consider that the CLOSEREQ is sent and timer is
-	 * on.  if all options are confirmed it might kill timer which should
-	 * remain alive until close is received.
-	 */
 	if (all_confirmed) {
 		dccp_pr_debug("clear feat negotiation timer %p\n", sk);
 		inet_csk_clear_xmit_timer(sk, ICSK_TIME_RETRANS);
