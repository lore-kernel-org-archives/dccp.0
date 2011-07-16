From: Samuel Jero <sj323707@ohio.edu>
Date: Sat, 16 Jul 2011 17:50:15 +0000
Subject: Re: [PATCH 04/07] dccp ccid-2: use feature-negotiation to report
Message-Id: <4E21CF57.5080104@ohio.edu>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------enig3CE476A1FA998A9A8D005B46"
List-Id: <dccp.vger.kernel.org>
References: <1310650955-5159-5-git-send-email-gerrit@erg.abdn.ac.uk>
In-Reply-To: <1310650955-5159-5-git-send-email-gerrit@erg.abdn.ac.uk>
To: dccp@vger.kernel.org

--------------enig3CE476A1FA998A9A8D005B46
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

This patch also looks good. You have my Signed-off-by.
The rest of the set looks good also.

On 07/14/2011 09:42 AM, Gerrit Renker wrote:
> This uses the new feature-negotiation framework to signal Ack Ratio cha=
nges,
> as required by RFC 4341, sec. 6.1.2.
>=20
> This raises some problems for CCID-2 since it can at the moment not cop=
e
> gracefully with Ack Ratio of e.g. 2. A FIXME has thus been added which
> reverts to the existing policy of bypassing the Ack Ratio sysctl.
>=20
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
> Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>

Signed-off-by: Samuel Jero <sj323707@ohio.edu>


Samuel Jero
Internetworking Research Group
Ohio University


--------------enig3CE476A1FA998A9A8D005B46
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAk4hz1wACgkQEwoGUlJjrt+HBwCeNWJCewxDuOwD2v+2SA8fNRkE
Yd8An3/ySz/o4gCEzb5A9QtAfo5ce/2h
=cwMb
-----END PGP SIGNATURE-----

--------------enig3CE476A1FA998A9A8D005B46--
