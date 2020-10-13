From: Richard Sailer <richard_siegfried@systemli.org>
Date: Tue, 13 Oct 2020 18:58:34 +0000
Subject: Re: [PATCH 1/2] dccp: ccid: move timers to struct dccp_sock
Message-Id: <0de6cc66-8825-6631-843e-68fc9e2c1517@systemli.org>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="KHVaNnR0CtdkaZCgAsBVhWbXcrEqCZBOz"
List-Id: <dccp.vger.kernel.org>
References: <20201013171849.236025-2-kleber.souza@canonical.com>
In-Reply-To: <20201013171849.236025-2-kleber.souza@canonical.com>
To: dccp@vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--KHVaNnR0CtdkaZCgAsBVhWbXcrEqCZBOz
Content-Type: multipart/mixed; boundary="dfjn9C3XkBZ9ZjEm6mKvr0DLGL7w3liEv";
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
Message-ID: <0de6cc66-8825-6631-843e-68fc9e2c1517@systemli.org>
Subject: Re: [PATCH 1/2] dccp: ccid: move timers to struct dccp_sock
References: <20201013171849.236025-1-kleber.souza@canonical.com>
 <20201013171849.236025-2-kleber.souza@canonical.com>
In-Reply-To: <20201013171849.236025-2-kleber.souza@canonical.com>

--dfjn9C3XkBZ9ZjEm6mKvr0DLGL7w3liEv
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable

On 13/10/2020 19:18, Kleber Sacilotto de Souza wrote:
> From: Thadeu Lima de Souza Cascardo <cascardo@canonical.com>
>=20
> When dccps_hc_tx_ccid is freed, ccid timers may still trigger. The reas=
on
> del_timer_sync can't be used is because this relies on keeping a refere=
nce
> to struct sock. But as we keep a pointer to dccps_hc_tx_ccid and free t=
hat
> during disconnect, the timer should really belong to struct dccp_sock.
>=20
> This addresses CVE-2020-16119.
>=20
> Fixes: 839a6094140a (net: dccp: Convert timers to use timer_setup())
> Signed-off-by: Thadeu Lima de Souza Cascardo <cascardo@canonical.com>
> Signed-off-by: Kleber Sacilotto de Souza <kleber.souza@canonical.com>

Acked-bd: Richard Sailer <richard_siegfried@systemli.org>

Implementation and concept looks fine to me


--dfjn9C3XkBZ9ZjEm6mKvr0DLGL7w3liEv--

--KHVaNnR0CtdkaZCgAsBVhWbXcrEqCZBOz
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCgAdFiEEBgAhuYrOnl9UC7I39kE5zAWb4eEFAl+F+N8ACgkQ9kE5zAWb
4eH0WQf/UWTTCBzTGhg11Zme2bEngbGDoD/xYPUZ8TvPD7cXCoq0WGSVG9yqaTc1
vXwH1+jvNoJHQ7NvXOoUEe1fGmgNVdFNIw5RzEy/9Oi8rukTpvjloFCproonNeNs
mVAS95hbRHKho+NG+MmtR3yuH52SLtgtCdn64lJjAaNeX1oWGbUNwSK7TNY9Wrjj
ubteuQz3mFOFyca/V4xJZU58jz5Ikp420w/UdQGGtmUf133L3rZxDrT0ilKkZEiS
eeDfKRDQlkBbCvOlkuG6dER/nPUF0in8n1Ci6Jycwk2gsMIKSt3La178e3di6NHB
zdVms9QK+dASFjYym7NaXmjTjXS+cQ==
=WF3A
-----END PGP SIGNATURE-----

--KHVaNnR0CtdkaZCgAsBVhWbXcrEqCZBOz--
