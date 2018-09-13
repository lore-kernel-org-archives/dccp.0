From: Arnd Bergmann <arnd@arndb.de>
Date: Thu, 13 Sep 2018 12:28:08 +0000
Subject: Re: [PATCH net-next 1/3] net: rework SIOCGSTAMP ioctl handling
Message-Id: <CAK8P3a038aDQQotzua_QtKGhq8O9n+rdiz2=WDCp82ys8eUT+A@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <20180829130308.3504560-1-arnd@arndb.de>
In-Reply-To: <20180829130308.3504560-1-arnd@arndb.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Wed, Aug 29, 2018 at 3:03 PM Arnd Bergmann <arnd@arndb.de> wrote:

> diff --git a/net/core/sock.c b/net/core/sock.c
> index 3730eb855095..df17bbfaca27 100644
> --- a/net/core/sock.c
> +++ b/net/core/sock.c
> @@ -2897,37 +2897,31 @@ bool lock_sock_fast(struct sock *sk)
>  }
>  EXPORT_SYMBOL(lock_sock_fast);
>
> -int sock_get_timestamp(struct sock *sk, struct timeval __user *userstamp)
> +int sock_gettstamp(struct socket *sock, void __user *userstamp,
> +                  bool timeval, bool time32)
>  {
> -       struct timeval tv;
> -
> -       sock_enable_timestamp(sk, SOCK_TIMESTAMP);
> -       tv = ktime_to_timeval(sk->sk_stamp);
> -       if (tv.tv_sec = -1)
> -               return -ENOENT;
> -       if (tv.tv_sec = 0) {
> -               sk->sk_stamp = ktime_get_real();
> -               tv = ktime_to_timeval(sk->sk_stamp);
> -       }
> -       return copy_to_user(userstamp, &tv, sizeof(tv)) ? -EFAULT : 0;
> -}
> -EXPORT_SYMBOL(sock_get_timestamp);

As  I just learned, sparc64 uses a 32-bit suseconds_t, so this
function always leaked 32 bits of kernel stack data by copying
the padding bytes of 'tv' into user space.

Linux-4.11 and higher could avoid that with
CONFIG_GCC_PLUGIN_STRUCTLEAK, but older kernels
have been affected since socket timestamps were first added.

The same thing is probably true of many other interfaces
that pass a timeval.

> -int sock_get_timestampns(struct sock *sk, struct timespec __user *userstamp)
> -{
> -       struct timespec ts;
> +       struct sock *sk = sock->sk;
> +       struct timespec64 ts;
>
>         sock_enable_timestamp(sk, SOCK_TIMESTAMP);
> -       ts = ktime_to_timespec(sk->sk_stamp);
> +       ts = ktime_to_timespec64(sk->sk_stamp);
>         if (ts.tv_sec = -1)
>                 return -ENOENT;
>         if (ts.tv_sec = 0) {
>                 sk->sk_stamp = ktime_get_real();
> -               ts = ktime_to_timespec(sk->sk_stamp);
> +               ts = ktime_to_timespec64(sk->sk_stamp);
>         }
> -       return copy_to_user(userstamp, &ts, sizeof(ts)) ? -EFAULT : 0;
> +
> +       if (timeval)
> +               ts.tv_nsec /= 1000;
> +#ifdef CONFIG_COMPAT_32BIT_TIME
> +       if (time32)
> +               return put_old_timespec32(&ts, userstamp);
> +#endif
> +
> +       return put_timespec64(&ts, userstamp);
>  }

My new implementation is worse here: it no longer leaks stack
data, but since we now write a big-endian 64-bit microseconds
value, the microseconds are in the wrong place and will
be interpreted as zero by user space...

I'll also have to revisit a few other similar patches I did for
y2038, to figure out what they should do on sparc64.

         Arnd
