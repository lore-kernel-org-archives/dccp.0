From: Samuel Jero <sj323707@ohio.edu>
Date: Sun, 26 Dec 2010 19:45:17 +0000
Subject: Sequence Number Validation Bug Fixes 1/2
Message-Id: <1293392717.22785.0.camel@jero-laptop>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="=-CsjK/ZwG2O7KKdCUOubn"
List-Id: <dccp.vger.kernel.org>
To: dccp@vger.kernel.org

--=-CsjK/ZwG2O7KKdCUOubn
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Currently dccp_check_seqno returns 0 (indicating a valid packet) if the
acknowledgment number is out of bounds and the sync that RFC 4340
mandates at this point is currently being rate-limited. This function
should return -1, indicating an invalid packet.

>>>>>>>>>>>>>>>>>>>>>>>>>  Patch Follows <<<<<<<<<<<<<<<<<<<<<<<<<<
diff --git a/net/dccp/input.c b/net/dccp/input.c
--- a/net/dccp/input.c
+++ b/net/dccp/input.c
@@ -275,8 +279,10 @@ static int dccp_check_seqno(struct sock *sk, struct
sk_buff *skb)
*   at most 1 / (dccp_sync_rate_limit * HZ) Syncs per second.
*/
if (time_before(now, (dp->dccps_rate_last +
-       sysctl_dccp_sync_ratelimit)))
- return 0;
+       sysctl_dccp_sync_ratelimit))){
+ return -1;
+ }
+

DCCP_WARN("Step 6 failed for %s packet, "
  "(LSWL(%llu) <=3D P.seqno(%llu) <=3D S.SWH(%llu)) and "



--=-CsjK/ZwG2O7KKdCUOubn
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEABECAAYFAk0Xm0kACgkQEwoGUlJjrt85sQCgnTvqqxSBAwEmGH7yuONFeGe8
+GQAn3mN57ma2IWaQeaBbQiVNQxnD66I
=pUXd
-----END PGP SIGNATURE-----

--=-CsjK/ZwG2O7KKdCUOubn--
