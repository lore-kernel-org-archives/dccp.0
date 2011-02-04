From: Alexander Zimmermann <alexander.zimmermann@comsys.rwth-aachen.de>
Date: Fri, 04 Feb 2011 08:38:34 +0000
Subject: Re: [PATCH] tcp: Increase the initial congestion window to 10.
Message-Id: <C9A0E70E-D1DB-45CF-ABB1-8CF9A9D03144@comsys.rwth-aachen.de>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="Apple-Mail-9-673935302"
List-Id: <dccp.vger.kernel.org>
References: <20110202.170750.229739784.davem@davemloft.net>
In-Reply-To: <20110202.170750.229739784.davem@davemloft.net>
To: dccp@vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--Apple-Mail-9-673935302
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain; charset=us-ascii

Hi David,

Am 03.02.2011 um 02:07 schrieb David Miller:

>=20
> Signed-off-by: David S. Miller <davem@davemloft.net>
> ---
>=20
> I've left the DCCP code to keep using RFC3390 logic, if they
> wish to adopt this change in their code they can do so by
> simply deleting the rfc33390_bytes_to_packets() function and
> using TCP_INIT_CWND in their assignment.
>=20
> include/net/tcp.h      |   12 +++---------
> net/dccp/ccids/ccid2.c |    9 +++++++++
> net/ipv4/tcp_input.c   |    2 +-
> 3 files changed, 13 insertions(+), 10 deletions(-)
>=20
> diff --git a/include/net/tcp.h b/include/net/tcp.h
> index 9179111..7118668 100644
> --- a/include/net/tcp.h
> +++ b/include/net/tcp.h
> @@ -196,6 +196,9 @@ extern void tcp_time_wait(struct sock *sk, int =
state, int timeo);
> /* TCP thin-stream limits */
> #define TCP_THIN_LINEAR_RETRIES 6       /* After 6 linear retries, do =
exp. backoff */
>=20

Could you add a reference to draft?

> +/* TCP initial congestion window */
> +#define TCP_INIT_CWND		10
> +
> extern struct inet_timewait_death_row tcp_death_row;
>=20
> /* sysctl variables for tcp */
> @@ -799,15 +802,6 @@ static inline __u32 tcp_current_ssthresh(const =
struct sock *sk)
> /* Use define here intentionally to get WARN_ON location shown at the =
caller */
> #define tcp_verify_left_out(tp)	WARN_ON(tcp_left_out(tp) > =
tp->packets_out)
>=20
> -/*
> - * Convert RFC 3390 larger initial window into an equivalent number =
of packets.
> - * This is based on the numbers specified in RFC 5681, 3.1.
> - */
> -static inline u32 rfc3390_bytes_to_packets(const u32 smss)
> -{
> -	return smss <=3D 1095 ? 4 : (smss > 2190 ? 2 : 3);
> -}
> -
> extern void tcp_enter_cwr(struct sock *sk, const int set_ssthresh);
> extern __u32 tcp_init_cwnd(struct tcp_sock *tp, struct dst_entry =
*dst);
>=20



--Apple-Mail-9-673935302
content-type: application/pgp-signature; x-mac-type=70674453;
	name=PGP.sig
content-description: Signierter Teil der Nachricht
content-disposition: inline; filename=PGP.sig
content-transfer-encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (Darwin)

iEYEARECAAYFAk1LuwsACgkQdyiq39b9uS57SQCfUU149QrgiJaqGMuPmtBHFk9j
0ukAoJQvAvChRj/W9qLSc0GCifwnxr2b
=TdpG
-----END PGP SIGNATURE-----

--Apple-Mail-9-673935302--
