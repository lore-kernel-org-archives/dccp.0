From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 11 Jul 2008 11:48:49 +0000
Subject: Re: [PATCH 1/1] [DCCP][QPOLICY]: More strict controlling of
Message-Id: <20080711114849.GA25718@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <20080710200543.AD02ABD27@poczta.oswiecenia.net>
In-Reply-To: <20080710200543.AD02ABD27@poczta.oswiecenia.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

| Ensure that cmsg->cmsg_type value is valid for qpolicy that is currently in use.
| Slightly revised version after comments from Gerrit.
| 
Thanks, this looks good and compiles cleanly. It is currently uploaded to
	git://eden-feed.erg.abdn.ac.uk/dccp_exp 	(subtree `qpolicy')
but I would like to add it to the test tree soon, with changes as below.

Are there any objections in reserving the first 16 bits for qpolicy -- I
think this should be enough to get a good number of policies started.

--- a/include/linux/dccp.h
+++ b/include/linux/dccp.h
@@ -198,6 +198,8 @@ enum dccp_feature_numbers {
 /* DCCP socket control message types for cmsg */
 enum dccp_cmsg_type {
 	DCCP_SCM_PRIORITY = 1,
+	DCCP_SCM_QPOLICY_MAX = 0xFFFF,
+	/* Up to here reserved exclusively for qpolicy parameters */
 	DCCP_SCM_MAX
 };
 
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -730,7 +730,8 @@ static int dccp_msghdr_parse(struct msgh
 		if (cmsg->cmsg_level != SOL_DCCP)
 			continue;
 
-		if (!dccp_qpolicy_param_ok(skb->sk, cmsg->cmsg_type))
+		if (cmsg->cmsg_type <= DCCP_SCM_QPOLICY_MAX &&
+		    !dccp_qpolicy_param_ok(skb->sk, cmsg->cmsg_type))
 			return -EINVAL;
 
 		switch (cmsg->cmsg_type) {
	
