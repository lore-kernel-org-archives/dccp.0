From: Richard Sailer <richard_siegfried@systemli.org>
Date: Tue, 13 Oct 2020 18:59:50 +0000
Subject: Re: [PATCH 2/2] Revert "dccp: don't free ccid2_hc_tx_sock struct in dccp_disconnect()"
Message-Id: <bb2755d3-cb80-5761-f01f-4c6da9bd31c2@systemli.org>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="J1wNxwe2U3hUL6xUfMbG23kWMkDthUjal"
List-Id: <dccp.vger.kernel.org>
References: <20201013171849.236025-3-kleber.souza@canonical.com>
In-Reply-To: <20201013171849.236025-3-kleber.souza@canonical.com>
To: dccp@vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--J1wNxwe2U3hUL6xUfMbG23kWMkDthUjal
Content-Type: multipart/mixed; boundary="WxePmLM0IhiWSQnQjcpdYpcvAqMuNppWd";
 protected-headers="v1"
From: Richard Sailer <richard_siegfried@systemli.org>
To: Kleber Sacilotto de Souza <kleber.souza@canonical.com>,
 netdev@vger.kernel.org
Cc: Gerrit Renker <gerrit@erg.abdn.ac.uk>,
 "David S. Miller" <davem@davemloft.net>, Jakub Kicinski <kuba@kernel.org>,
 Thadeu Lima de Souza Cascardo <cascardo@canonical.com>,
 "Gustavo A. R. Silva" <gustavoars@kernel.org>,
 "Alexander A. Klimov" <grandmaster@al2klimov.de>,
 Kees Cook <keescook@chromium.org>, Eric Dumazet <edumazet@google.com>,
 Alexey Kodanev <alexey.kodanev@oracle.com>, dccp@vger.kernel.org,
 linux-kernel@vger.kernel.org
Message-ID: <bb2755d3-cb80-5761-f01f-4c6da9bd31c2@systemli.org>
Subject: Re: [PATCH 2/2] Revert "dccp: don't free ccid2_hc_tx_sock struct in
 dccp_disconnect()"
References: <20201013171849.236025-1-kleber.souza@canonical.com>
 <20201013171849.236025-3-kleber.souza@canonical.com>
In-Reply-To: <20201013171849.236025-3-kleber.souza@canonical.com>

--WxePmLM0IhiWSQnQjcpdYpcvAqMuNppWd
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable

On 13/10/2020 19:18, Kleber Sacilotto de Souza wrote:
> rom: Thadeu Lima de Souza Cascardo <cascardo@canonical.com>
>=20
> This reverts commit 2677d20677314101293e6da0094ede7b5526d2b1.
>=20
> This fixes an issue that after disconnect, dccps_hc_tx_ccid will still =
be
> kept, allowing the socket to be reused as a listener socket, and the cl=
oned
> socket will free its dccps_hc_tx_ccid, leading to a later use after fre=
e,
> when the listener socket is closed.
>=20
> This addresses CVE-2020-16119.
>=20
> Fixes: 2677d2067731 (dccp: don't free ccid2_hc_tx_sock struct in dccp_d=
isconnect())
> Reported-by: Hadar Manor
> Signed-off-by: Thadeu Lima de Souza Cascardo <cascardo@canonical.com>
> Signed-off-by: Kleber Sacilotto de Souza <kleber.souza@canonical.com>
> ---
Acked-by: Richard Sailer <richard_siegfried@systemli.org>


--WxePmLM0IhiWSQnQjcpdYpcvAqMuNppWd--

--J1wNxwe2U3hUL6xUfMbG23kWMkDthUjal
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCgAdFiEEBgAhuYrOnl9UC7I39kE5zAWb4eEFAl+F+ScACgkQ9kE5zAWb
4eH6sQf/Tqw4Q9r0PAI1c+stYzlcCikkYpFE33vnoG+SbiIQCBhB83rs/BxTNmxO
mKRJpzTswAQsqrnGRCrFGcazAUJKWqhAxC6N+g0nZCDZuSVfSAAh5e6ayHP4HLJw
SW0daEUNYkdGvYkl5Dhom35pjziR+m1RTWE2EXesA4vMpOG+WBsNyzZ1tmDDb/Ad
nYQNfRZOZjXpFWwGg4yVl9q0kddB5RYxkYXHH1gRsMK8uvJRjGXmaj/XdNlcdyLQ
BfwUINi94v9arFQZwnjtiKDTkpN5YaD4GLPT+ffQLcBc6P6ixa6CcCCG0khkjLu5
dfBZ8s+blxKb/APl8JUsI6Ud9YMLVw==
=+HsJ
-----END PGP SIGNATURE-----

--J1wNxwe2U3hUL6xUfMbG23kWMkDthUjal--
