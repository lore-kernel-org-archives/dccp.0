From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Date: Thu, 30 Aug 2018 20:09:31 +0000
Subject: Re: [PATCH net-next 1/3] net: rework SIOCGSTAMP ioctl handling
Message-Id: <CAF=yD-J7-GumUmonrZt7s44e3bsjY2DCD6ZpmhtCx6FOBV5BNA@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <20180829130308.3504560-1-arnd@arndb.de>
In-Reply-To: <20180829130308.3504560-1-arnd@arndb.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Wed, Aug 29, 2018 at 9:05 AM Arnd Bergmann <arnd@arndb.de> wrote:
>
> The SIOCGSTAMP/SIOCGSTAMPNS ioctl commands are implemented by many
> socket protocol handlers, and all of those end up calling the same
> sock_get_timestamp()/sock_get_timestampns() helper functions, which
> results in a lot of duplicate code.
>
> With the introduction of 64-bit time_t on 32-bit architectures, this
> gets worse, as we then need four different ioctl commands in each
> socket protocol implementation.
>
> To simplify that, let's add a new .gettstamp() operation in
> struct proto_ops, and move ioctl implementation into the common
> sock_ioctl()/compat_sock_ioctl_trans() functions that these all go
> through.
>
> We can reuse the sock_get_timestamp() implementation, but generalize
> it so it can deal with both native and compat mode, as well as
> timeval and timespec structures.
>
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

This also will simplify fixing a recently reported race condition with
sock_get_timestamp [1]. That calls sock_enable_timestamp, which
modifies sk->sk_flags, without taking the socket lock. Currently some
callers of sock_get_timestamp hold the lock (ax25, netrom, qrtr), many
don't. See also how this patch removes the lock_sock in the netrom
case. Moving the call to sock_gettstamp outside the protocol handlers
will allow taking the lock inside the function.

If this is the only valid implementation of .gettstamp, the indirect
call could be avoided in favor of a simple branch.

Thanks,

Acked-by: Willem de Bruijn <willemb@google.com>

[1] http://lkml.kernel.org/r/20180518080308.GA28587@dragonet.kaist.ac.kr
