From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 27 Aug 2008 05:35:22 +0000
Subject: [PATCH 3/6] dccp: Fill in the Data fields for "Option Error" Resets
Message-Id: <1219815325-13778-4-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This updates the use of the `out_invalid_option' label, which produces a
Reset (code 5, "Option Error"), to fill in the  Data1...Data3 fields as
specified in RFC 4340, 5.6.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/options.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

--- a/net/dccp/options.c
+++ b/net/dccp/options.c
@@ -291,6 +291,9 @@ out_invalid_option:
 	DCCP_INC_STATS_BH(DCCP_MIB_INVALIDOPT);
 	DCCP_SKB_CB(skb)->dccpd_reset_code = DCCP_RESET_CODE_OPTION_ERROR;
 	DCCP_WARN("DCCP(%p): invalid option %d, len=%d", sk, opt, len);
+	DCCP_SKB_CB(skb)->dccpd_reset_data[0] = opt;
+	DCCP_SKB_CB(skb)->dccpd_reset_data[1] = len > 0 ? value[0] : 0;
+	DCCP_SKB_CB(skb)->dccpd_reset_data[2] = len > 1 ? value[1] : 0;
 	return -1;
 }
 
