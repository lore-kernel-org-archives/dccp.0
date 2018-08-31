From: Arnd Bergmann <arnd@arndb.de>
Date: Fri, 31 Aug 2018 10:31:23 +0000
Subject: Re: [PATCH net-next 1/3] net: rework SIOCGSTAMP ioctl handling
Message-Id: <CAK8P3a2XTUZJUqGu6v=SZqcoJTqM3fgtDAWBnBopX3=4NJYcRA@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <20180829130308.3504560-1-arnd@arndb.de>
In-Reply-To: <20180829130308.3504560-1-arnd@arndb.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Thu, Aug 30, 2018 at 10:10 PM Willem de Bruijn
<willemdebruijn.kernel@gmail.com> wrote:
>
> On Wed, Aug 29, 2018 at 9:05 AM Arnd Bergmann <arnd@arndb.de> wrote:
> >
> > The SIOCGSTAMP/SIOCGSTAMPNS ioctl commands are implemented by many
> > socket protocol handlers, and all of those end up calling the same
> > sock_get_timestamp()/sock_get_timestampns() helper functions, which
> > results in a lot of duplicate code.
> >
> > With the introduction of 64-bit time_t on 32-bit architectures, this
> > gets worse, as we then need four different ioctl commands in each
> > socket protocol implementation.
> >
> > To simplify that, let's add a new .gettstamp() operation in
> > struct proto_ops, and move ioctl implementation into the common
> > sock_ioctl()/compat_sock_ioctl_trans() functions that these all go
> > through.
> >
> > We can reuse the sock_get_timestamp() implementation, but generalize
> > it so it can deal with both native and compat mode, as well as
> > timeval and timespec structures.
> >
> > Signed-off-by: Arnd Bergmann <arnd@arndb.de>
>
> This also will simplify fixing a recently reported race condition with
> sock_get_timestamp [1]. That calls sock_enable_timestamp, which
> modifies sk->sk_flags, without taking the socket lock. Currently some
> callers of sock_get_timestamp hold the lock (ax25, netrom, qrtr), many
> don't. See also how this patch removes the lock_sock in the netrom
> case. Moving the call to sock_gettstamp outside the protocol handlers
> will allow taking the lock inside the function.

I suppose it would be best to always take that lock then, rather than
removing the lock as my patch does at the moment.

> If this is the only valid implementation of .gettstamp, the indirect
> call could be avoided in favor of a simple branch.

I thought about that as well, but I could not come up with a
good way to encode the difference between socket protocols
that allow timestamping and those that don't.

I think ideally we would just call sock_gettstamp() unconditonally
on every socket, and have that function decide whether timestamps
make sense or not. The part I did not understand is which ones
actually want the timestamps or not. Most protocols that
implement the ioctls also assign skb->tstamp, but there are some
protocols in which I could not see skb->tstamp ever being set,
and some that set it but don't seem to have the ioctls.

Looking at it again, it seems that sock_gettstamp() should
actually deal with this gracefully: it will return a -EINVAL
error condition if the timestamp remains at the
SK_DEFAULT_STAMP initial value, which is probably
just as appropriate (or better) as the current -ENOTTY
default, and if we are actually recording timestamps, we
might just as well report them.

> Acked-by: Willem de Bruijn <willemb@google.com>

Thanks,

      Arnd
