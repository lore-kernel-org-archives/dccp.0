From: Samuel Jero <sj323707@ohio.edu>
Date: Mon, 14 Feb 2011 01:44:37 +0000
Subject: [PATCH 2/4] dccp: Send Confirm Options Only Once
Message-Id: <1297647877.9816.145.camel@jero-laptop>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="=-xXmVLq1SqxRO4dC9fbpH"
List-Id: <dccp.vger.kernel.org>
To: dccp@vger.kernel.org

--=-xXmVLq1SqxRO4dC9fbpH
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Remove Feature Negotiation Confirm Options from the list of options to
send after they are sent once because such options are NOT supposed to
be retransmitted and are ONLY supposed to be sent in response to a
Change Option (RFC 4340 6.2).

---

Signed-off-by: Samuel Jero
diff --git a/net/dccp/feat.c b/net/dccp/feat.c
index 6f2bc96..ab85f23 100644
--- a/net/dccp/feat.c
+++ b/net/dccp/feat.c
@@ -690,11 +690,18 @@ int dccp_feat_insert_opts(struct dccp_sock *dp, struc=
t dccp_request_sock *dreq,
 			return -1;
 		if (pos->needs_mandatory && dccp_insert_option_mandatory(skb))
 			return -1;
-		/*
-		 * Enter CHANGING after transmitting the Change option (6.6.2).
-		 */
-		if (pos->state =3D=3D FEAT_INITIALISING)
-			pos->state =3D FEAT_CHANGING;
+
+		if (opt =3D=3D DCCPO_CONFIRM_R || opt =3D=3D DCCPO_CONFIRM_L) {
+			/*Confirms don't get retransmitted (6.6.3)*/
+			dccp_feat_list_pop(pos);
+		} else {
+			/*
+			 * Enter CHANGING after transmitting
+			 * the Change option (6.6.2).
+			 */
+			if (pos->state =3D=3D FEAT_INITIALISING)
+				pos->state =3D FEAT_CHANGING;
+		}
 	}
 	return 0;
 }


--=-xXmVLq1SqxRO4dC9fbpH
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEABECAAYFAk1YiQEACgkQEwoGUlJjrt+RZwCgrsRTyXShRmlR+hJHxnLS4+Fc
YUEAn3BKOnn2tFOR+e3d1OWX2Fde4SEq
=8AHe
-----END PGP SIGNATURE-----

--=-xXmVLq1SqxRO4dC9fbpH--
