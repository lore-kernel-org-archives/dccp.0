From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Mon, 02 Jan 2006 16:54:21 +0000
Subject: [PATCH 3/3][DCCP]: Notify CCID only after ACK vectors have been processed
Message-Id: <39e6f6c70601020854m6e746900ue60fb823cddfa297@mail.gmail.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----=_Part_14020_25722383.1136220861935"
List-Id: <dccp.vger.kernel.org>
To: dccp@vger.kernel.org

------=_Part_14020_25722383.1136220861935
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Hi David,

 Please consider pulling from:

master.kernel.org:/pub/scm/linux/kernel/git/acme/net-2.6.16.git

Best Regards,

- Arnaldo

------=_Part_14020_25722383.1136220861935
Content-Type: text/x-patch; name=3.patch; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="3.patch"

tree 0ea2fae5f2e089c5c491869a12543c6791d10da1
parent 7d96f7a6a44a53029fb4d8540ce223e622527798
author Andrea Bittau <a.bittau@cs.ucl.ac.uk> 1136217403 -0200
committer Arnaldo Carvalho de Melo <acme@mandriva.com> 1136217403 -0200

[DCCP]: Notify CCID only after ACK vectors have been processed.

The CCID should be notified of packet reception only when a packet is valid.
Therefore, the ACK vector needs to be processed before notifying the CCID.
Also, the CCID might need information provided by the ACK vector.

Signed-off-by: Andrea Bittau <a.bittau@cs.ucl.ac.uk>
Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>

------------------------------------------------------------------------------

 input.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

------------------------------------------------------------------------------

diff --git a/net/dccp/input.c b/net/dccp/input.c
index cb0f5c9..b6cba72 100644
--- a/net/dccp/input.c
+++ b/net/dccp/input.c
@@ -492,14 +492,14 @@ int dccp_rcv_state_process(struct sock *
 		if (dcb->dccpd_ack_seq != DCCP_PKT_WITHOUT_ACK_SEQ)
 			dccp_event_ack_recv(sk, skb);
 
-		ccid_hc_rx_packet_recv(dp->dccps_hc_rx_ccid, sk, skb);
-		ccid_hc_tx_packet_recv(dp->dccps_hc_tx_ccid, sk, skb);
-
  		if (dp->dccps_options.dccpo_send_ack_vector &&
 		    dccp_ackvec_add(dp->dccps_hc_rx_ackvec, sk,
  				    DCCP_SKB_CB(skb)->dccpd_seq,
  				    DCCP_ACKVEC_STATE_RECEIVED))
  			goto discard;
+
+		ccid_hc_rx_packet_recv(dp->dccps_hc_rx_ccid, sk, skb);
+		ccid_hc_tx_packet_recv(dp->dccps_hc_tx_ccid, sk, skb);
 	}
 
 	/*


------=_Part_14020_25722383.1136220861935--
