From: Joel Granados <j.granados@samsung.com>
Date: Wed, 21 Jun 2023 11:49:27 +0000
Subject: Re: [PATCH 06/11] sysctl: Add size to register_net_sysctl function
Message-Id: <20230621114927.woeidgxx5jhtchxt@localhost>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="xne6trb3st3pnm7t"
List-Id: <dccp.vger.kernel.org>
References: <20230621091000.424843-7-j.granados@samsung.com>
In-Reply-To: <20230621091000.424843-7-j.granados@samsung.com>
To: dccp@vger.kernel.org

--xne6trb3st3pnm7t
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Jun 21, 2023 at 01:49:54PM +0300, Dan Carpenter wrote:
> On Wed, Jun 21, 2023 at 12:47:30PM +0300, Dan Carpenter wrote:
> > The patchset doesn't include the actual interesting changes, just a
> > bunch of mechanical prep work.
> >=20
>=20
> I was wrong here, the patchset just hadn't all hit the mailing lists.
not even. It was that the patch got mangled by some error on my side.

> I can't apply this patchset to anything.  I tried linux-next, net, and
> net-next.  So it's hard to review.
All this applies cleanly to mcgrof's sysctl-next branch here
https://git.kernel.org/pub/scm/linux/kernel/git/mcgrof/linux.git/log/?h=3Ds=
ysctl-next

>=20
> It looks like ensure_safe_net_sysctl() never got update to use
> table_size...
Done. I realized this while checking out your other comments. thx.

>=20
> You could easily write a static checker test to print a warning any time
> that ->procname is checked for NULL.  I have attached a Smatch check.
> You would need to added to check_list.h and recompile.
Awesome!!!, I had been doing this with coccinelle, I'll recompile with
smatch and see if I get extra hits. Thx!
>=20
> net/sysctl_net.c:130 ensure_safe_net_sysctl() warn: checking ->procname '=
ent->procname'
Done. Will be available in V2

>=20
> regards,
> dan carpenter
>=20

Best
--=20

Joel Granados

--xne6trb3st3pnm7t
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQGzBAABCgAdFiEErkcJVyXmMSXOyyeQupfNUreWQU8FAmSS48UACgkQupfNUreW
QU8P6wv+JBI5ELQO0rQlbgdRdUTqyimzPcdhSxOT8QeXa/qKyYDEV+KhvzEMZap0
0yiZFvImIwiv6dp/2opPovNRg1qLPT6jIoadBpMtglkCwRcyEH9HCX77M+R75wnz
eGelorE8pyLVRRRfz0vIOe+cSOT3K3W6t+JeaaVpDKIUQk/5RNsirkOjC/499F+3
QphT45CRPGAdiVjtKnEmkiCYwBVu4w2WiZn6MgN8Poq8eS+g88bfq1X33HbbOrAE
+xgFe/74kvzkeOAQ25zYT1oQVslt4dkE7ypD3JY5TC7PaFIa4/bVSQ233awpvNgP
0gdYX5kqUjjS5kDE5Br2kToneRo8n4D8xO3Q/0uXjvqjonOmarRtfBXuxkIvfpTL
y4aAcmIcU4xLvQdYoETV+2vNqUfxaHzIlRukxzVIZNcRYU4FN2jUKjQv5fNf2frE
CGQ8KJwhsUjQVIkm5jyVdhxrw8AmWbzthNWUKJW82kxDAQ6AOJbZWb+C4HPQ+39P
70ZNs++G
=sqdF
-----END PGP SIGNATURE-----

--xne6trb3st3pnm7t--
