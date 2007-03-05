From: Andre Noll <maan@systemlinux.org>
Date: Mon, 05 Mar 2007 14:32:40 +0000
Subject: kernel BUG at kernel/timer.c:407!
Message-Id: <20070305143240.GW22572@skl-net.de>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="hOh8F6DNH/RZBSFD"
List-Id: <dccp.vger.kernel.org>
To: dccp@vger.kernel.org


--hOh8F6DNH/RZBSFD
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi

In linux-2.6.20 and linux-2.6.21-pre1, the kernel oops shown below is
repeatably triggered by paraslash's [1] dccp sender (which is based
on Ian McDonald's dccp-cs-0.01.tar.bz2).

git-bisect pointed out=20

	bf58a381e8106fe73247c753e3da58fcb5eabd2e
	[DCCP]: Only deliver to the CCID rx side in charge

as the culprit. Reverting this commit, i.e. applying the patch below
to linux-2.6.21-pre1, makes the problem go away.

So this change seems to introduce a use of an uninitialized timer in
the dccp kernel code. Does anybody know how to fix it?

Thanks
Andre
---
dccp_feat_debug: ChangeL(CCID (1), 2)
dccp_feat_debug: ChangeR(CCID (1), 2)
dccp_feat_debug: ChangeL(Ack Ratio (5), 2)
ccid2_change_cwnd: change cwnd to 1
ccid2_change_srtt: change SRTT to -1
ccid2_hc_tx_check_sanity: len of chain=3D0
ccid2_hc_tx_check_sanity: total len=3D1024
dccp_feat_debug: ChangeL(CCID (1), 2)
dccp_feat_debug: ChangeR(CCID (1), 2)
dccp_feat_debug: ChangeL(Ack Ratio (5), 2)
ccid2_change_cwnd: change cwnd to 1
ccid2_change_srtt: change SRTT to -1
ccid2_hc_tx_check_sanity: len of chain=3D0
ccid2_hc_tx_check_sanity: total len=3D1024
dccp_set_state: client(c15807f8) CLOSED     -> REQUESTING
dccp_insert_feat_opt: ChangeL(CCID (1), ...), length 1
dccp_insert_feat_opt: ChangeR(CCID (1), ...), length 1
dccp_insert_feat_opt: ChangeL(Ack Ratio (5), ...), length 1
dccp_insert_options_feat: reset feat negotiation timer c15807f8
dccp_v4_rcv:  REQUEST src=3D127.0.0.1@46800 dst=3D127.0.0.1@5001  seq=3D432=
6915464
dccp_feat_debug: ChangeL(Ack Ratio (5), 2)
dccp_feat_debug: ChangeL(Ack Ratio (5), 2)
dccp_feat_update: UNIMPLEMENTED: ChangeL(5, ...)
dccp_feat_debug: ChangeL(Ack Ratio (5), 2)
dccp_feat_debug: ChangeR(CCID (1), 2)
dccp_feat_debug: ChangeL(CCID (1), 2)
dccp_feat_reconcile: Will confirm 2
dccp_feat_reconcile: won't ask for change of same feature
dccp_feat_debug: ChangeL(CCID (1), 2)
dccp_feat_debug: ChangeR(CCID (1), 2)
dccp_feat_reconcile: Will confirm 2
dccp_feat_reconcile: won't ask for change of same feature
dccp_insert_feat_opt: ConfirmR(Ack Ratio (5), ...), length 1
dccp_insert_feat_opt: ConfirmL(CCID (1), ...), length 2
dccp_insert_feat_opt: ConfirmR(CCID (1), ...), length 2
dccp_insert_feat_opt: ChangeL(Ack Ratio (5), ...), length 1
dccp_v4_rcv: RESPONSE src=3D127.0.0.1@5001  dst=3D127.0.0.1@46800 seq=3D351=
0785020, ack=3D4326915464
dccp_feat_debug: ChangeL(Ack Ratio (5), 2)
dccp_feat_debug: ChangeL(Ack Ratio (5), 2)
dccp_feat_update: UNIMPLEMENTED: ChangeL(5, ...)
dccp_feat_debug: ChangeL(Ack Ratio (5), 2)
dccp_feat_debug: ConfirmR(CCID (1), 2)
dccp_feat_confirm_recv: feature 1 found
dccp_feat_debug: ChangeL(CCID (1), 2)
dccp_feat_confirm_recv: clear feat negotiation timer c15807f8
dccp_feat_debug: ConfirmL(CCID (1), 2)
dccp_feat_confirm_recv: feature 1 found
dccp_feat_debug: ChangeR(CCID (1), 2)
dccp_feat_confirm_recv: clear feat negotiation timer c15807f8
dccp_feat_debug: ConfirmR(Ack Ratio (5), 2)
dccp_feat_confirm_recv: feature 5 found
dccp_feat_debug: ChangeL(Ack Ratio (5), 2)
dccp_feat_update: UNIMPLEMENTED: ChangeL(5, ...)
dccp_feat_confirm_recv: clear feat negotiation timer c15807f8
dccp_set_state: client(c15807f8) REQUESTING -> PARTOPEN
dccp_insert_option_ackvec: client ACK Vector 0, len=3D1, ack_seqno=3D432691=
5465, ack_ackno=3D3510785020
dccp_insert_feat_opt: ConfirmR(Ack Ratio (5), ...), length 1
dccp_v4_rcv:      ACK src=3D127.0.0.1@46800 dst=3D127.0.0.1@5001  seq=3D432=
6915465, ack=3D3510785020
ccid2_change_cwnd: change cwnd to 1
ccid2_change_srtt: change SRTT to -1
ccid2_hc_tx_check_sanity: len of chain=3D0
ccid2_hc_tx_check_sanity: total len=3D1024
dccp_feat_debug: ConfirmR(Ack Ratio (5), 2)
dccp_feat_confirm_recv: feature 5 found
dccp_feat_debug: ChangeL(Ack Ratio (5), 2)
dccp_feat_update: UNIMPLEMENTED: ChangeL(5, ...)
dccp_feat_confirm_recv: clear feat negotiation timer c1580414
dccp_parse_options: server rx opt: ELAPSED_TIME=3D1
dccp_set_state: server(c1580414) RESPOND    -> OPEN
ccid2_hc_tx_send_packet: pipe=3D0 cwnd=3D1
dccp_insert_option_ackvec: server ACK Vector 0, len=3D1, ack_seqno=3D351078=
5021, ack_ackno=3D4326915465
dccp_v4_rcv:  DATAACK src=3D127.0.0.1@5001  dst=3D127.0.0.1@46800 seq=3D351=
0785021, ack=3D4326915465
dccp_ackvec_check_rcv_ackvector: client ACK vector 0, len=3D1, ack_seqno=3D=
4326915465, ack_ackno=3D3510785020, ACKED!
dccp_parse_options: client rx opt: ELAPSED_TIME=3D29799
ccid2_hc_tx_check_sanity: len of chain=3D0
ccid2_hc_tx_check_sanity: total len=3D1024
dccp_set_state: client(c15807f8) PARTOPEN   -> OPEN
ccid2_hc_tx_check_sanity: len of chain=3D0
ccid2_hc_tx_check_sanity: total len=3D1024
ccid2_hc_tx_packet_sent: cwnd=3D1 pipe=3D1
ccid2_start_rto_timer: setting RTO timeout=3D3000
ccid2_hc_tx_packet_sent: pipe=3D1
ccid2_hc_tx_packet_sent: Sent: seq=3D3510785021
ccid2_hc_tx_packet_sent: out seq=3D3510785021 acked=3D0 time=3D4294695413
ccid2_hc_tx_packet_sent: =3D=3D=3D=3D=3D=3D=3D=3D=3D
ccid2_hc_tx_check_sanity: len of chain=3D1
ccid2_hc_tx_check_sanity: total len=3D1024
ccid2_hc_tx_send_packet: pipe=3D1 cwnd=3D1
------------[ cut here ]------------
kernel BUG at kernel/timer.c:407!
invalid opcode: 0000 [#1]
PREEMPT=20
CPU:    0
EIP:    0060:[<c0124ace>]    Not tainted VLI
EFLAGS: 00210246   (2.6.20.1 #12)
EIP is at mod_timer+0x28/0x2c
eax: c15807d4   ebx: c1580414   ecx: 00000000   edx: fffbda11
esi: c1580414   edi: dea75644   ebp: dc637db8   esp: dc637db8
ds: 007b   es: 007b   ss: 0068
Process para_server (pid: 1085, ti=3Ddc636000 task=3Dde5df030 task.ti=3Ddc6=
36000)
Stack: dc637dc4 c0369b66 00000001 dc637df8 c0407ddc dc637de0 c15804bc 00200=
292=20
       dc637de4 c041588c c15804b0 dc637df8 00000000 dea75644 c1580414 dc7b2=
ec4=20
       dc637e1c c040971d dc637e08 dc637e8c 00000000 00000000 c0529780 c1580=
414=20
Call Trace:
 [<c0103c3b>] show_trace_log_lvl+0x1a/0x30
 [<c0103cf2>] show_stack_log_lvl+0x8d/0xaa
 [<c0103f07>] show_registers+0x1a8/0x312
 [<c0104210>] die+0x109/0x226
 [<c01043ab>] do_trap+0x7e/0xb4
 [<c0104684>] do_invalid_op+0xa3/0xad
 [<c0415b5c>] error_code+0x74/0x7c
 [<c0369b66>] sk_reset_timer+0xf/0x19
 [<c0407ddc>] dccp_write_xmit+0x224/0x22c
 [<c040971d>] dccp_sendmsg+0x10a/0x15a
 [<c03a9e26>] inet_sendmsg+0x44/0x55
 [<c036666a>] do_sock_write+0x9a/0xa9
 [<c03666e3>] sock_aio_write+0x6a/0x7b
 [<c015afc6>] do_sync_write+0xc7/0x116
 [<c015b197>] vfs_write+0x182/0x187
 [<c015b23d>] sys_write+0x3d/0x64
 [<c0102fa4>] syscall_call+0x7/0xb
 =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
Code: 0b eb fe 55 8b 48 0c 89 e5 85 c9 74 1e 39 50 08 74 0b e8 15 ff ff ff =
89 c1 5d 89 c8 c3 83 38 00 b9 01 00 00 00 74 eb 89 c8 5d c3 <0f> 0b eb fe 5=
5 89 e5 83 ec 0c 89 5d f8 89 75 fc 89 c3 8b 00 31=20
EIP: [<c0124ace>] mod_timer+0x28/0x2c SS:ESP 0068:dc637db8
 <7>dccp_set_state: listen(c1580030) LISTEN     -> CLOSED
ccid2_hc_tx_kill_rto_timer: deleted RTO timer
dccp_set_state: client(c15807f8) OPEN       -> CLOSING
dccp_insert_option_ackvec: client ACK Vector 0, len=3D1, ack_seqno=3D432691=
5466, ack_ackno=3D3510785021
dccp_v4_rcv:    CLOSE src=3D127.0.0.1@46800 dst=3D127.0.0.1@5001  seq=3D432=
6915466, ack=3D3510785021
dccp_insert_option_ackvec: client ACK Vector 0, len=3D1, ack_seqno=3D432691=
5467, ack_ackno=3D3510785021
dccp_v4_rcv:    CLOSE src=3D127.0.0.1@46800 dst=3D127.0.0.1@5001  seq=3D432=
6915467, ack=3D3510785021
dccp_insert_option_ackvec: client ACK Vector 0, len=3D1, ack_seqno=3D432691=
5468, ack_ackno=3D3510785021
dccp_v4_rcv:    CLOSE src=3D127.0.0.1@46800 dst=3D127.0.0.1@5001  seq=3D432=
6915468, ack=3D3510785021
dccp_insert_option_ackvec: client ACK Vector 0, len=3D1, ack_seqno=3D432691=
5469, ack_ackno=3D3510785021
dccp_v4_rcv:    CLOSE src=3D127.0.0.1@46800 dst=3D127.0.0.1@5001  seq=3D432=
6915469, ack=3D3510785021
---
commit 26cea71dac43be2de14c2cd71bd5bfb1465dd386
Author: Installations Account <install@meins.(none)>
Date:   Wed Feb 28 23:06:26 2007 +0100

    revert [bf58a381e8106fe73247c753e3da58fcb5eabd2e] [DCCP]: Only deliver =
to the CCID rx side in charge
   =20
    As this causes an oops in mod_timer()

diff --git a/net/dccp/ccids/ccid3.c b/net/dccp/ccids/ccid3.c
index 40402c5..3b168bd 100644
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -542,7 +542,7 @@ static void ccid3_hc_tx_packet_recv(stru
 				   jiffies + usecs_to_jiffies(t_nfb));
=20
 		/* set idle flag */
-		hctx->ccid3hctx_idle =3D 1;
+		hctx->ccid3hctx_idle =3D 1;  =20
 		break;
 	case TFRC_SSTATE_NO_SENT:
 		/*
diff --git a/net/dccp/input.c b/net/dccp/input.c
index 565bc80..6e4715e 100644
--- a/net/dccp/input.c
+++ b/net/dccp/input.c
@@ -248,18 +248,8 @@ int dccp_rcv_established(struct sock *sk
 			    DCCP_ACKVEC_STATE_RECEIVED))
 		goto discard;
=20
-	/*
-	 * Deliver to the CCID module in charge.
-	 * FIXME: Currently DCCP operates one-directional only, i.e. a listening
-	 *        server is not at the same time a connecting client. There is
-	 *        not much sense in delivering to both rx/tx sides at the moment
-	 *        (only one is active at a time); when moving to bidirectional
-	 *        service, this needs to be revised.
-	 */
-	if (dccp_sk(sk)->dccps_role =3D=3D DCCP_ROLE_SERVER)
-		ccid_hc_rx_packet_recv(dp->dccps_hc_rx_ccid, sk, skb);
-	else
-		ccid_hc_tx_packet_recv(dp->dccps_hc_tx_ccid, sk, skb);
+	ccid_hc_rx_packet_recv(dp->dccps_hc_rx_ccid, sk, skb);
+	ccid_hc_tx_packet_recv(dp->dccps_hc_tx_ccid, sk, skb);
=20
 	return __dccp_rcv_established(sk, skb, dh, len);
 discard:
@@ -494,11 +484,8 @@ int dccp_rcv_state_process(struct sock *
 				    DCCP_ACKVEC_STATE_RECEIVED))
 			goto discard;
=20
-		/* XXX see the comments in dccp_rcv_established about this */
-		if (dccp_sk(sk)->dccps_role =3D=3D DCCP_ROLE_SERVER)
-			ccid_hc_rx_packet_recv(dp->dccps_hc_rx_ccid, sk, skb);
-		else
-			ccid_hc_tx_packet_recv(dp->dccps_hc_tx_ccid, sk, skb);
+		ccid_hc_rx_packet_recv(dp->dccps_hc_rx_ccid, sk, skb);
+		ccid_hc_tx_packet_recv(dp->dccps_hc_tx_ccid, sk, skb);
 	}
=20
 	/*
---
[1] www.paraslash.org
--=20
The only person who always got his work done by Friday was Robinson Crusoe

--hOh8F6DNH/RZBSFD
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.1 (GNU/Linux)

iD8DBQFF7CoIWto1QDEAkw8RAlOSAKCjUb0/QOmfHpKqLXgJYw7uaRBYuACgmUNV
EeqitHXd8r1m/0BvZG6NxkM=
=5lip
-----END PGP SIGNATURE-----

--hOh8F6DNH/RZBSFD--
