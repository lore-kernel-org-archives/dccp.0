From: Marc Kleine-Budde <mkl@pengutronix.de>
Date: Thu, 16 Mar 2023 15:57:58 +0000
Subject: Re: [RFC PATCH 28/28] sock: Remove ->sendpage*() in favour of sendmsg(MSG_SPLICE_PAGES)
Message-Id: <20230316155758.5ylpybqjma7x4lbs@pengutronix.de>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="km5oeoth2y26yqyc"
List-Id: <dccp.vger.kernel.org>
References: <20230316152618.711970-29-dhowells@redhat.com>
In-Reply-To: <20230316152618.711970-29-dhowells@redhat.com>
To: dccp@vger.kernel.org


--km5oeoth2y26yqyc
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On 16.03.2023 15:26:18, David Howells wrote:
> [!] Note: This is a work in progress.  At the moment, some things won't
>     build if this patch is applied.  nvme, kcm, smc, tls.
>=20
> Remove ->sendpage() and ->sendpage_locked().  sendmsg() with
> MSG_SPLICE_PAGES should be used instead.  This allows multiple pages and
> multipage folios to be passed through.
>=20
> Signed-off-by: David Howells <dhowells@redhat.com>

> cc: linux-can@vger.kernel.org

Acked-by: Marc Kleine-Budde <mkl@pengutronix.de> # for net/can

Marc

--=20
Pengutronix e.K.                 | Marc Kleine-Budde           |
Embedded Linux                   | https://www.pengutronix.de  |
Amtsgericht Hildesheim, HRA 2686 | Fax:   +49-5121-206917-5555 |

--km5oeoth2y26yqyc
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEzBAABCgAdFiEEDs2BvajyNKlf9TJQvlAcSiqKBOgFAmQTPIMACgkQvlAcSiqK
BOj6JAgAtfBV5yq+uNvtDfdNTDCgUnr0pkrsEqo0Ygt0A84TUlJF1K9QFkFTlvFo
NEtegJFeDvbE8EmvRgOnpoTRcMQwDClaw5c7O7TquCr3SEAcXECesFYUVLWR7hsf
Mk3DzSWUNIqMeSUOAEPBPfWNGGQWdjut5IQHdhuIs2/irjgsb5GZJ27rYyV9F/+l
daE1Ac6RGnKq9zV/UszZ7AbfKA7bI9TVioWBVmIFCQZeWJprHq5rD0LTH6+QjdyQ
5AdUTjTbZ/YRTjr4KQQkISfoq8oMC/zVENiagYZ89SGTbciIaCeqBpvdgUVKTob6
2Uoo/o+yUY90Dy8JPw9/gLSsthDGaw==
=IhKV
-----END PGP SIGNATURE-----

--km5oeoth2y26yqyc--
