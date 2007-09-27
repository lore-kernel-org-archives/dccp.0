From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 27 Sep 2007 14:20:52 +0000
Subject: [PATCH 3/11]: Ignore feature negotiation on Data packets
Message-Id: <200709271520.52147@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[DCCP]: Ignore feature negotiation on Data packets

This implements [RFC 4340, p. 32]: "any feature negotiation options received
on DCCP-Data packets MUST be ignored".

Also added a FIXME for further processing, since the code currently (wrongly)
classifies empty Confirm options as invalid - this needs to be resolved in
a separate patch.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/options.c |    6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

--- a/net/dccp/options.c
+++ b/net/dccp/options.c
@@ -125,6 +125,8 @@ int dccp_parse_options(struct sock *sk, 
 		case DCCPO_CHANGE_L:
 			/* fall through */
 		case DCCPO_CHANGE_R:
+			if (pkt_type = DCCP_PKT_DATA)
+				break;
 			if (len < 2)
 				goto out_invalid_option;
 			rc = dccp_feat_change_recv(sk, opt, *value, value + 1,
@@ -141,7 +143,9 @@ int dccp_parse_options(struct sock *sk, 
 		case DCCPO_CONFIRM_L:
 			/* fall through */
 		case DCCPO_CONFIRM_R:
-			if (len < 2)
+			if (pkt_type = DCCP_PKT_DATA)
+				break;
+			if (len < 2)	/* FIXME this disallows empty confirm */
 				goto out_invalid_option;
 			if (dccp_feat_confirm_recv(sk, opt, *value,
 						   value + 1, len - 1))
