From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Date: Wed, 17 Apr 2019 21:56:43 +0000
Subject: Re: [PATCH v3 1/3] net: rework SIOCGSTAMP ioctl handling
Message-Id: <CAF=yD-KkUveFFj_j721kML0rMJF=uDcVQv+RQO4N6xjorHCtZg@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <20190417205404.1877560-1-arnd@arndb.de>
In-Reply-To: <20190417205404.1877560-1-arnd@arndb.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Wed, Apr 17, 2019 at 4:54 PM Arnd Bergmann <arnd@arndb.de> wrote:
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
> Acked-by: Stefan Schmidt <stefan@datenfreihafen.org>
> Acked-by: Neil Horman <nhorman@tuxdriver.com>
> Acked-by: Marc Kleine-Budde <mkl@pengutronix.de>
> Link: https://lore.kernel.org/lkml/CAK8P3a038aDQQotzua_QtKGhq8O9n+rdiz2=WDCp82ys8eUT+A@mail.gmail.com/
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Acked-by: Willem de Bruijn <willemb@google.com>
