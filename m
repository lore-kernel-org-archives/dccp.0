From: Breno Leitao <leitao@debian.org>
Date: Sun, 04 Jun 2023 08:32:18 +0000
Subject: Re: [PATCH net-next v5] net: ioctl: Use kernel memory on protocol ioctl callbacks
Message-Id: <ZHxMErkF/Yi/OD8z@gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <20230602163044.1820619-1-leitao@debian.org>
In-Reply-To: <20230602163044.1820619-1-leitao@debian.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

On Sun, Jun 04, 2023 at 12:59:27AM -0700, Breno Leitao wrote:
> Hello Willem=20
>=20
> On Sat, Jun 03, 2023 at 10:21:50AM +0200, Willem de Bruijn wrote:
> > On Fri, Jun 2, 2023 at 6:31=E2=80=AFPM Breno Leitao <leitao@debian.org>=
 wrote:
> > > Signed-off-by: Breno Leitao <leitao@debian.org>
> >=20
> > Please check the checkpatch output
> >=20
> > https://patchwork.hopto.org/static/nipa/753609/13265673/checkpatch/stdo=
ut
>=20
> I am checking my current checkpatch before sending the patch, but I am
> not seeing the problems above.
>=20
> My tree is at 44c026a73be8038 ("Linux 6.4-rc3"), and I am not able to
> reproduce the problems above.
>=20
> 	$ scripts/checkpatch.pl v5/v5-0001-net-ioctl-Use-kernel-memory-on-protoc=
ol-ioctl-cal.patch
> 	total: 0 errors, 0 warnings, 0 checks, 806 lines checked
> 	v5/v5-0001-net-ioctl-Use-kernel-memory-on-protocol-ioctl-cal.patch has n=
o obvious style problems and is ready for submission.
>=20
> Let me investigate what options I am missing when running checkpatch.

Investigating these issues, I see 4 of the following messages:

	WARNING: line length of 84 exceeds 80 columns

This implies that checkpatch.pl is being called with
`--max-line-length=80` parameter, or, the system is using an older
version, before bdc48fa11e46f ("checkpatch/coding-style: deprecate
80-column warning").

Since I am not familiar with patchwork.hopto.org, I am not sure what is
the case. Do you know how can I find out?

Thanks!
