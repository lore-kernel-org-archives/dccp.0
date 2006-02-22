From: Hagen Paul Pfeifer <hagen@jauu.net>
Date: Wed, 22 Feb 2006 11:33:10 +0000
Subject: [PATCH]
Message-Id: <20060222113310.GA21876@c3po.0xdef.net>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="2oS5YaxWCcQjTEyO"
List-Id: <dccp.vger.kernel.org>
To: dccp@vger.kernel.org


--2oS5YaxWCcQjTEyO
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline


According to dccp draft (draft-ietf-dccp-spec-13.txt) section 5.8.2 (Mandatory
Option) the following patch correct the handling of the following cases:

1) "... and any Mandatory options received on DCCP-Data packets MUST be
   ignored."

2) "The connection is in error and should be reset with Reset Code 5, ...
   if option O is absent (Mandatory was the last byte of the option list), or
   if option O equals Mandatory."


options.c |    7 ++++++-
1 file changed, 6 insertions(+), 1 deletion(-)

Best regards

Hagen Pfeifer



--2oS5YaxWCcQjTEyO
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: attachment; filename="mandatory.patch"

diff --git a/net/dccp/options.c b/net/dccp/options.c
index 7d73b33..3db9aad 100644
--- a/net/dccp/options.c
+++ b/net/dccp/options.c
@@ -107,7 +107,8 @@ int dccp_parse_options(struct sock *sk, 
 		case DCCPO_MANDATORY:
 			if (mandatory)
 				goto out_invalid_option;
-			mandatory = 1;
+			if (pkt_type != DCCP_PKT_DATA)
+				mandatory = 1;
 			break;
 		case DCCPO_NDP_COUNT:
 			if (len > 3)
@@ -247,6 +248,10 @@ int dccp_parse_options(struct sock *sk, 
 			mandatory = 0;
 	}
 
+	/* mandatory was the last byte in option list -> reset connection */
+	if (mandatory)
+		goto out_invalid_option;
+
 	return 0;
 
 out_invalid_option:

--2oS5YaxWCcQjTEyO--
