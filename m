From: Samuel Jero <sj323707@ohio.edu>
Date: Mon, 14 Feb 2011 01:43:22 +0000
Subject: [PATCH 1/4] dccp: Prevent Congestion Window > Sequence Window
Message-Id: <1297647802.9816.144.camel@jero-laptop>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="=-INaWAU3bI8a99kYlXIha"
List-Id: <dccp.vger.kernel.org>
To: dccp@vger.kernel.org

--=-INaWAU3bI8a99kYlXIha
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Add a check to prevent CCID 2 from increasing the Congestion Window
greater than the Sequence Window. Doing so causes useless Syncs and
drops in throughput.
Also add code to adjust the sequence window to be about 5 times the
number of packets in the network (RFC 4340 7.5.2) and to adjust the Ack
Ratio so that the remote sequence window will hold about 5 times the
number of packets in the network.

---=20
Signed-off-by: Samuel Jero
diff --git a/net/dccp/ccids/ccid2.c b/net/dccp/ccids/ccid2.c
index 8f35c36..b70ed1d 100644
--- a/net/dccp/ccids/ccid2.c
+++ b/net/dccp/ccids/ccid2.c
@@ -106,6 +106,27 @@ static void ccid2_change_l_ack_ratio(struct sock *sk, =
u32 val)
=20
 	ccid2_pr_debug("changing local ack ratio to %u\n", val);
 	dp->dccps_l_ack_ratio =3D val;
+	dccp_feat_signal_nn_change(sk, DCCPF_ACK_RATIO, val);
+	return;
+}
+
+static void ccid2_change_l_seq_window(struct sock *sk, u64 val)
+{
+	struct dccp_sock *dp =3D dccp_sk(sk);
+
+	if (val < DCCPF_SEQ_WMIN)
+			val =3D DCCPF_SEQ_WMIN;
+
+	if (val > DCCPF_SEQ_WMAX)
+			val =3D DCCPF_SEQ_WMAX;
+
+	if (val =3D=3D dp->dccps_l_seq_win)
+			return;
+
+	dp->dccps_l_seq_win =3D val;
+	dccp_feat_signal_nn_change(sk,
+			DCCPF_SEQUENCE_WINDOW, dp->dccps_l_seq_win);
+	return;
 }
=20
 static void ccid2_hc_tx_rto_expire(unsigned long data)
@@ -418,17 +438,33 @@ static void ccid2_new_ack(struct sock *sk, struct cci=
d2_seq *seqp,
 			  unsigned int *maxincr)
 {
 	struct ccid2_hc_tx_sock *hc =3D ccid2_hc_tx_sk(sk);
-
-	if (hc->tx_cwnd < hc->tx_ssthresh) {
-		if (*maxincr > 0 && ++hc->tx_packets_acked =3D=3D 2) {
-			hc->tx_cwnd +=3D 1;
-			*maxincr    -=3D 1;
-			hc->tx_packets_acked =3D 0;
+	struct dccp_sock *dp =3D dccp_sk(sk);
+	int r_seq_used =3D hc->tx_cwnd/dp->dccps_l_ack_ratio;
+
+	if ((hc->tx_cwnd < dp->dccps_l_seq_win)
+			&& (r_seq_used < dp->dccps_r_seq_win)) {
+		if (hc->tx_cwnd < hc->tx_ssthresh) {
+			if (*maxincr > 0 && ++hc->tx_packets_acked =3D=3D 2) {
+				hc->tx_cwnd +=3D 1;
+				*maxincr    -=3D 1;
+				hc->tx_packets_acked =3D 0;
+			}
+		} else if (++hc->tx_packets_acked >=3D hc->tx_cwnd) {
+				hc->tx_cwnd +=3D 1;
+				hc->tx_packets_acked =3D 0;
 		}
-	} else if (++hc->tx_packets_acked >=3D hc->tx_cwnd) {
-			hc->tx_cwnd +=3D 1;
-			hc->tx_packets_acked =3D 0;
 	}
+
+	if (r_seq_used*5 >=3D dp->dccps_r_seq_win)
+		ccid2_change_l_ack_ratio(sk, dp->dccps_l_ack_ratio*2);
+	else if (r_seq_used*5 < (dp->dccps_r_seq_win/2))
+		ccid2_change_l_ack_ratio(sk, dp->dccps_l_ack_ratio/2);
+
+	if (hc->tx_cwnd*5 >=3D dp->dccps_l_seq_win)
+			ccid2_change_l_seq_window(sk, dp->dccps_l_seq_win*2);
+	else if (hc->tx_cwnd*5 < (dp->dccps_l_seq_win/2))
+			ccid2_change_l_seq_window(sk, dp->dccps_l_seq_win/2);
+
 	/*
 	 * FIXME: RTT is sampled several times per acknowledgment (for each
 	 * entry in the Ack Vector), instead of once per Ack (as in TCP SACK).


--=-INaWAU3bI8a99kYlXIha
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEABECAAYFAk1YiLcACgkQEwoGUlJjrt/hegCfTjwghUYjdQiSqagKEcln5cVy
xTcAn1g0uZvVYie2d5yh52l7gT4fE8ZL
=XmNU
-----END PGP SIGNATURE-----

--=-INaWAU3bI8a99kYlXIha--
