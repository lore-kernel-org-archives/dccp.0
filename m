From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sun, 08 Jul 2007 11:41:05 +0000
Subject: [PATCH 6/8]: Use DIV_ROUND_UP macro
Message-Id: <200707081241.05584@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[ACKVEC]: Use DIV_ROUND_UP macro

This replaces a round-up operation with the macro defined
in include/linux/kernel.h.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ackvec.c |    5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

--- a/net/dccp/ackvec.c
+++ b/net/dccp/ackvec.c
@@ -69,9 +69,8 @@ int dccp_insert_option_ackvec(struct soc
 	struct dccp_sock *dp = dccp_sk(sk);
 	struct dccp_ackvec *av = dp->dccps_hc_rx_ackvec;
 	/* Figure out how many options do we need to represent the ackvec */
-	const u16 nr_opts = (av->dccpav_vec_len +
-			     DCCP_MAX_ACKVEC_OPT_LEN - 1) /
-			    DCCP_MAX_ACKVEC_OPT_LEN;
+	const u16 nr_opts = DIV_ROUND_UP(av->dccpav_vec_len,
+					 DCCP_MAX_ACKVEC_OPT_LEN);
 	u16 len = av->dccpav_vec_len + 2 * nr_opts, i;
 	struct timeval now;
 	u32 elapsed_time;
