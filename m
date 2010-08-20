From: Ivo Calado <ivocalado@embedded.ufcg.edu.br>
Date: Fri, 20 Aug 2010 12:38:34 +0000
Subject: Re: dccp test-tree [Patch 1/1] ccid-3: use per-route min-RTO and/or
Message-Id: <AANLkTi=iqabHfTwSON81ZiNKw9vXvGkrOg2QkGxXd2vt@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <20100816051936.GD3571@gerrit.erg.abdn.ac.uk>
In-Reply-To: <20100816051936.GD3571@gerrit.erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

Acked-by: Ivo Calado <ivocalado@embedded.ufcg.edu.br>  for ccid4 subtree

On Mon, Aug 16, 2010 at 02:19, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> This patch relates to the similar one submitted last week for CCID-2.
>
> It replaces the hardcoded (Kconfig) value of the minimum RTO value with
> a reconfigurable, per-route value which falls back to the TCP minimum
> RTO value.
>
> Leando, Ivo, can you please have a look and indicate whether you are ok
> with this? If yes I would like to also update the CCID-4 tree to make it
> consistent with the test tree - for this reason the test tree has not yet
> been updated.
>
>>>>>>>>>>>>>>>>>>>>>>>> Patch <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
> dccp ccid-3: use per-route RTO or TCP RTO as fallback
>
> This makes the TCP (per-route) RTO value also available to CCID-3, hence =
it
> is now possible to influence this value at runtime rather than, as before,
> via Kconfig.
>
> The same effect as the default Kconfig option of 100ms is now achieved by
>
>> ip route replace to unicast 192.168.0.0/24 rto_min 100j dev eth0
>
> (assuming HZ=1000).
>
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
> ---
> =A0net/dccp/ccids/Kconfig | =A0 31 -------------------------------
> =A0net/dccp/ccids/ccid3.c | =A0 =A09 ++++-----
> =A02 files changed, 4 insertions(+), 36 deletions(-)
>
> --- a/net/dccp/ccids/Kconfig
> +++ b/net/dccp/ccids/Kconfig
> @@ -47,37 +47,6 @@ config IP_DCCP_CCID3_DEBUG
>
> =A0 =A0 =A0 =A0 =A0If in doubt, say N.
>
> -config IP_DCCP_CCID3_RTO
> - =A0 =A0 =A0 =A0 int "Use higher bound for nofeedback timer"
> - =A0 =A0 =A0 =A0 default 100
> - =A0 =A0 =A0 =A0 depends on IP_DCCP_CCID3 && EXPERIMENTAL
> - =A0 =A0 =A0 =A0 ---help---
> - =A0 =A0 =A0 =A0 =A0 Use higher lower bound for nofeedback timer expirat=
ion.
> -
> - =A0 =A0 =A0 =A0 =A0 The TFRC nofeedback timer normally expires after th=
e maximum of 4
> - =A0 =A0 =A0 =A0 =A0 RTTs and twice the current send interval (RFC 3448,=
 4.3). On LANs
> - =A0 =A0 =A0 =A0 =A0 with a small RTT this can mean a high processing lo=
ad and reduced
> - =A0 =A0 =A0 =A0 =A0 performance, since then the nofeedback timer is tri=
ggered very
> - =A0 =A0 =A0 =A0 =A0 frequently.
> -
> - =A0 =A0 =A0 =A0 =A0 This option enables to set a higher lower bound for=
 the nofeedback
> - =A0 =A0 =A0 =A0 =A0 value. Values in units of milliseconds can be set h=
ere.
> -
> - =A0 =A0 =A0 =A0 =A0 A value of 0 disables this feature by enforcing the=
 value specified
> - =A0 =A0 =A0 =A0 =A0 in RFC 3448. The following values have been suggest=
ed as bounds for
> - =A0 =A0 =A0 =A0 =A0 experimental use:
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 * 16-20ms to match the typical multimedia i=
nter-frame interval
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 * 100ms as a reasonable compromise [default]
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 * 1000ms corresponds to the lower TCP RTO b=
ound (RFC 2988, 2.4)
> -
> - =A0 =A0 =A0 =A0 =A0 The default of 100ms is a compromise between a larg=
e value for
> - =A0 =A0 =A0 =A0 =A0 efficient DCCP implementations, and a small value t=
o avoid disrupting
> - =A0 =A0 =A0 =A0 =A0 the network in times of congestion.
> -
> - =A0 =A0 =A0 =A0 =A0 The purpose of the nofeedback timer is to slow DCCP=
 down when there
> - =A0 =A0 =A0 =A0 =A0 is serious network congestion: experimenting with l=
arger values should
> - =A0 =A0 =A0 =A0 =A0 therefore not be performed on WANs.
> -
> =A0config IP_DCCP_TFRC_LIB
> =A0 =A0 =A0 =A0def_bool y if IP_DCCP_CCID3
>
> --- a/net/dccp/ccids/ccid3.c
> +++ b/net/dccp/ccids/ccid3.c
> @@ -461,12 +461,11 @@ done_computing_x:
>
> =A0 =A0 =A0 =A0/*
> =A0 =A0 =A0 =A0 * Update timeout interval for the nofeedback timer.
> - =A0 =A0 =A0 =A0* We use a configuration option to increase the lower bo=
und.
> - =A0 =A0 =A0 =A0* This can help avoid triggering the nofeedback timer too
> - =A0 =A0 =A0 =A0* often ('spinning') on LANs with small RTTs.
> + =A0 =A0 =A0 =A0* We use the current (per-route) value of the TCP RTO as=
 lower bound
> + =A0 =A0 =A0 =A0* to slow down rate-halving on networks with small RTTs =
(loopback,
> + =A0 =A0 =A0 =A0* running DCCP in a virtual machine, Gbit ethernet, etc).
> =A0 =A0 =A0 =A0 */
> - =A0 =A0 =A0 hc->tx_t_rto =3D max_t(u32, 4 * hc->tx_rtt, (CONFIG_IP_DCCP=
_CCID3_RTO *
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(USEC_PER_SEC / 1000)));
> + =A0 =A0 =A0 hc->tx_t_rto =3D max(4 * hc->tx_rtt, USEC_PER_SEC/HZ * tcp_=
rto_min(sk));
> =A0 =A0 =A0 =A0/*
> =A0 =A0 =A0 =A0 * Schedule no feedback timer to expire in
> =A0 =A0 =A0 =A0 * max(t_RTO, 2 * s/X) =A0=3D =A0max(t_RTO, 2 * t_ipi)
>



--=20
Ivo Augusto Andrade Rocha Calado
PhD candidate in Electrical Engineering
Embedded Systems and Pervasive Computing Lab - http://embedded.ufcg.edu.br
Electrical Engineering Department - http://dee.ufcg.edu.br/
Electrical Engineering and Informatics Center - http://www.ceei.ufcg.edu.br
Federal University of Campina Grande - http://www.ufcg.edu.br

PGP: 0xD7C3860A pgp.mit.edu
Putt's Law:
=A0 =A0 =A0=A0 Technology is dominated by two types of people:
=A0 =A0 =A0 =A0 =A0 =A0 =A0=A0 Those who understand what they do not manage.
=A0 =A0 =A0 =A0 =A0 =A0 =A0=A0 Those who manage what they do not understand.
