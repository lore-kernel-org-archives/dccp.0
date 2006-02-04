From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Sat, 04 Feb 2006 02:38:36 +0000
Subject: [PATCH 7/11][DCCP] CCID: Allow ccid_{init,exit} to be NULL
Message-Id: <39e6f6c70602031838g7f14ebf1s567ad1ba84db9d0b@mail.gmail.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----=_Part_11478_17467437.1139020716593"
List-Id: <dccp.vger.kernel.org>
To: dccp@vger.kernel.org

------=_Part_11478_17467437.1139020716593
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Hi David,

    Please consider pulling from:

master.kernel.org:/pub/scm/linux/kernel/git/acme/net-2.6.17.git

Best Regards,

- Arnaldo

------=_Part_11478_17467437.1139020716593
Content-Type: text/x-patch; name=7.patch; charset=us-ascii
Content-Transfer-Encoding: 7bit
X-Attachment-Id: f_ej9bcm1g
Content-Disposition: attachment; filename="7.patch"

tree 819a12569a02512dbbb427d857fbe22756bc4772
parent 90e6088d8191c44c120ede18b19e09ad0da28121
author Arnaldo Carvalho de Melo <acme@mandriva.com> 1138987435 -0200
committer Arnaldo Carvalho de Melo <acme@mandriva.com> 1138987435 -0200

[DCCP] CCID: Allow ccid_{init,exit} to be NULL

Testing if the ccid being instantiated has these methods in
ccid_init().

Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>

------------------------------------------------------------------------------

 ccid.c        |    5 +----
 ccids/ccid3.c |   11 -----------
 2 files changed, 1 insertion(+), 15 deletions(-)

------------------------------------------------------------------------------

diff --git a/net/dccp/ccid.c b/net/dccp/ccid.c
index 9d8fc0e..06b191a 100644
--- a/net/dccp/ccid.c
+++ b/net/dccp/ccid.c
@@ -59,9 +59,6 @@ int ccid_register(struct ccid *ccid)
 {
 	int err;
 
-	if (ccid->ccid_init == NULL)
-		return -1;
-
 	ccids_write_lock();
 	err = -EEXIST;
 	if (ccids[ccid->ccid_id] == NULL) {
@@ -106,7 +103,7 @@ struct ccid *ccid_init(unsigned char id,
 	if (!try_module_get(ccid->ccid_owner))
 		goto out_err;
 
-	if (ccid->ccid_init(sk) != 0)
+	if (ccid->ccid_init != NULL && ccid->ccid_init(sk) != 0)
 		goto out_module_put;
 out:
 	ccids_read_unlock();
diff --git a/net/dccp/ccids/ccid3.c b/net/dccp/ccids/ccid3.c
index aa68e0a..c539c33 100644
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -76,15 +76,6 @@ static struct dccp_tx_hist *ccid3_tx_his
 static struct dccp_rx_hist *ccid3_rx_hist;
 static struct dccp_li_hist *ccid3_li_hist;
 
-static int ccid3_init(struct sock *sk)
-{
-	return 0;
-}
-
-static void ccid3_exit(struct sock *sk)
-{
-}
-
 /* TFRC sender states */
 enum ccid3_hc_tx_states {
        	TFRC_SSTATE_NO_SENT = 1,
@@ -1178,8 +1169,6 @@ static struct ccid ccid3 = {
 	.ccid_id		   = 3,
 	.ccid_name		   = "ccid3",
 	.ccid_owner		   = THIS_MODULE,
-	.ccid_init		   = ccid3_init,
-	.ccid_exit		   = ccid3_exit,
 	.ccid_hc_tx_init	   = ccid3_hc_tx_init,
 	.ccid_hc_tx_exit	   = ccid3_hc_tx_exit,
 	.ccid_hc_tx_send_packet	   = ccid3_hc_tx_send_packet,

------=_Part_11478_17467437.1139020716593--
