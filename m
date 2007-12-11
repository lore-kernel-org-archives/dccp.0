From: Alessio Botta <a.botta@unina.it>
Date: Tue, 11 Dec 2007 13:59:46 +0000
Subject: Re: [Announce]: Test results with latest CCID3 patch set
Message-Id: <475E97D2.4010208@unina.it>
List-Id: <dccp.vger.kernel.org>
References: <20071210154008.GA16839@gerrit.erg.abdn.ac.uk>
In-Reply-To: <20071210154008.GA16839@gerrit.erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

Hi all,

I am new of this mailing list and I am really interested in the
measurements you are performing with DCCP.
Which tool are you using ? Are you using Iperf for such measurements ?
In the past I used it, currently I'm working on D-ITG.
Have you ever heard about D-ITG ?
It is both a flexible traffic generator and a measurement platform which
also supports DCCP.
More precisely, as regards transport protocols, it
supports TCP, UDP, SCTP, and DCCP. It is also possible
to generate ICMP traffic.
You can find more information here:
http://www.grid.unina.it/software/ITG

I am one of the authors of such platform and I have also
performed some very preliminary tests with DCCP.

I would be very glad to have your opinion on that and I'm very interested
in improving its features, also with specific regard to the support of
transport protocols.

Best Regards.

AB


Gerrit Renker ha scritto:
> As promised, here are some test results using the latest (2.6.25-backport=
ed)
> version of the test tree.
>=20
> These are sanity checks and by no means "statistically significant". For
> that it would necessary to run more tests, take averages and calculate
> standard deviation / error bars.
>=20
> Longer test runs (> 1/3 Min) would also be good.
>=20
> Please therefore feel encouraged to run similar tests against this; on
> possibly different pieces of hardware.
>=20
> All runs were for 20 seconds. The figures in square brackets are the
> theoretical values using the throughput equation from RFC 3448, 3.1, which
> ignores IP/DCCP header sizes.
>=20
>=20
> I) First run: laptop to double-CPU server via NetEm router
> ----------------------------------------------------------
> This run was done before the latest revision of patches today, but
> already including the patch set as per Friday last week.
> Setup for these tests:
> 	* client: Pentium M 1.7 GHz laptop
> 	* server: 2 x Pentium III 700 MHz SMP server
> 	* router: 2.4 GHz PIV desktop with 2.6.24 NetEm
>=20
> RTT 40ms, loss 1%
> 	* DCCPv6, s=1420:        3.3  Mbps   [3.3 Mbps]
> 	*         s%6:         658  kbps   [602 kbps]
> 	*         s2:           63  kbps   [ 75 kbps]
> 	* DCCPv4, s=1440:        3.5  Mbps   [3.4 Mbps]
> 	*         s%6:         638  kbps   [602 kbps]
> 	*         s2:           73  kbps   [ 75 kbps]
>=20
> RTT 150ms, loss 1%
> 	* DCCPv6, s=1420:         826 kbps   [891 kbps]
> 	*         s%6:          120 kbps   [161 kbps]
> 	*         s2:            18 kbps   [ 20 kbps]
> 	* DCCPv4, s=1440:         714 kbps   [904 kbps]
> 	*         s%6:          230 kbps   [161 kbps]
> 	*         s2:            20 kbps   [ 20 kbps]
>=20
> RTT 150ms, loss 10%
> 	* DCCPv6, s=1420:        130  kbps   [132 kbps]
> 	*         s%6:          23  kbps   [ 24 kbps]
> 	*         s2:           3.8 kbps   [  3 kbps]
> 	* DCCPv4, s=1440:        221  kbps   [134 kbps]
> 	*         s%6:          25  kbps   [ 24 kbps]
> 	*         s2:            3  kbps   [  3 kbps]
>=20
>=20
>=20
> II) Second run: desktop-to-desktop via NetEm bridge
> ---------------------------------------------------
> This run was done with the latest revision of patches today.
> Setup for these tests:
> 	* client: 2.4 GHz PIV desktop
> 	* server: 2.8 GHz Pentium dual-core desktop
> 	* bridge: 2.4 GHz PIV desktop with 2.6.18-4 NetEm
>=20
> RTT 40ms, loss 1%
> 	* DCCPv6, s=1420:        3.07 Mbps   [3.3 Mbps]
> 	*         s%6:          644 kbps   [602 kbps]
> 	*         s2:            63 kbps   [ 75 kbps]
> 	* DCCPv4, s=1440:        3.26 Mbps   [3.4 Mbps]
> 	*         s%6:          600 kbps   [602 kbps]
> 	*         s2:            67 kbps   [ 75 kbps]
>=20
> RTT 150ms, loss 1%
> 	* DCCPv6, s=1420:         756 kbps   [891 kbps]
> 	*         s%6:          148 kbps   [161 kbps]
> 	*         s2:            16 kbps   [ 20 kbps]
> 	* DCCPv4, s=1440:         947 kbps   [904 kbps]
> 	*         s%6:          131 kbps   [161 kbps]
> 	*         s2:            23 kbps   [ 20 kbps]
>=20
> RTT 150ms, loss 10%
> 	* DCCPv6, s=1420:         117 kbps   [132 kbps]
> 	*         s%6:           28 kbps   [ 24 kbps]
> 	*         s2:           3.6 kbps   [  3 kbps]
> 	* DCCPv4, s=1440:         187 kbps   [134 kbps]
> 	*         s%6:           50 kbps   [ 24 kbps]
> 	*         s2:             4 kbps   [  3 kbps]
>=20
>=20
> I think this encouraging and asks for more challenging tests.
> -
> To unsubscribe from this list: send the line "unsubscribe dccp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--=20
Alessio Botta, PhD Student
Dipartimento di Informatica e Sistemistica
Universit=E0 degli Studi di Napoli Federico II
Via Claudio 21 -- 80125 Napoli (Italy)
Phone: +390817683821 - Fax: +390817683816
Email: a.botta@unina.it
         abotta@napoli.consorzio-cini.it
WWW: http://wpage.unina.it/a.botta
