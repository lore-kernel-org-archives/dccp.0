From: Marc Kleine-Budde <mkl@pengutronix.de>
Date: Wed, 17 Apr 2019 09:59:55 +0000
Subject: Re: [PATCH net-next 1/3] net: rework SIOCGSTAMP ioctl handling
Message-Id: <4eabda4b-d08e-ae29-b3df-0971e909fe9c@pengutronix.de>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="oP6RuXvTEGF9Y54Th4EJnog3EsjFlvu8A"
List-Id: <dccp.vger.kernel.org>
References: <20180829130308.3504560-1-arnd@arndb.de>
In-Reply-To: <20180829130308.3504560-1-arnd@arndb.de>
To: dccp@vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--oP6RuXvTEGF9Y54Th4EJnog3EsjFlvu8A
Content-Type: multipart/mixed; boundary="bhFxmOk9TZicUAH3UPosBJuXCCeMCMkUw";
 protected-headers="v1"
From: Marc Kleine-Budde <mkl@pengutronix.de>
To: Arnd Bergmann <arnd@arndb.de>, "David S. Miller" <davem@davemloft.net>,
 Ralf Baechle <ralf@linux-mips.org>, Marcel Holtmann <marcel@holtmann.org>,
 Johan Hedberg <johan.hedberg@gmail.com>,
 Oliver Hartkopp <socketcan@hartkopp.net>,
 Gerrit Renker <gerrit@erg.abdn.ac.uk>, Alexander Aring
 <alex.aring@gmail.com>, Stefan Schmidt <stefan@datenfreihafen.org>,
 Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
 Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
 Vlad Yasevich <vyasevich@gmail.com>, Neil Horman <nhorman@tuxdriver.com>,
 Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
 Andrew Hendry <andrew.hendry@gmail.com>, Eric Dumazet <edumazet@google.com>,
 Willem de Bruijn <willemb@google.com>,
 Deepa Dinamani <deepa.kernel@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
 linux-hams@vger.kernel.org, linux-bluetooth@vger.kernel.org,
 linux-can@vger.kernel.org, dccp@vger.kernel.org, linux-wpan@vger.kernel.org,
 linux-sctp@vger.kernel.org, linux-x25@vger.kernel.org
Message-ID: <4eabda4b-d08e-ae29-b3df-0971e909fe9c@pengutronix.de>
Subject: Re: [PATCH net-next 1/3] net: rework SIOCGSTAMP ioctl handling
References: <20190416203620.539628-1-arnd@arndb.de>
In-Reply-To: <20190416203620.539628-1-arnd@arndb.de>

--bhFxmOk9TZicUAH3UPosBJuXCCeMCMkUw
Content-Type: text/plain; charset=utf-8
Content-Language: de-DE
Content-Transfer-Encoding: quoted-printable

On 4/16/19 10:32 PM, Arnd Bergmann wrote:
> The SIOCGSTAMP/SIOCGSTAMPNS ioctl commands are implemented by many
> socket protocol handlers, and all of those end up calling the same
> sock_get_timestamp()/sock_get_timestampns() helper functions, which
> results in a lot of duplicate code.
>=20
> With the introduction of 64-bit time_t on 32-bit architectures, this
> gets worse, as we then need four different ioctl commands in each
> socket protocol implementation.
>=20
> To simplify that, let's add a new .gettstamp() operation in
> struct proto_ops, and move ioctl implementation into the common
> sock_ioctl()/compat_sock_ioctl_trans() functions that these all go
> through.
>=20
> We can reuse the sock_get_timestamp() implementation, but generalize
> it so it can deal with both native and compat mode, as well as
> timeval and timespec structures.
>=20
> Acked-by: Stefan Schmidt <stefan@datenfreihafen.org>
> Link: https://lore.kernel.org/lkml/CAK8P3a038aDQQotzua_QtKGhq8O9n+rdiz2=
=3DWDCp82ys8eUT+A@mail.gmail.com/
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

For the CAN part:

Acked-by: Marc Kleine-Budde <mkl@pengutronix.de>

regards,
Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--bhFxmOk9TZicUAH3UPosBJuXCCeMCMkUw--

--oP6RuXvTEGF9Y54Th4EJnog3EsjFlvu8A
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCgAdFiEEmvEkXzgOfc881GuFWsYho5HknSAFAly2+RsACgkQWsYho5Hk
nSA+5Qf/TdRQd9Jb+CrEOmRTXkDOy+oG5Q4lOH8kTGLGuVcufVKYrWxNazF2WNAU
uiohTFCKRBHADN7QSPuJcj5bKF/zAva4tIOEI+P/E/kJKklBF0JwPc676SmkUaop
mMat6DD+JbjBkUVVGum0QxcuvTX870gX//xOhwjjEZDwx9nphQ0LJHas6t675WJY
/gM4YTaSzuGCMsh65dduYl3d2UG0a1X4S8JtOgoBniszfkJYDxd2TAhZdur/tCq6
C3WtdnLh3NvCFu6Q4HDaBrXqgtv0/n1pX0zko+TNiNv0ETTx8bbHztafQBR/xWIt
W2DtCx2TmAr9FxU5oK3tnc5OO9QiFg==
=MQJ6
-----END PGP SIGNATURE-----

--oP6RuXvTEGF9Y54Th4EJnog3EsjFlvu8A--
