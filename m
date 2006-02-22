From: Arnaldo Carvalho de Melo <acme@mandriva.com>
Date: Wed, 22 Feb 2006 21:38:41 +0000
Subject: [PATCH 3/4] [DCCP]: Call dccp_feat_init more early in dccp_v4_init_sock
Message-Id: <11406443213002-git-send-email-acme@mandriva.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

So that dccp_feat_clean doesn't get confused with uninitialized list_heads.

Noticed when testing with no ccid kernel modules.

Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>

---

 net/dccp/ipv4.c |    9 ++++-----
 1 files changed, 4 insertions(+), 5 deletions(-)

f79878f104ec370040510ae7db907b4504c46d3a
diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index 54fabb1..4a2ce1c 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -1051,7 +1051,10 @@ int dccp_v4_init_sock(struct sock *sk)
 	 * setsockopt(CCIDs-I-want/accept). -acme
 	 */
 	if (likely(!dccp_ctl_socket_init)) {
-		int rc;
+		int rc = dccp_feat_init(sk);
+
+		if (rc)
+			return rc;
 
 		if (dp->dccps_options.dccpo_send_ack_vector) {
 			dp->dccps_hc_rx_ackvec = dccp_ackvec_alloc(GFP_KERNEL);
@@ -1075,10 +1078,6 @@ int dccp_v4_init_sock(struct sock *sk)
 			dp->dccps_hc_rx_ccid = dp->dccps_hc_tx_ccid = NULL;
 			return -ENOMEM;
 		}
-
-		rc = dccp_feat_init(sk);
-		if (rc)
-			return rc;
 	} else {
 		/* control socket doesn't need feat nego */
 		INIT_LIST_HEAD(&dp->dccps_options.dccpo_pending);
-- 
1.1.GIT


