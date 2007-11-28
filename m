From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Wed, 28 Nov 2007 15:23:49 +0000
Subject: [PATCH 2/5] Use AF-independent rebuild_header routine
Message-Id: <1196263432-17390-3-git-send-email-acme@redhat.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>

[DCCP]: Use AF-independent rebuild_header routine

This fixes a nasty bug: dccp_send_reset() is called by both DCCPv4 and DCCPv6, but uses
inet_sk_rebuild_header() in each case. This leads to unpredictable and weird behaviour:
under some conditions, DCCPv6 Resets were sent, in other not.

The fix is to use the AF-independent rebuild_header routine.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 net/dccp/output.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/dccp/output.c b/net/dccp/output.c
index 33ce737..7caa7f5 100644
--- a/net/dccp/output.c
+++ b/net/dccp/output.c
@@ -391,7 +391,7 @@ int dccp_send_reset(struct sock *sk, enum dccp_reset_codes code)
 	 * FIXME: what if rebuild_header fails?
 	 * Should we be doing a rebuild_header here?
 	 */
-	int err = inet_sk_rebuild_header(sk);
+	int err = inet_csk(sk)->icsk_af_ops->rebuild_header(sk);
 
 	if (err != 0)
 		return err;
-- 
1.5.3.4

