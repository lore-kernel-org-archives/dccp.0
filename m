From: Breno Leitao <leitao@debian.org>
Date: Tue, 06 Jun 2023 10:11:55 +0000
Subject: Re: [PATCH net-next v5] net: ioctl: Use kernel memory on protocol ioctl callbacks
Message-Id: <ZH8Ga15IFIUUA7j8@gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <20230602163044.1820619-1-leitao@debian.org>
In-Reply-To: <20230602163044.1820619-1-leitao@debian.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

On Sun, Jun 04, 2023 at 11:17:56AM +0200, Willem de Bruijn wrote:
> > On Sat, Jun 03, 2023 at 10:21:50AM +0200, Willem de Bruijn wrote:
> > > On Fri, Jun 2, 2023 at 6:31=E2=80=AFPM Breno Leitao <leitao@debian.or=
g> wrote:
> > > > Signed-off-by: Breno Leitao <leitao@debian.org>
> > >
> > > Please check the checkpatch output
> > >
> > > https://patchwork.hopto.org/static/nipa/753609/13265673/checkpatch/st=
dout
> >
> > I am checking my current checkpatch before sending the patch, but I am
> > not seeing the problems above.
> >
> > My tree is at 44c026a73be8038 ("Linux 6.4-rc3"), and I am not able to
> > reproduce the problems above.
> >
> >         $ scripts/checkpatch.pl v5/v5-0001-net-ioctl-Use-kernel-memory-=
on-protocol-ioctl-cal.patch
> >         total: 0 errors, 0 warnings, 0 checks, 806 lines checked
> >         v5/v5-0001-net-ioctl-Use-kernel-memory-on-protocol-ioctl-cal.pa=
tch has no obvious style problems and is ready for submission.
> >
> > Let me investigate what options I am missing when running checkpatch.
>=20
> The reference is to the checkpatch as referenced by patchwork:
>=20
> https://patchwork.kernel.org/project/netdevbpf/patch/20230602163044.18206=
19-1-leitao@debian.org/
>=20
> The 80 character limit is a soft limit. But also note the CHECK
> statements on whitespace.

Right. In order to enable the "CHECK" statments, we need to pass the
"--subjective" parameter to checpatch.pl

That said, I am able to reproduce the same output now, using the
following command line:

	$ scripts/checkpatch.pl --subjective --max-line-length=80

> > > > +/* A wrapper around sock ioctls, which copies the data from usersp=
ace
> > > > + * (depending on the protocol/ioctl), and copies back the result t=
o userspace.
> > > > + * The main motivation for this function is to pass kernel memory =
to the
> > > > + * protocol ioctl callbacks, instead of userspace memory.
> > > > + */
> > > > +int sk_ioctl(struct sock *sk, unsigned int cmd, void __user *arg)
> > > > +{
> > > > +       int rc =3D 1;
> > > > +
> > > > +       if (sk_is_ipmr(sk))
> > > > +               rc =3D ipmr_sk_ioctl(sk, cmd, arg);
> > > > +       else if (sk_is_icmpv6(sk))
> > > > +               rc =3D ip6mr_sk_ioctl(sk, cmd, arg);
> > > > +       else if (sk_is_phonet(sk))
> > > > +               rc =3D phonet_sk_ioctl(sk, cmd, arg);
> > >
> > > Does this handle all phonet ioctl cases correctly?
> > >
> > > Notably pn_socket_ioctl has a SIOCPNGETOBJECT that reads and writes a=
 u16.
> >
> > We are not touching  "struct proto_ops" in this patch at all.  And
> > pn_socket_ioctl() is part of "struct proto_ops".
> >
> >         const struct proto_ops phonet_stream_ops =3D {
> >                   ...
> >                   .ioctl          =3D pn_socket_ioctl,
> >         }
> >
> > That said, all the "struct proto_ops" ioctl calls backs continue to use
> > "unsigned long arg" with userspace information, at least for now.
>=20
> Ok. Perhaps good to call out in the commit message that this does not
> convert all protocol ioctl callbacks.

Sure, let me send a V6 with this information in the patch summary.
