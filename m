From: Samuel Jero <sj323707@ohio.edu>
Date: Sat, 26 Feb 2011 02:10:09 +0000
Subject: Re: [PATCH 3/4] dccp: Don't Reset On Confirm for Old NN Feature
Message-Id: <1298686209.11418.63.camel@jero-laptop>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="=-Nv0dygzvAzqYWSvT2kAN"
List-Id: <dccp.vger.kernel.org>
References: <1297647936.9816.146.camel@jero-laptop>
In-Reply-To: <1297647936.9816.146.camel@jero-laptop>
To: dccp@vger.kernel.org

--=-Nv0dygzvAzqYWSvT2kAN
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
--- a/net/dccp/feat.c
+++ b/net/dccp/feat.c
@@ -1347,10 +1337,14 @@ static u8 dccp_feat_handle_nn_established(struct so=
ck *sk, u8 mandatory, u8 opt,
 			return 0;
=20
 		fval.nn =3D dccp_decode_value_var(val, len);
-		if (fval.nn !=3D entry->val.nn) {
-			DCCP_WARN("Bogus Confirm for non-existing value\n");
-			goto fast_path_failed;
-		}
+		/*
+		 * Just ignore a value that doesn't match our current value.
+		 * If the option changes twice within two RTTs, then at least
+		 * one CONFIRM will be received for the old value after a
+		 * new CHANGE was sent.
+		 */
+		if (fval.nn !=3D entry->val.nn)
+			return 0;
=20
 		/* It has been confirmed - so remove the entry */
 		dccp_feat_list_pop(entry);


--=-Nv0dygzvAzqYWSvT2kAN
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEABECAAYFAk1oYP0ACgkQEwoGUlJjrt/LgQCeMN+5pJUTxHpxGN/3vrvlg3xY
QMYAnjaDYmZmarFMXrqy//LWk/tLhsb5
=Bwy7
-----END PGP SIGNATURE-----

--=-Nv0dygzvAzqYWSvT2kAN--
