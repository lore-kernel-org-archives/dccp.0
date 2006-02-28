From: Hagen Paul Pfeifer <hagen@jauu.net>
Date: Tue, 28 Feb 2006 20:15:05 +0000
Subject: [PATCH] Mandatory Option Draft Cleanup
Message-Id: <20060228201505.GD317@c3po.0xdef.net>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="yVhtmJPUSI46BTXb"
List-Id: <dccp.vger.kernel.org>
References: <20060222113802.GB21876@c3po.0xdef.net>
In-Reply-To: <20060222113802.GB21876@c3po.0xdef.net>
To: dccp@vger.kernel.org


--yVhtmJPUSI46BTXb
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline


According to dccp draft (draft-ietf-dccp-spec-13.txt) section 5.8.2 (Mandatory
Option) the following patch correct the handling of the following cases:

1) "... and any Mandatory options received on DCCP-Data packets MUST be
   ignored."

2) "The connection is in error and should be reset with Reset Code 5, ...
   if option O is absent (Mandatory was the last byte of the option list), or
   if option O equals Mandatory."


Signed-off-by: Hagen Paul Pfeifer <hagen@jauu.net>



--yVhtmJPUSI46BTXb
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

--yVhtmJPUSI46BTXb--
