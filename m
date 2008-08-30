From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sat, 30 Aug 2008 13:52:22 +0000
Subject: Re: [PATCH 14/37] dccp: Tidy up setsockopt calls
Message-Id: <20080830135222.GD17190@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <1219945512-7723-15-git-send-email-gerrit@erg.abdn.ac.uk>
In-Reply-To: <1219945512-7723-15-git-send-email-gerrit@erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Resent for reference after incorporating the suggestions made by
Arnaldo and Eugene. Many thanks for comments and suggestions.

>>>>>>>>>>>>>>>>>>>>>>>>>> Patch v2 <<<<<<<<<<<<<<<<<<<<<<<<<<<<
dccp: Tidy up setsockopt calls

This splits the setsockopt calls into two groups, depending on whether an
integer argument (val) is required and whether routines being called do
their own locking.

Some options (such as setting the CCID) use u8 rather than int, so that for
these the test with regard to integer-sizeof can not be used.

The second switch-case statement now only has those statements which need
locking and which make use of `val'.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
Acked-by: Arnaldo Carvalho de Melo <acme@redhat.com>
Reviewed-by: Eugene Teo <eugeneteo@kernel.sg>
---
 net/dccp/proto.c |   23 ++++++++++++-----------
 1 file changed, 12 insertions(+), 11 deletions(-)

--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -512,7 +512,17 @@ static int do_dccp_setsockopt(struct soc
 	struct dccp_sock *dp = dccp_sk(sk);
 	int val, err = 0;
 
-	if (optlen < sizeof(int))
+	switch (optname) {
+	case DCCP_SOCKOPT_PACKET_SIZE:
+		DCCP_WARN("sockopt(PACKET_SIZE) is deprecated: fix your app\n");
+		return 0;
+	case DCCP_SOCKOPT_CHANGE_L:
+	case DCCP_SOCKOPT_CHANGE_R:
+		DCCP_WARN("sockopt(CHANGE_L/R) is deprecated: fix your app\n");
+		return 0;
+	}
+
+	if (optlen < (int)sizeof(int))
 		return -EINVAL;
 
 	if (get_user(val, (int __user *)optval))
@@ -523,15 +533,6 @@ static int do_dccp_setsockopt(struct soc
 
 	lock_sock(sk);
 	switch (optname) {
-	case DCCP_SOCKOPT_PACKET_SIZE:
-		DCCP_WARN("sockopt(PACKET_SIZE) is deprecated: fix your app\n");
-		err = 0;
-		break;
-	case DCCP_SOCKOPT_CHANGE_L:
-	case DCCP_SOCKOPT_CHANGE_R:
-		DCCP_WARN("sockopt(CHANGE_L/R) is deprecated: fix your app\n");
-		err = 0;
-		break;
 	case DCCP_SOCKOPT_SERVER_TIMEWAIT:
 		if (dp->dccps_role != DCCP_ROLE_SERVER)
 			err = -EOPNOTSUPP;
@@ -548,8 +549,8 @@ static int do_dccp_setsockopt(struct soc
 		err = -ENOPROTOOPT;
 		break;
 	}
-
 	release_sock(sk);
+
 	return err;
 }
 
