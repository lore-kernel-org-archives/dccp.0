From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 28 Nov 2007 08:35:08 +0000
Subject: [PATCH 1/4]: Use AF-independent rebuild_header routine
Message-Id: <11962389111717-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[DCCP]: Use AF-independent rebuild_header routine

This fixes a nasty bug: dccp_send_reset() is called by both DCCPv4 and DCCPv6, but uses
inet_sk_rebuild_header() in each case. This leads to unpredictable and weird behaviour:
under some conditions, DCCPv6 Resets were sent, in other not.

The fix is to use the AF-independent rebuild_header routine.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/output.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- a/net/dccp/output.c
+++ b/net/dccp/output.c
@@ -391,7 +391,7 @@ int dccp_send_reset(struct sock *sk, enu
 	 * FIXME: what if rebuild_header fails?
 	 * Should we be doing a rebuild_header here?
 	 */
-	int err = inet_sk_rebuild_header(sk);
+	int err = inet_csk(sk)->icsk_af_ops->rebuild_header(sk);
 
 	if (err != 0)
 		return err;
