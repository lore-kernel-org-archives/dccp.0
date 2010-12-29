From: Samuel Jero <sj323707@ohio.edu>
Date: Wed, 29 Dec 2010 04:07:12 +0000
Subject: Re: Sequence Number Validation Bug Fixes 2/2
Message-Id: <1293595632.22785.26.camel@jero-laptop>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="=-M8+XU1sAmopka1in6Z0D"
List-Id: <dccp.vger.kernel.org>
References: <1293393024.22785.1.camel@jero-laptop>
In-Reply-To: <1293393024.22785.1.camel@jero-laptop>
To: dccp@vger.kernel.org

--=-M8+XU1sAmopka1in6Z0D
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

This problem is, indeed, very similar to the November 23rd bug fix; in
fact, it was that bug fix that caused me to notice this problem.

The difference is that the November 23rd bug fix covers the Greatest
Acknowledgment Number Received; whereas, this bug fix covers the
Greatest Sequence Number Received.

On Tue, 2010-12-28 at 10:44 +0100, Gerrit Renker wrote:
> Thanks a lot for looking into this.
>=20
> I think the problem below is similar to or even covered by the bug fix
> submitted on 23th November (it is in net-2.6 but may not yet be in mainli=
ne):
>=20
> http://eden-feed.erg.abdn.ac.uk/cgi-bin/gitweb.cgi?p=3Ddccp_exp.git;a=3Dc=
ommitdiff;h=3D0ac78870220b6e0ac74dd9292bcfa7b18718babd
>=20
> I will have a look at the other patches, but it maybe "next year" until
> able to get back.
>=20
>=20
> Quoting Samuel Jero:
> | Currently dccp_check_seqno allows any valid packet to update the
> | Greatest Sequence Number Received, even if that packet's sequence numbe=
r
> | is less than the current GSR. This patch adds a check to make sure that
> | the new packet's sequence number is greater than GSR.
> |=20
> | >>>>>>>>>>>>>>>>>>>>>>>>>  Patch Follows <<<<<<<<<<<<<<<<<<<<<<<<<<
> | diff --git a/net/dccp/input.c b/net/dccp/input.c
> | --- a/net/dccp/input.c
> | +++ b/net/dccp/input.c
> | @@ -252,7 +253,10 @@ static int dccp_check_seqno(struct sock *sk, struc=
t
> | sk_buff *skb)
> | if (between48(seqno, lswl, dp->dccps_swh) &&
> |     (ackno =3D=3D DCCP_PKT_WITHOUT_ACK_SEQ ||
> |      between48(ackno, lawl, dp->dccps_awh))) {
> | - dccp_update_gsr(sk, seqno);
> | +
> | + if(after48(seqno, dp->dccps_gsr)){
> | + dccp_update_gsr(sk, seqno);
> | + }
> |=20
> | if (dh->dccph_type !=3D DCCP_PKT_SYNC &&
> |     ackno !=3D DCCP_PKT_WITHOUT_ACK_SEQ &&=20
>=20

--=-M8+XU1sAmopka1in6Z0D
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEABECAAYFAk0as+QACgkQEwoGUlJjrt9QaACghdKHreEImkmIcmkU7O9JbIN5
0Z8An1QlOBxqsKX8aHexjhbuMGitTJZa
=6yfi
-----END PGP SIGNATURE-----

--=-M8+XU1sAmopka1in6Z0D--
