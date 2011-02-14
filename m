From: Samuel Jero <sj323707@ohio.edu>
Date: Mon, 14 Feb 2011 01:45:36 +0000
Subject: [PATCH 3/4] dccp: Don't Reset On Confirm for Old NN Feature Values
Message-Id: <1297647936.9816.146.camel@jero-laptop>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="=-EUt3nkHjB0CagwRTMoVb"
List-Id: <dccp.vger.kernel.org>
To: dccp@vger.kernel.org

--=-EUt3nkHjB0CagwRTMoVb
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

The Current DCCP code resets the connection when it encounters a Confirm
for an NN feature with a value that doesn't match the most recent Change
sent. However, this causes unneeded resets if an NN option changes twice
within two RTTs. Further, this would break on the multiple Change
options for a feature in one packet example in RFC4340 6.6.1.

This patch modifies the code to simply ignore such a Confirm Option.

---=20
Signed-off-by: Samuel Jero
diff --git a/net/dccp/feat.c b/net/dccp/feat.c
index 6f2bc96..e5c1bad 100644
--- a/net/dccp/feat.c
+++ b/net/dccp/feat.c
@@ -1347,10 +1347,8 @@ static u8 dccp_feat_handle_nn_established(struct soc=
k *sk, u8 mandatory, u8 opt,
 			return 0;
=20
 		fval.nn =3D dccp_decode_value_var(val, len);
-		if (fval.nn !=3D entry->val.nn) {
-			DCCP_WARN("Bogus Confirm for non-existing value\n");
-			goto fast_path_failed;
-		}
+		if (fval.nn !=3D entry->val.nn)
+			return 0;
=20
 		/* It has been confirmed - so remove the entry */
 		dccp_feat_list_pop(entry);


--=-EUt3nkHjB0CagwRTMoVb
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEABECAAYFAk1YiTsACgkQEwoGUlJjrt++bgCeKFBhd/rLfCRM+UcLhwaMzeRs
mKsAoJfToiFYok1ictZ4deIuxwwjCLsL
=IE39
-----END PGP SIGNATURE-----

--=-EUt3nkHjB0CagwRTMoVb--
