From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 14 Jul 2011 13:42:31 +0000
Subject: [PATCH 03/07] dccp: send Confirm options only once
Message-Id: <1310650955-5159-4-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Samuel Jero <sj323707@ohio.edu>

If a connection is in the OPEN state, then remove Feature Negotiation Confirm
Options from the list of options to send after they are sent once. Confirm
options are NOT supposed to be retransmitted and are ONLY supposed to be
sent in response to a Change Option (RFC 4340 6.2).

When combined with feature negotiation code that would reset the connection on
an feature negotiation value that didn't match the most recently sent value,
this issue will cause a connection reset on the second feature negotiation
for any given NN feature.

Signed-off-by: Samuel Jero <sj323707@ohio.edu>
Acked-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/feat.c |   21 ++++++++++++++++-----
 1 files changed, 16 insertions(+), 5 deletions(-)

--- a/net/dccp/feat.c
+++ b/net/dccp/feat.c
@@ -665,11 +665,22 @@ int dccp_feat_insert_opts(struct dccp_sock *dp, struct dccp_request_sock *dreq,
 			return -1;
 		if (pos->needs_mandatory && dccp_insert_option_mandatory(skb))
 			return -1;
-		/*
-		 * Enter CHANGING after transmitting the Change option (6.6.2).
-		 */
-		if (pos->state = FEAT_INITIALISING)
-			pos->state = FEAT_CHANGING;
+
+		if (skb->sk->sk_state = DCCP_OPEN &&
+		    (opt = DCCPO_CONFIRM_R || opt = DCCPO_CONFIRM_L)) {
+			/*
+			 * Confirms don't get retransmitted (6.6.3) once the
+			 * connection is in state OPEN
+			 */
+			dccp_feat_list_pop(pos);
+		} else {
+			/*
+			 * Enter CHANGING after transmitting the Change
+			 * option (6.6.2).
+			 */
+			if (pos->state = FEAT_INITIALISING)
+				pos->state = FEAT_CHANGING;
+		}
 	}
 	return 0;
 }
