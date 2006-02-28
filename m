From: Arnaldo Carvalho de Melo <acme@mandriva.com>
Date: Tue, 28 Feb 2006 22:09:02 +0000
Subject: [PATCH 3/4] [DCCP] options: Fix some aspects of mandatory option processing
Message-Id: <1141164542543-git-send-email-acme@mandriva.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

According to dccp draft (draft-ietf-dccp-spec-13.txt) section 5.8.2 (Mandatory
Option) the following patch correct the handling of the following cases:

1) "... and any Mandatory options received on DCCP-Data packets MUST be
  ignored."

2) "The connection is in error and should be reset with Reset Code 5, ...
  if option O is absent (Mandatory was the last byte of the option list), or
  if option O equals Mandatory."

Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>
Signed-off-by: Hagen Paul Pfeifer <hagen@jauu.net>

---

 net/dccp/options.c |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletions(-)

61e2a0fe55ae1e6b2d1f7f10660065de8c606e5c
diff --git a/net/dccp/options.c b/net/dccp/options.c
index 79d228e..8867b6f 100644
--- a/net/dccp/options.c
+++ b/net/dccp/options.c
@@ -109,7 +109,8 @@ int dccp_parse_options(struct sock *sk, 
 		case DCCPO_MANDATORY:
 			if (mandatory)
 				goto out_invalid_option;
-			mandatory = 1;
+			if (pkt_type != DCCP_PKT_DATA)
+				mandatory = 1;
 			break;
 		case DCCPO_NDP_COUNT:
 			if (len > 3)
@@ -249,6 +250,10 @@ int dccp_parse_options(struct sock *sk, 
 			mandatory = 0;
 	}
 
+	/* mandatory was the last byte in option list -> reset connection */
+	if (mandatory)
+		goto out_invalid_option;
+
 	return 0;
 
 out_invalid_option:
-- 
1.2.2.gd27d


