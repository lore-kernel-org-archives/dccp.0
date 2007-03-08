From: Andre Noll <maan@systemlinux.org>
Date: Thu, 08 Mar 2007 08:40:14 +0000
Subject: Re: kernel BUG at kernel/timer.c:407!
Message-Id: <20070308084014.GA25100@skl-net.de>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="GvXjxJ+pjyke8COw"
List-Id: <dccp.vger.kernel.org>
References: <20070305143240.GW22572@skl-net.de>
In-Reply-To: <20070305143240.GW22572@skl-net.de>
To: dccp@vger.kernel.org


--GvXjxJ+pjyke8COw
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On 10:24, Andre Noll wrote:
> > Can you confirm that, when the `culprit' patch is reverted (as per
> > the first email), the bug disappears?
>=20
> I double-checked this before sending the first mail, but I also will
> try the patch you sent today and report tomorrow.

I now can confirm that also with 2.6.21-rc3 your patch makes the bug
go away, so feel free to add my Signed-Off.

Thanks
Andre
--=20
The only person who always got his work done by Friday was Robinson Crusoe

--GvXjxJ+pjyke8COw
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.1 (GNU/Linux)

iD8DBQFF78vuWto1QDEAkw8RAiHMAJ9baIQIbM8XPEWjrZlDE8GdkTXM9wCdEpfs
h0ZtogZOojZY0kOgo2QBI/A=
=cnnR
-----END PGP SIGNATURE-----

--GvXjxJ+pjyke8COw--
