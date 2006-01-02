From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Mon, 02 Jan 2006 16:54:06 +0000
Subject: [PATCH 2/3][DCCP]: Send an ACK vector when ACKing a response packet
Message-Id: <39e6f6c70601020854v65ddfae3tc01b6204c43818f1@mail.gmail.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----=_Part_14008_19682076.1136220846583"
List-Id: <dccp.vger.kernel.org>
To: dccp@vger.kernel.org

------=_Part_14008_19682076.1136220846583
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Hi David,

 Please consider pulling from:

master.kernel.org:/pub/scm/linux/kernel/git/acme/net-2.6.16.git

Best Regards,

- Arnaldo

------=_Part_14008_19682076.1136220846583
Content-Type: text/x-patch; name=2.patch; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="2.patch"

tree ea024a03f12dad7a2074f71afd2b3148347323f0
parent caf2e7480ba587b7cb6902e1bfcd6832dfd393bf
author Andrea Bittau <a.bittau@cs.ucl.ac.uk> 1136217289 -0200
committer Arnaldo Carvalho de Melo <acme@mandriva.com> 1136217289 -0200

[DCCP]: Send an ACK vector when ACKing a response packet

If ACK vectors are used, each packet with an ACK should contain an ACK vector.
The only exception currently is response packets.  It probably is not a good
idea to store ACK vector state before the connection is completed (to help
protect from syn floods).

Signed-off-by: Andrea Bittau <a.bittau@cs.ucl.ac.uk>
Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>

------------------------------------------------------------------------------

 input.c |    6 ++++++
 1 file changed, 6 insertions(+)

------------------------------------------------------------------------------

diff --git a/net/dccp/input.c b/net/dccp/input.c
index 5e312b0..cb0f5c9 100644
--- a/net/dccp/input.c
+++ b/net/dccp/input.c
@@ -300,6 +300,12 @@ static int dccp_rcv_request_sent_state_p
 			goto out_invalid_packet;
 		}
 
+                if (dp->dccps_options.dccpo_send_ack_vector &&
+                    dccp_ackvec_add(dp->dccps_hc_rx_ackvec, sk,
+                                    DCCP_SKB_CB(skb)->dccpd_seq,
+                                    DCCP_ACKVEC_STATE_RECEIVED))
+                        goto out_invalid_packet; /* FIXME: change error code */
+
 		dp->dccps_isr = DCCP_SKB_CB(skb)->dccpd_seq;
 		dccp_update_gsr(sk, dp->dccps_isr);
 		/*


------=_Part_14008_19682076.1136220846583--
