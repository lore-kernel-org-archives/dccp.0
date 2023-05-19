From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Date: Fri, 19 May 2023 17:04:50 +0000
Subject: Re: [PATCH 1/1] net: ioctl: Use kernel memory on protocol ioctl callbacks
Message-Id: <CAF=yD-L0MnbofufMB_SKu+8PZ+f_QdAGYoDe-jOavdkAjFrXXg@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <20230519135821.922326-2-leitao@debian.org>
In-Reply-To: <20230519135821.922326-2-leitao@debian.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: dccp@vger.kernel.org

On Fri, May 19, 2023 at 11:39 AM Breno Leitao <leitao@debian.org> wrote:
>
> On Fri, May 19, 2023 at 11:09:29AM -0400, Willem de Bruijn wrote:
> > On Fri, May 19, 2023 at 9:59 AM Breno Leitao <leitao@debian.org> wrote:
> > >
> > > Most of the ioctls to net protocols operates directly on userspace
> > > argument (arg). Usually doing get_user()/put_user() directly in the
> > > ioctl callback.  This is not flexible, because it is hard to reuse these
> > > functions without passing userspace buffers.
> > >
> > > Change the "struct proto" ioctls to avoid touching userspace memory and
> > > operate on kernel buffers, i.e., all protocol's ioctl callbacks is
> > > adapted to operate on a kernel memory other than on userspace (so, no
> > > more {put,get}_user() and friends being called in the ioctl callback).
> > >
> > > This changes the "struct proto" ioctl format in the following way:
> > >
> > >     int                     (*ioctl)(struct sock *sk, int cmd,
> > > -                                        unsigned long arg);
> > > +                                        int *karg);
> > >
> > > So, the "karg" argument, which is passed to the ioctl callback, is a
> > > pointer allocated to kernel space memory (inside a function wrapper -
> > > sock_skprot_ioctl()). This buffer (karg) may contain input argument
> > > (copied from userspace in a prep function) and it might return a
> > > value/buffer, which is copied back to userspace if necessary. There is
> > > not one-size-fits-all format (that is I am using 'may' above), but
> > > basically, there are three type of ioctls:
> > >
> > > 1) Do not read from userspace, returns a result to userspace
> > > 2) Read an input parameter from userspace, and does not return anything
> > >   to userspace
> > > 3) Read an input from userspace, and return a buffer to userspace.
> > >
> > > The default case (1) (where no input parameter is given, and an "int" is
> > > returned to userspace) encompasses more than 90% of the cases, but there
> > > are two other exceptions. Here is a list of exceptions:
> > >
> > > * Protocol RAW:
> > >    * cmd = SIOCGETVIFCNT:
> > >      * input and output = struct sioc_vif_req
> > >    * cmd = SIOCGETSGCNT
> > >      * input and output = struct sioc_sg_req
> > >    * Explanation: for the SIOCGETVIFCNT case, userspace passes the input
> > >      argument, which is struct sioc_vif_req. Then the callback populates
> > >      the struct, which is copied back to userspace.
> > >
> > > * Protocol RAW6:
> > >    * cmd = SIOCGETMIFCNT_IN6
> > >      * input and output = struct sioc_mif_req6
> > >    * cmd = SIOCGETSGCNT_IN6
> > >      * input and output = struct sioc_sg_req6
> > >
> > > * Protocol PHONET:
> > >   * cmd == SIOCPNADDRESOURCE | SIOCPNDELRESOURCE
> > >      * input int (4 bytes)
> > >   * Nothing is copied back to userspace.
> > >
> > > For the exception cases, functions sock_skproto_ioctl_in{out}() will
> > > copy the userspace input, and copy it back to kernel space.
> > >
> > > The wrapper that prepares the buffer and puts the buffer back to user is
> > > sock_skprot_ioctl(), so, instead of calling sk->sk_prot->ioctl(), the
> > > callee now calls sock_skprot_ioctl().
> > >
> > > Signed-off-by: Breno Leitao <leitao@debian.org>
> >
> > Overall this looks great to me.
>
> Thanks for the guidance and quick review!
>
> >
> > Thanks for the detailed commit message that lists all exceptions, Bruno.
> >
> > Since that is a limited well understood list, I'm not in favor of the
> > suggestion to add an explicit length argument that then needs to be
> > checked in each callee.
> >
> > > +/* Copy 'size' bytes from userspace and return `size` back to userspace */
> > > +int sock_skproto_ioctl_inout(struct sock *sk, unsigned int cmd,
> > > +                            void __user *arg, size_t size)
> > > +{
> > > +       void *ptr;
> > > +       int ret;
> > > +
> > > +       ptr = kmalloc(size, GFP_KERNEL);
> > > +       if (!ptr)
> > > +               return -ENOMEM;
> >
> > > +/* A wrapper around sock ioctls, which copies the data from userspace
> > > + * (depending on the protocol/ioctl), and copies back the result to userspace.
> > > + * The main motivation for this function is to pass kernel memory to the
> > > + * protocol ioctl callsback, instead of userspace memory.
> > > + */
> > > +int sock_skprot_ioctl(struct sock *sk, unsigned int cmd,
> > > +                     void __user *arg)
> > > +{
> > > +#ifdef CONFIG_IP_MROUTE
> > > +       if (!strcmp(sk->sk_prot->name, "RAW")) {
> >
> > This must check both sk_family and sk_protocol. That is preferable
> > over string match.
> >
> > For these exception cases, instead of having sock_skproto_ioctl_inout
> > dynamically allocate the struct, how about stack allocating them here
> > and passing to the function?
>
> Should I stack allocate all the 4 structures sock_skprot_ioctl and pass
> them to sock_skproto_ioctl_inout() together with the size? (using the
> original name to avoid confusion - will rename in V2)
>
> I mean, writing something as:
>
> int sock_skprot_ioctl(struct sock *sk, unsigned int cmd
>                      void __user *arg`
> {
>         struct sioc_vif_req sioc_vif_req_arg;
>         struct sioc_sg_req sioc_sg_req_arg;
>         struct sioc_mif_req6 sioc_mif_req6_arg;
>         struct sioc_sg_req6 sioc_sg_req6_arg;
>
>         ..
>
>         if (!strcmp(sk->sk_prot->name, "RAW6")) {
>         switch (cmd) {
>                case SIOCGETMIFCNT_IN6:
>                        return sock_skproto_ioctl_inout(sk, cmd,
>                                arg, &sioc_mif_req6_arg, sizeof(sioc_mif_req6_arg);
>                case SIOCGETSGCNT_IN6:
>                        return sock_skproto_ioctl_inout(sk, cmd,
>                                arg, &sioc_sg_req6_arg, sizeof(sioc_sg_req6_arg));
>                }
>        }
>        ...
> }

Slight preference for using braces in the individual case statements
and defining the variables in that block scope. See for instance
do_tcp_setsockopt.

Btw, no need for a cover letter for a single patch.
