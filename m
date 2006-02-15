From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Wed, 15 Feb 2006 12:30:30 +0000
Subject: [PATCH 2/2][DCCP] CCID2: Drop sock reference count on timer expiration and reset
Message-Id: <39e6f6c70602150430x35cabcf1p9ea5b9538087e6ad@mail.gmail.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----=_Part_3899_28735733.1140006630163"
List-Id: <dccp.vger.kernel.org>
To: dccp@vger.kernel.org

------=_Part_3899_28735733.1140006630163
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Hi David,

  Please consider pulling from:

master.kernel.org:/pub/scm/linux/kernel/git/acme/net-2.6.17.git

  Now there are two outstanding csets in this tree.

Best Regards,

- Arnaldo

------=_Part_3899_28735733.1140006630163
Content-Type: text/x-patch; name=2.patch; charset=us-ascii
Content-Transfer-Encoding: 7bit
X-Attachment-Id: f_ejpmhdjt
Content-Disposition: attachment; filename="2.patch"

tree 9f3ff0a05e7a2ac51825e18c0af0233ad9c26541
parent 75548ffb3813e123bf90d20b595c01fd363b8160
author Andrea Bittau <a.bittau@cs.ucl.ac.uk> 1140006497 -0200
committer Arnaldo Carvalho de Melo <acme@mandriva.com> 1140006497 -0200

[DCCP] CCID2: Drop sock reference count on timer expiration and reset.

There was a hybrid use of standard timers and sk_timers.  This caused the
reference count of the sock to be incorrect when resetting the RTO timer.  The
sock reference count should now be correct, enabling its destruction, and
allowing the DCCP module to be unloaded.

Signed-off-by: Andrea Bittau <a.bittau@cs.ucl.ac.uk>
Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>

------------------------------------------------------------------------------

 ccid2.c |   26 +++++++++++++++-----------
 1 file changed, 15 insertions(+), 11 deletions(-)

------------------------------------------------------------------------------

diff --git a/net/dccp/ccids/ccid2.c b/net/dccp/ccids/ccid2.c
index 5495980..6d4cb43 100644
--- a/net/dccp/ccids/ccid2.c
+++ b/net/dccp/ccids/ccid2.c
@@ -234,7 +234,7 @@ static void ccid2_hc_tx_rto_expire(unsig
 	ccid2_hc_tx_check_sanity(hctx);
 out:
 	bh_unlock_sock(sk);
-/*	sock_put(sk); */
+	sock_put(sk);
 }
 
 static void ccid2_start_rto_timer(struct sock *sk)
@@ -399,10 +399,12 @@ out_invalid_option:
 	return -1;
 }
 
-static void ccid2_hc_tx_kill_rto_timer(struct ccid2_hc_tx_sock *hctx)
+static void ccid2_hc_tx_kill_rto_timer(struct sock *sk)
 {
-	if (del_timer(&hctx->ccid2hctx_rtotimer))
-		ccid2_pr_debug("deleted RTO timer\n");
+	struct ccid2_hc_tx_sock *hctx = ccid2_hc_tx_sk(sk);
+
+	sk_stop_timer(sk, &hctx->ccid2hctx_rtotimer);
+	ccid2_pr_debug("deleted RTO timer\n");
 }
 
 static inline void ccid2_new_ack(struct sock *sk, 
@@ -496,17 +498,19 @@ static inline void ccid2_new_ack(struct 
 	}
 
 	/* we got a new ack, so re-start RTO timer */
-	ccid2_hc_tx_kill_rto_timer(hctx);
+	ccid2_hc_tx_kill_rto_timer(sk);
 	ccid2_start_rto_timer(sk);
 }
 
-static void ccid2_hc_tx_dec_pipe(struct ccid2_hc_tx_sock *hctx)
+static void ccid2_hc_tx_dec_pipe(struct sock *sk)
 {
+	struct ccid2_hc_tx_sock *hctx = ccid2_hc_tx_sk(sk);
+	
 	hctx->ccid2hctx_pipe--;
 	BUG_ON(hctx->ccid2hctx_pipe < 0);
 
 	if (hctx->ccid2hctx_pipe == 0)
-		ccid2_hc_tx_kill_rto_timer(hctx);
+		ccid2_hc_tx_kill_rto_timer(sk);
 }
 
 static void ccid2_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
@@ -627,7 +631,7 @@ static void ccid2_hc_tx_packet_recv(stru
 					seqp->ccid2s_acked = 1;
 					ccid2_pr_debug("Got ack for %llu\n",
 					       	       seqp->ccid2s_seq);
-					ccid2_hc_tx_dec_pipe(hctx);
+					ccid2_hc_tx_dec_pipe(sk);
 				}
 				if (seqp == hctx->ccid2hctx_seqt) {
 					done = 1;
@@ -674,7 +678,7 @@ static void ccid2_hc_tx_packet_recv(stru
 		while (1) {
 			if (!seqp->ccid2s_acked) {
 				loss = 1;
-				ccid2_hc_tx_dec_pipe(hctx);
+				ccid2_hc_tx_dec_pipe(sk);
 			}
 			if (seqp == hctx->ccid2hctx_seqt)
 				break;
@@ -760,9 +764,9 @@ static int ccid2_hc_tx_init(struct sock 
 static void ccid2_hc_tx_exit(struct sock *sk)
 {
 	struct dccp_sock *dp = dccp_sk(sk);
-        struct ccid2_hc_tx_sock *hctx = dp->dccps_hc_tx_ccid_private;
+        struct ccid2_hc_tx_sock *hctx = ccid2_hc_tx_sk(sk);
 
-	ccid2_hc_tx_kill_rto_timer(hctx);
+	ccid2_hc_tx_kill_rto_timer(sk);
 
 	kfree(hctx->ccid2hctx_seqbuf);
 

------=_Part_3899_28735733.1140006630163--
