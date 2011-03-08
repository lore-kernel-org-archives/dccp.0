From: Samuel Jero <sj323707@ohio.edu>
Date: Tue, 08 Mar 2011 05:31:18 +0000
Subject: [Patch 1/1] dccp: CCID2 increment cwnd correctly
Message-Id: <1299562278.7569.82.camel@jero-laptop>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="=-lXUm5HGgtt2iKcManAfV"
List-Id: <dccp.vger.kernel.org>
To: dccp@vger.kernel.org

--=-lXUm5HGgtt2iKcManAfV
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

This patch fixes an issue where CCID2 will not to increase the
congestion window for numerous RTTs after an idle period, application
limited period, or a loss once the algorithm is in congestion avoidance.

What happens is that when CCID2 is in congestion avoidance mode it will
increase hc->tx_packets_acked by one for every packet and will increment
cwnd every cwnd packets. However, if there is now an idle period in the
connection, cwnd will be reduced, possibly below the slow start
threshold. This will cause the connection to go into slow start.
However, in slow start CCID2 performs this test to increment cwnd every
second ack:
++hc->tx_packets_acked =3D=3D 2
Unfortunately, this will be incorrect, if cwnd previous to the idle
period was larger than 2 and if tx_packets_acked was close to cwnd. For
example: cwnd=3D50 and tx_packets_acked=3D45.

In this case, the current code, will increment tx_packets_acked until it
equals two, which will only be once tx_packets_acked (an unsigned 32bit
int) overflows.

My fix is simply to change that test for tx_packets_acked greater than
or equal to two in slow start.


---
Signed-off-by: Samuel Jero
diff --git a/net/dccp/ccids/ccid2.c b/net/dccp/ccids/ccid2.c
--- a/net/dccp/ccids/ccid2.c
+++ b/net/dccp/ccids/ccid2.c
@@ -440,7 +480,7 @@ static void ccid2_new_ack(struct sock *sk, struct ccid2=
_seq *seqp,
 	if (hc->tx_cwnd < dp->dccps_l_seq_win &&
 	    r_seq_used < dp->dccps_r_seq_win) {
 		if (hc->tx_cwnd < hc->tx_ssthresh) {
-			if (*maxincr > 0 && ++hc->tx_packets_acked =3D=3D 2) {
+			if (*maxincr > 0 && ++hc->tx_packets_acked >=3D 2) {
 				hc->tx_cwnd +=3D 1;
 				*maxincr    -=3D 1;
 				hc->tx_packets_acked =3D 0;

--=-lXUm5HGgtt2iKcManAfV
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEABECAAYFAk11vtoACgkQEwoGUlJjrt9m6QCfUmN1HakunBiARcU2iwTelq4g
SjwAnRJ3b6b8Z6etynOKtcIeH8h55Wn4
=w5e2
-----END PGP SIGNATURE-----

--=-lXUm5HGgtt2iKcManAfV--
