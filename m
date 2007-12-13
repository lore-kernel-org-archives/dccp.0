From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Thu, 13 Dec 2007 15:06:05 +0000
Subject: [PATCH 12/12] [DCCP]: Ignore feature negotiation on Data packets
Message-Id: <1197558365-31134-13-git-send-email-acme@redhat.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>

This implements [RFC 4340, p. 32]: "any feature negotiation options received
on DCCP-Data packets MUST be ignored".

Also added a FIXME for further processing, since the code currently (wrongly)
classifies empty Confirm options as invalid - this needs to be resolved in
a separate patch.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 net/dccp/options.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/net/dccp/options.c b/net/dccp/options.c
index bedb5da..d2a84a2 100644
--- a/net/dccp/options.c
+++ b/net/dccp/options.c
@@ -132,6 +132,8 @@ int dccp_parse_options(struct sock *sk, struct dccp_request_sock *dreq,
 		case DCCPO_CHANGE_L:
 			/* fall through */
 		case DCCPO_CHANGE_R:
+			if (pkt_type = DCCP_PKT_DATA)
+				break;
 			if (len < 2)
 				goto out_invalid_option;
 			rc = dccp_feat_change_recv(sk, opt, *value, value + 1,
@@ -148,7 +150,9 @@ int dccp_parse_options(struct sock *sk, struct dccp_request_sock *dreq,
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
-- 
1.5.3.4

