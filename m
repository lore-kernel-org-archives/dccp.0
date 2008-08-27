From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 27 Aug 2008 05:35:21 +0000
Subject: [PATCH 2/6] dccp: Silently ignore options with nonsensical lengths
Message-Id: <1219815325-13778-3-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This updates the option-parsing code with regard to RFC 4340, 5.8:
 "[..] options with nonsensical lengths (length byte less than two or more
  than the remaining space in the options portion of the header) MUST be
  ignored, and any option space following an option with nonsensical length
  MUST likewise be ignored."

Hence in the following cases erratic options will be ignored:
 1. The type byte of a multi-byte option is the last byte of the header
    options (i.e. effective option length of 1).
 2. The value of the length byte is less than the minimum 2. This has been
    changed from previously 3: although no multi-byte option with a length
    less than 3 yet exists (cf. table 3 in 5.8), a length of 2 is valid.
    (The switch-statement in dccp_parse has further per-option length checks.)
 3. The option length exceeds the length of the remaining option space.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/options.c |   10 ++++++----
 1 files changed, 6 insertions(+), 4 deletions(-)

--- a/net/dccp/options.c
+++ b/net/dccp/options.c
@@ -81,11 +81,11 @@ int dccp_parse_options(struct sock *sk, struct dccp_request_sock *dreq,
 		/* Check if this isn't a single byte option */
 		if (opt > DCCPO_MAX_RESERVED) {
 			if (opt_ptr = opt_end)
-				goto out_invalid_option;
+				goto out_nonsensical_length;
 
 			len = *opt_ptr++;
-			if (len < 3)
-				goto out_invalid_option;
+			if (len < 2)
+				goto out_nonsensical_length;
 			/*
 			 * Remove the type and len fields, leaving
 			 * just the value size
@@ -95,7 +95,7 @@ int dccp_parse_options(struct sock *sk, struct dccp_request_sock *dreq,
 			opt_ptr += len;
 
 			if (opt_ptr > opt_end)
-				goto out_invalid_option;
+				goto out_nonsensical_length;
 		}
 
 		/*
@@ -283,6 +283,8 @@ ignore_option:
 	if (mandatory)
 		goto out_invalid_option;
 
+out_nonsensical_length:
+	/* RFC 4340, 5.8: ignore option and all remaining option space */
 	return 0;
 
 out_invalid_option:
