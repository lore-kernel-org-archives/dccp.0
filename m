From: Samuel Jero <sj323707@ohio.edu>
Date: Tue, 15 Mar 2011 04:53:17 +0000
Subject: Re: dccp test-tree [RFC] [Patch 2/2] dccp: CCID2 check ack ratio
Message-Id: <1300164797.20638.65.camel@jero-laptop>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="=-rjZlnKAh2brar6wvK5MH"
List-Id: <dccp.vger.kernel.org>
To: dccp@vger.kernel.org

--=-rjZlnKAh2brar6wvK5MH
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

This patch causes CCID2 to check the ack ratio after reducing the
congestion window. If the ack ratio is greater than the congestion
window, it is reduced. This prevents timeouts caused by an ack ratio
larger than the congestion window.=20

In this situation, we choose to set the ack ratio to half the congestion
window (or one if that's zero) so that if we loose one ack we don't
trigger a timeout.

---=20
Signed-off-by: Samuel Jero
diff --git a/net/dccp/ccids/ccid2.c b/net/dccp/ccids/ccid2.c
index 1475ba3..b7f7dbd 100644
--- a/net/dccp/ccids/ccid2.c
+++ b/net/dccp/ccids/ccid2.c
@@ -118,4 +118,22 @@ static void ccid2_change_l_seq_window(struct sock *sk,=
 u64 val)
 		dccp_feat_signal_nn_change(sk, DCCPF_SEQUENCE_WINDOW, val);
 }
+
+static void ccid2_check_l_ack_ratio(struct sock *sk)
+{
+	struct ccid2_hc_tx_sock *hc =3D ccid2_hc_tx_sk(sk);
+
+	/*
+	* After a loss, idle period, application limited period, or RTO we
+	* need tocheck that the ack ratio is still less than the congestion
+	* window. Otherwise, we will send an entire congestion window of
+	* packets and got no response because we haven't sent ack ratio
+	* packets yet.
+	* If the ack ratio does need to be reduced, we reduce it to half of
+	* the congestion window (or 1 if that's zero) instead of to the
+	* congestion window. This prevents problems if one ack is lost.
+	*/
+	if (dccp_feat_get_nn_next_val(sk, DCCPF_ACK_RATIO) > hc->tx_cwnd)
+		ccid2_change_l_ack_ratio(sk, hc->tx_cwnd/2 ? : 1U);
+}
=20
 static void ccid2_hc_tx_rto_expire(unsigned long data)
@@ -203,6 +214,8 @@ static void ccid2_cwnd_application_limited(struct sock =
*sk, const u32 now)
 	}
 	hc->tx_cwnd_used  =3D 0;
 	hc->tx_cwnd_stamp =3D now;
+
+	ccid2_check_l_ack_ratio(sk);
 }
=20
 /* This borrows the code of tcp_cwnd_restart() */
@@ -221,6 +234,8 @@ static void ccid2_cwnd_restart(struct sock *sk, const u=
32 now)
=20
 	hc->tx_cwnd_stamp =3D now;
 	hc->tx_cwnd_used  =3D 0;
+
+	ccid2_check_l_ack_ratio(sk);
 }
=20
 static void ccid2_hc_tx_packet_sent(struct sock *sk, unsigned int len)
@@ -490,9 +505,7 @@ static void ccid2_congestion_event(struct sock *sk, str=
uct ccid2_seq *seqp)
 	hc->tx_cwnd      =3D hc->tx_cwnd / 2 ? : 1U;
 	hc->tx_ssthresh  =3D max(hc->tx_cwnd, 2U);
=20
-	/* Avoid spurious timeouts resulting from Ack Ratio > cwnd */
-	if (dccp_sk(sk)->dccps_l_ack_ratio > hc->tx_cwnd)
-		ccid2_change_l_ack_ratio(sk, hc->tx_cwnd);
+	ccid2_check_l_ack_ratio(sk);
 }
=20
 static int ccid2_hc_tx_parse_options(struct sock *sk, u8 packet_type,


--=-rjZlnKAh2brar6wvK5MH
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEABECAAYFAk1+8LkACgkQEwoGUlJjrt8ixACfYp3dVtUeSF7SHmUpV3F/CKhK
JaUAniHLVwrKhQKRoIIFGabYLJGWyCws
=VeDn
-----END PGP SIGNATURE-----

--=-rjZlnKAh2brar6wvK5MH--
