From: Samuel Jero <sj323707@ohio.edu>
Date: Mon, 14 Feb 2011 01:46:58 +0000
Subject: [PATCH 4/4] dccp: Enable the Ack Ratio Feature but keep CCID2 Ack
Message-Id: <1297648018.9816.147.camel@jero-laptop>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="=-JpP92hA22Q5g7w6RZs76"
List-Id: <dccp.vger.kernel.org>
To: dccp@vger.kernel.org

--=-JpP92hA22Q5g7w6RZs76
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

In order to effectively utilize Patch 1 ("Prevent Congestion Window >
Sequence Window"), we need the Ack Ratio Feature. However, this feature
has been disabled because the CCID2 Ack Congestion Control code is so
broken that it was causing major problems.
This patch enables the Ack Ratio Feature, but disables sending the
feature because of the Ack Congestion Control. This allows us to utilize
the Ack Ratio, but prevents the problems with broken Ack Congestion
Control.

---=20
Signed-off-by: Samuel Jero
diff --git a/net/dccp/ccids/ccid2.c b/net/dccp/ccids/ccid2.c
index 8f35c36..ae7e332 100644
--- a/net/dccp/ccids/ccid2.c
+++ b/net/dccp/ccids/ccid2.c
@@ -507,8 +507,11 @@ static void ccid2_hc_tx_packet_recv(struct sock *sk, s=
truct sk_buff *skb)
 			if (hc->tx_rpdupack >=3D NUMDUPACK) {
 				hc->tx_rpdupack =3D -1; /* XXX lame */
 				hc->tx_rpseq    =3D 0;
-
+#ifdef __CCID2_COPES_GRACEFULLY_WITH_ACK_CONGESTION_CONTROL__
+				/* FIXME: Ack Congestion Control is broken;
+				it doesn't change the ack ratio correctly.*/
 				ccid2_change_l_ack_ratio(sk, 2 * dp->dccps_l_ack_ratio);
+#endif
 			}
 		}
 	}
diff --git a/net/dccp/feat.c b/net/dccp/feat.c
index 6f2bc96..b0ff279 100644
--- a/net/dccp/feat.c
+++ b/net/dccp/feat.c
@@ -86,18 +86,6 @@ static int dccp_hdlr_ecn(struct sock *sk, u64 ecn_incapa=
ble, bool rx)
=20
 static int dccp_hdlr_ack_ratio(struct sock *sk, u64 ratio, bool rx)
 {
-#ifndef __CCID2_COPES_GRACEFULLY_WITH_DYNAMIC_ACK_RATIO_UPDATES__
-	/*
-	 * FIXME: This is required until several problems in the CCID-2 code are
-	 * resolved. The CCID-2 code currently does not cope well; using dynamic
-	 * Ack Ratios greater than 1 caused instabilities. These were manifest
-	 * in hangups and long RTO timeouts (1...3 seconds). Until this has been
-	 * stabilised, it is safer not to activate dynamic Ack Ratio changes.
-	 */
-	dccp_pr_debug("Not changing %s Ack Ratio from 1 to %u\n",
-		      rx ? "RX" : "TX", (u16)ratio);
-	ratio =3D 1;
-#endif
 	if (rx)
 		dccp_sk(sk)->dccps_r_ack_ratio =3D ratio;
 	else


--=-JpP92hA22Q5g7w6RZs76
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEABECAAYFAk1YiYoACgkQEwoGUlJjrt+TEgCgoO1tqG4yNhRczuHwjMqDJHUK
IuQAn3XAoEnHvu4Qt8bz2uXjquXoZYrl
=G5r+
-----END PGP SIGNATURE-----

--=-JpP92hA22Q5g7w6RZs76--
