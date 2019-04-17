From: Arnd Bergmann <arnd@arndb.de>
Date: Wed, 17 Apr 2019 16:19:25 +0000
Subject: Re: [PATCH net-next 1/3] net: rework SIOCGSTAMP ioctl handling
Message-Id: <CAK8P3a2z5QT7VooQPytx-C+Z_+kxzqmWmB8x-ow9PaApPuFY8g@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <20180829130308.3504560-1-arnd@arndb.de>
In-Reply-To: <20180829130308.3504560-1-arnd@arndb.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Wed, Apr 17, 2019 at 4:46 PM Willem de Bruijn
<willemdebruijn.kernel@gmail.com> wrote:
> On Tue, Apr 16, 2019 at 4:38 PM Arnd Bergmann <arnd@arndb.de> wrote:
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
> > Acked-by: Stefan Schmidt <stefan@datenfreihafen.org>
> > Link: https://lore.kernel.org/lkml/CAK8P3a038aDQQotzua_QtKGhq8O9n+rdiz2=WDCp82ys8eUT+A@mail.gmail.com/
> > Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> > ---
> > v2: reworked to not break sparc64 support
>
> From the discussion of v1 I thought you planned to unconditionally
> call sock_gettstamp() for all protocols, avoiding the need to plumb in
> all these new callbacks?
>
> That is more concise, though this closer to the existing behavior. So,
> fine either way.

Thanks for the reminder. I have definitely waited too long before revisiting
this series, and only had a vague recollection of that discussion but could
not find it in the logs (found it now, and the Link I quoted...).

I would prefer to get this series into the coming merge window, and
probably don't have time to rework it completely by then, so I hope
the current version is ok.

I also found your comment on lock_sock(), which could be easily
added inside of sock_gettstamp() if you think we should have that.
There is one more issue I just noticed (I dropped the necessary
sock_read_timestamp()), so I have to repost the series anyway
to fix that.

       Arnd
