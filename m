From: Breno Leitao <leitao@debian.org>
Date: Fri, 26 May 2023 08:49:10 +0000
Subject: Re: [PATCH net-next v3] net: ioctl: Use kernel memory on protocol ioctl callbacks
Message-Id: <ZHByhjt2xYf5xKAu@gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <20230525125503.400797-1-leitao@debian.org>
In-Reply-To: <20230525125503.400797-1-leitao@debian.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

On Thu, May 25, 2023 at 11:05:40AM -0400, Willem de Bruijn wrote:
> On Thu, May 25, 2023 at 8:55=E2=80=AFAM Breno Leitao <leitao@debian.org> =
wrote:
> > @@ -1547,6 +1547,28 @@ int ip_mroute_setsockopt(struct sock *sk, int op=
tname, sockptr_t optval,
> >         return ret;
> >  }
> >
> > +/* Execute if this ioctl is a special mroute ioctl */
> > +int ipmr_sk_ioctl(struct sock *sk, unsigned int cmd, void __user *arg)
> > +{
> > +       switch (cmd) {
> > +       /* These userspace buffers will be consumed by ipmr_ioctl() */
> > +       case SIOCGETVIFCNT: {
> > +               struct sioc_vif_req buffer;
> > +
> > +               return sock_ioctl_inout(sk, cmd, arg, &buffer,
> > +                                     sizeof(buffer));
> > +               }
>=20
> More importantly, if we go down the path of demultiplexing in protocol
> independent code to call protocol specific handlers, then there there
> is no need to have them call protocol independent helpers like
> sock_ioct_inout again. Just call the protocol-specific ioctl handlers
> directly?

That is what I was expecting, but, the code is exactly the same and I
kept it in the generic section. This is what this code needs to do:

 * Copy X byte from userspace
 * sk->sk_prot->ioctl()
 * Copy X bytes back to userspace

I tried to keep the code generic enough that it could be reused.
I can definitely push the same code to two different protocols, if you
prefer, no strong opinion.=20
