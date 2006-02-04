From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Sat, 04 Feb 2006 02:38:50 +0000
Subject: [PATCH 9/11][DCCP]: Don't alloc ack vector for the control sock
Message-Id: <39e6f6c70602031838i740111beyb1fdc030dfd594d1@mail.gmail.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----=_Part_11490_29753772.1139020730250"
List-Id: <dccp.vger.kernel.org>
To: dccp@vger.kernel.org

------=_Part_11490_29753772.1139020730250
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Hi David,

    Please consider pulling from:

master.kernel.org:/pub/scm/linux/kernel/git/acme/net-2.6.17.git

Best Regards,

- Arnaldo

------=_Part_11490_29753772.1139020730250
Content-Type: text/x-patch; name=9.patch; charset=us-ascii
Content-Transfer-Encoding: 7bit
X-Attachment-Id: f_ej9be608
Content-Disposition: attachment; filename="9.patch"

tree 53906d2a70f6c94436b548e25548c10cea620498
parent c312bf30df32e63f17614eb9c7e127e85f40e354
author Arnaldo Carvalho de Melo <acme@mandriva.com> 1138987845 -0200
committer Arnaldo Carvalho de Melo <acme@mandriva.com> 1138987845 -0200

[DCCP]: Don't alloc ack vector for the control sock

Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>

------------------------------------------------------------------------------

 ipv4.c |   11 +++++------
 1 file changed, 5 insertions(+), 6 deletions(-)

------------------------------------------------------------------------------

diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index 9fedeca..fd5a615 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -1040,12 +1040,6 @@ int dccp_v4_init_sock(struct sock *sk)
 	dccp_options_init(&dp->dccps_options);
 	do_gettimeofday(&dp->dccps_epoch);
 
-	if (dp->dccps_options.dccpo_send_ack_vector) {
-		dp->dccps_hc_rx_ackvec = dccp_ackvec_alloc(GFP_KERNEL);
-		if (dp->dccps_hc_rx_ackvec == NULL)
-			return -ENOMEM;
-	}
-
 	/*
 	 * FIXME: We're hardcoding the CCID, and doing this at this point makes
 	 * the listening (master) sock get CCID control blocks, which is not
@@ -1054,6 +1048,11 @@ int dccp_v4_init_sock(struct sock *sk)
 	 * setsockopt(CCIDs-I-want/accept). -acme
 	 */
 	if (likely(!dccp_ctl_socket_init)) {
+		if (dp->dccps_options.dccpo_send_ack_vector) {
+			dp->dccps_hc_rx_ackvec = dccp_ackvec_alloc(GFP_KERNEL);
+			if (dp->dccps_hc_rx_ackvec == NULL)
+				return -ENOMEM;
+		}
 		dp->dccps_hc_rx_ccid = ccid_init(dp->dccps_options.dccpo_rx_ccid,
 						 sk);
 		dp->dccps_hc_tx_ccid = ccid_init(dp->dccps_options.dccpo_tx_ccid,


------=_Part_11490_29753772.1139020730250--
