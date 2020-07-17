From: Richard Sailer <richard_siegfried@systemli.org>
Date: Fri, 17 Jul 2020 00:56:59 +0000
Subject: Re: [PATCH net-next v4] net: dccp: Add SIOCOUTQ IOCTL support (send buffer fill)
Message-Id: <a0b896e3-e422-4901-bfba-8634c0fe6f5e@systemli.org>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="iwNExoDH9BubZexnCqmw2B1b8dd8T0v3w"
List-Id: <dccp.vger.kernel.org>
References: <20200712225520.269542-1-richard_siegfried@systemli.org>
In-Reply-To: <20200712225520.269542-1-richard_siegfried@systemli.org>
To: dccp@vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--iwNExoDH9BubZexnCqmw2B1b8dd8T0v3w
Content-Type: multipart/mixed; boundary="tw1Sih1WHter9AROfY8v0CNwvu19ynKkd";
 protected-headers="v1"
From: Richard Sailer <richard_siegfried@systemli.org>
To: Jakub Kicinski <kuba@kernel.org>
Cc: gerrit@erg.abdn.ac.uk, davem@davemloft.net, dccp@vger.kernel.org,
 netdev@vger.kernel.org
Message-ID: <a0b896e3-e422-4901-bfba-8634c0fe6f5e@systemli.org>
Subject: Re: [PATCH net-next v4] net: dccp: Add SIOCOUTQ IOCTL support (send
 buffer fill)
References: <20200712225520.269542-1-richard_siegfried@systemli.org>
 <20200716125608.33a0589b@kicinski-fedora-pc1c0hjn.dhcp.thefacebook.com>
In-Reply-To: <20200716125608.33a0589b@kicinski-fedora-pc1c0hjn.dhcp.thefacebook.com>

--tw1Sih1WHter9AROfY8v0CNwvu19ynKkd
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable



On 16/07/2020 21:56, Jakub Kicinski wrote:
> On Mon, 13 Jul 2020 00:55:20 +0200 Richard Sailer wrote:
>> This adds support for the SIOCOUTQ IOCTL to get the send buffer fill
>> of a DCCP socket, like UDP and TCP sockets already have.
>>
>> Regarding the used data field: DCCP uses per packet sequence numbers,
>> not per byte, so sequence numbers can't be used like in TCP. sk_wmem_q=
ueued
>> is not used by DCCP and always 0, even in test on highly congested pat=
hs.
>> Therefore this uses sk_wmem_alloc like in UDP.
>>
>> Signed-off-by: Richard Sailer <richard_siegfried@systemli.org>
>=20
> Sorry for the late review
No problem, nothing compared to the information delays at university^^

>=20
>> diff --git a/Documentation/networking/dccp.rst b/Documentation/network=
ing/dccp.rst
>> index dde16be044562..74659da107f6b 100644
>> --- a/Documentation/networking/dccp.rst
>> +++ b/Documentation/networking/dccp.rst
>> @@ -192,6 +192,8 @@ FIONREAD
>>  	Works as in udp(7): returns in the ``int`` argument pointer the size=
 of
>>  	the next pending datagram in bytes, or 0 when no datagram is pending=
=2E
>> =20
>> +SIOCOUTQ
>> +  Returns the number of data bytes in the local send queue.
>=20
> FIONREAD uses tabs for indentation, it seems like a good idea to
> document the size of the argument (i.e. "returns in the ``int`` ...").

Agreed
>=20
>>  Other tunables
>>  =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>> diff --git a/net/dccp/proto.c b/net/dccp/proto.c
>> index c13b6609474b6..dab74e8a8a69b 100644
>> --- a/net/dccp/proto.c
>> +++ b/net/dccp/proto.c
>> @@ -375,6 +375,14 @@ int dccp_ioctl(struct sock *sk, int cmd, unsigned=
 long arg)
>>  		goto out;
>> =20
>>  	switch (cmd) {
>> +	case SIOCOUTQ: {
>> +		/* Using sk_wmem_alloc here because sk_wmem_queued is not used by D=
CCP and
>> +		 * always 0, comparably to UDP.
>> +		 */
>> +		int amount =3D sk_wmem_alloc_get(sk);
>> +		rc =3D put_user(amount, (int __user *)arg);
>=20
> checkpatch warns:
>=20
> WARNING: Missing a blank line after declarations
> #48: FILE: net/dccp/proto.c:383:
> +		int amount =3D sk_wmem_alloc_get(sk);
> +		rc =3D put_user(amount, (int __user *)arg);
>=20
> Could you please address that, and better still move the declaration of=

> "int amount" up to the function level and avoid the funky bracket aroun=
d
> the case statement altogether?

I found the funky braces disturbing too, but thought they were
convention, so happy to delete them.

Regarding "putting int amount at function level": well the problem is in
the other case statement is a unsigned long (and the pointer in
put_user() is (int __user *) ). I don't yet know if I can make that all
a simple int without losing correctness/security. I will send a v5 when
I figured that out.

Thanks,
-- Richard


--tw1Sih1WHter9AROfY8v0CNwvu19ynKkd--

--iwNExoDH9BubZexnCqmw2B1b8dd8T0v3w
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCgAdFiEEBgAhuYrOnl9UC7I39kE5zAWb4eEFAl8Q91sACgkQ9kE5zAWb
4eGCSwgAnCO+7iLPMRj1aJsj/wQPjZiBQVNW0Jn7RfWiLeaDre8cAdZVSbwGnGw9
+elrnxBq2BMJCHlYiop/YyAMGKQVNIdLyp2qhJpgu4O5yNlUi5aKt3WE1HXvpsA5
jJeYFt8Gs6MCx3vgJ4COVZbmjdAuxD342okaFCRholRJGiMMLtoW8a4+YoDKcqmt
NyH6qNll4w9D+mT6/2ZlvgeuYrJPtv10gXhx3Q+LM55y+T6kFFDDJoS+67CfrNHv
w7CzcBJDvFlweKin9elCytRD4Gn2b6JFJUZLbWEUwXGxGoCo01C61yyV6zZh14qc
yAfhAQWPRLKLDezvJa+AIs5o7wM/ag==
=KCXz
-----END PGP SIGNATURE-----

--iwNExoDH9BubZexnCqmw2B1b8dd8T0v3w--
