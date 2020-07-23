From: Richard Sailer <richard_siegfried@systemli.org>
Date: Thu, 23 Jul 2020 10:28:08 +0000
Subject: Re: [PATCH net-next v5] net: dccp: Add SIOCOUTQ IOCTL support (send buffer fill)
Message-Id: <be70bbe3-4a8e-8a17-e808-1e1e668e3318@systemli.org>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="dZArhhPJOWWJ2NbiOMlJSpA9vDrVBNXJr"
List-Id: <dccp.vger.kernel.org>
References: <20200720160614.117090-1-richard_siegfried@systemli.org>
In-Reply-To: <20200720160614.117090-1-richard_siegfried@systemli.org>
To: dccp@vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--dZArhhPJOWWJ2NbiOMlJSpA9vDrVBNXJr
Content-Type: multipart/mixed; boundary="45hY1hWy9uB2bEIuP8oW0BTiuWwSgICEd";
 protected-headers="v1"
From: Richard Sailer <richard_siegfried@systemli.org>
To: David Miller <davem@davemloft.net>
Cc: gerrit@erg.abdn.ac.uk, dccp@vger.kernel.org, netdev@vger.kernel.org
Message-ID: <be70bbe3-4a8e-8a17-e808-1e1e668e3318@systemli.org>
Subject: Re: [PATCH net-next v5] net: dccp: Add SIOCOUTQ IOCTL support (send
 buffer fill)
References: <20200720160614.117090-1-richard_siegfried@systemli.org>
 <20200722.170112.664348766467297694.davem@davemloft.net>
In-Reply-To: <20200722.170112.664348766467297694.davem@davemloft.net>

--45hY1hWy9uB2bEIuP8oW0BTiuWwSgICEd
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable


>=20
> Applied, but I wonder if you'll also need something like tcp's SIOCOUTQ=
NSD?
>=20
A good question. SIOCOUTQNSD is not mentioned in man 7 tcp and I didn't
know and consider it. Now that I looked it up (bytes of unsent packets
in send buffer) maybe this patch's ioctl should be renamed SIOCOUTQNSD,
since it returns the byte count of unsent packets.

I'm undecided here, this is also the only of these ioctl's that makes
sense for DCCP since DCCP does not keep sent but un-acked packets so
SIOCOUTQ does not exist for DCCP. Or SIOCOUTQ and SIOCOUTQNSD are the
same for DCCP, that's a viewpoint question. And it's anyhow correctly
documented in dccp.rst, it's about unsent packets.

So I'm undecided here, should I resend my patch renamed to SIOCOUTQNSD?

-- Richard


--45hY1hWy9uB2bEIuP8oW0BTiuWwSgICEd--

--dZArhhPJOWWJ2NbiOMlJSpA9vDrVBNXJr
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCgAdFiEEBgAhuYrOnl9UC7I39kE5zAWb4eEFAl8ZZjgACgkQ9kE5zAWb
4eE7Xwf/e1lQO8XLn845lLFjA7Wm3W+kC+oAWSlNrO6jL4RZDsGW/C9tbIYnxIle
GSV1Lky4PzNiJD1pKaBJyA1XtkGEE5yZZ20wcVG1K5wuO0S0weAlhiR/JFc9kaDj
e/ycFkSQFtLzE0aAe8WmAHts53o6XwohZBEGV2Y8obruwANRbV0wSq5eeaLiKjSj
gGkYl7L7gnuwr2Kqv+4tWE56RlgzKv39EoT/AojJSrgAWCWolpi45MyJzABu98Hs
C2tQzn8F7+ilnTF/JZrT4fs8mHYqrnnnkxqYAzKD6MNcufnewFVXmy69YlJk/jp5
tSg7sC5upiCdHYZ/a2E7dW/8+n/chg==
=hdou
-----END PGP SIGNATURE-----

--dZArhhPJOWWJ2NbiOMlJSpA9vDrVBNXJr--
