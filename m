From: Samuel Jero <sj323707@ohio.edu>
Date: Sun, 26 Dec 2010 19:50:24 +0000
Subject: Sequence Number Validation Bug Fixes 2/2
Message-Id: <1293393024.22785.1.camel@jero-laptop>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="=-fYSaIcWoqAQ5YnbcTIBb"
List-Id: <dccp.vger.kernel.org>
To: dccp@vger.kernel.org

--=-fYSaIcWoqAQ5YnbcTIBb
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Currently dccp_check_seqno allows any valid packet to update the
Greatest Sequence Number Received, even if that packet's sequence number
is less than the current GSR. This patch adds a check to make sure that
the new packet's sequence number is greater than GSR.

>>>>>>>>>>>>>>>>>>>>>>>>>  Patch Follows <<<<<<<<<<<<<<<<<<<<<<<<<<
diff --git a/net/dccp/input.c b/net/dccp/input.c
--- a/net/dccp/input.c
+++ b/net/dccp/input.c
@@ -252,7 +253,10 @@ static int dccp_check_seqno(struct sock *sk, struct
sk_buff *skb)
if (between48(seqno, lswl, dp->dccps_swh) &&
    (ackno =3D=3D DCCP_PKT_WITHOUT_ACK_SEQ ||
     between48(ackno, lawl, dp->dccps_awh))) {
- dccp_update_gsr(sk, seqno);
+
+ if(after48(seqno, dp->dccps_gsr)){
+ dccp_update_gsr(sk, seqno);
+ }

if (dh->dccph_type !=3D DCCP_PKT_SYNC &&
    ackno !=3D DCCP_PKT_WITHOUT_ACK_SEQ &&=20

--=-fYSaIcWoqAQ5YnbcTIBb
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEABECAAYFAk0XnHwACgkQEwoGUlJjrt+bGQCfRmo5eBOPGL2zkixEbdgQ6fIq
M7cAoLq4aBofcXI/3KkWJhfION/kSM2u
=heP/
-----END PGP SIGNATURE-----

--=-fYSaIcWoqAQ5YnbcTIBb--
