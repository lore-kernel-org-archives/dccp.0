From: Samuel Jero <sj323707@ohio.edu>
Date: Sun, 13 Mar 2011 19:50:44 +0000
Subject: Re: [Patch 1/1] dccp: CCID2 increment cwnd correctly
Message-Id: <1300045844.31664.121.camel@jero-laptop>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="=-pGDwk8n8kMZhrM2aPJlL"
List-Id: <dccp.vger.kernel.org>
References: <1299562278.7569.82.camel@jero-laptop>
In-Reply-To: <1299562278.7569.82.camel@jero-laptop>
To: dccp@vger.kernel.org

--=-pGDwk8n8kMZhrM2aPJlL
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

> | My fix is simply to change that test for tx_packets_acked greater than
> | or equal to two in slow start.
> |=20
> Excellent catch, thank you very much. This has also been added to the tes=
t tree.
>=20
> Would you be ok with me reusing the commit message as a comment - or if y=
ou
> like, you can also send an update.

I don't think that a comment is really needed here. I don't see that
anyone looking at this code at some point in the future would say "why
did they use >=3D there?" Particularly, since the test (in congestion
avoidance state) four lines later also uses >=3D without explanation.

I would consider using >=3D in this situation (testing for a value of an
incrementing variable) to be good coding practice even if it wasn't
strictly necessary.

Samuel Jero
Internetworking Research Group
Ohio University

--=-pGDwk8n8kMZhrM2aPJlL
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEABECAAYFAk19IA4ACgkQEwoGUlJjrt9XWwCfeyaNxhn0I1TEBi3DVeOWy+da
iSgAoJNdHUYH7MQVXD95rwxNLpJOb5rW
=z9tj
-----END PGP SIGNATURE-----

--=-pGDwk8n8kMZhrM2aPJlL--
