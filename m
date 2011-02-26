From: Samuel Jero <sj323707@ohio.edu>
Date: Sat, 26 Feb 2011 02:05:39 +0000
Subject: Re: [PATCH 1/4] dccp: Prevent Congestion Window > Sequence Window
Message-Id: <1298685939.11418.58.camel@jero-laptop>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="=-IJrqPo7UJpU4TdFmSfhQ"
List-Id: <dccp.vger.kernel.org>
References: <1297647802.9816.144.camel@jero-laptop>
In-Reply-To: <1297647802.9816.144.camel@jero-laptop>
To: dccp@vger.kernel.org

--=-IJrqPo7UJpU4TdFmSfhQ
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Add a check to prevent CCID 2 from increasing the Congestion Window
greater than the Sequence Window.

When the congestion window becomes bigger than the sequence window CCID
2 will attempt to keep more data in the network than the DCCP sequence
window code considers possible. This results in the sequence window code
issuing a sync, thereby inducing needless overhead. Further, if this
occurs at the sender, CCID 2 will never detect the problem because th
Acks it receives will indicate no losses. I have seen this cause a drop
of 1/3rd in throughput for a connection.

Also add code to adjust the sequence window to be about 5 times the
number of packets in the network (RFC 4340 7.5.2) and to adjust the Ack
Ratio so that the remote sequence window will hold about 5 times the
number of packets in the network. This allows the congestion window to
increase correctly without being limited by the sequence window.


---=20
Signed-off-by: Samuel Jero
diff --git a/net/dccp/ccids/ccid2.c b/net/dccp/ccids/ccid2.c
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
@@ -418,17 +468,37 @@ static void ccid2_new_ack(struct sock *sk, struct cci=
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
+	if ((hc->tx_cwnd < dp->dccps_l_seq_win) &&
+				(r_seq_used < dp->dccps_r_seq_win)) {
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
+	/*
+	 * Adjust the local sequence window and the ack ratio to allow about
+	 * 5 times the number of packets in the network (RFC 4340 7.5.2)
+	 */
+	if (r_seq_used*CCID2_WIN_CHANGE_FACTOR >=3D dp->dccps_r_seq_win)
+		ccid2_change_l_ack_ratio(sk, dp->dccps_l_ack_ratio*2);
+	else if (r_seq_used*CCID2_WIN_CHANGE_FACTOR < (dp->dccps_r_seq_win/2))
+		ccid2_change_l_ack_ratio(sk, dp->dccps_l_ack_ratio/2 ? : 1U);
+
+	if (hc->tx_cwnd*CCID2_WIN_CHANGE_FACTOR >=3D dp->dccps_l_seq_win)
+			ccid2_change_l_seq_window(sk, dp->dccps_l_seq_win*2);
+	else if (hc->tx_cwnd*CCID2_WIN_CHANGE_FACTOR < (dp->dccps_l_seq_win/2))
+			ccid2_change_l_seq_window(sk, dp->dccps_l_seq_win/2);
+
 	/*
 	 * FIXME: RTT is sampled several times per acknowledgment (for each
 	 * entry in the Ack Vector), instead of once per Ack (as in TCP SACK).
diff --git a/net/dccp/ccids/ccid2.h b/net/dccp/ccids/ccid2.h
--- a/net/dccp/ccids/ccid2.h
+++ b/net/dccp/ccids/ccid2.h
@@ -43,6 +43,12 @@ struct ccid2_seq {
 #define CCID2_SEQBUF_LEN 1024
 #define CCID2_SEQBUF_MAX 128
=20
+/*
+ * Multiple of congestion window to keep the sequence window at
+ * (RFC 4340 7.5.2)
+ */
+#define CCID2_WIN_CHANGE_FACTOR 5
+
 /**
  * struct ccid2_hc_tx_sock - CCID2 TX half connection
  * @tx_{cwnd,ssthresh,pipe}: as per RFC 4341, section 5


--=-IJrqPo7UJpU4TdFmSfhQ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEABECAAYFAk1oX+8ACgkQEwoGUlJjrt8vOQCfSoF0zpTr7M9dXPhbjF6aZBor
ydMAoKm7QSiLo8XhUOhGWlv0CTZ2kTm4
=p+Yn
-----END PGP SIGNATURE-----

--=-IJrqPo7UJpU4TdFmSfhQ--
