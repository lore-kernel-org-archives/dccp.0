From: David Laight <David.Laight@ACULAB.COM>
Date: Fri, 19 May 2023 14:22:08 +0000
Subject: RE: [PATCH 1/1] net: ioctl: Use kernel memory on protocol ioctl callbacks
Message-Id: <f2d1a07b3e954db8ae40a2d739372e6c@AcuMS.aculab.com>
List-Id: <dccp.vger.kernel.org>
References: <20230519135821.922326-2-leitao@debian.org>
In-Reply-To: <20230519135821.922326-2-leitao@debian.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Breno Leitao
> Sent: 19 May 2023 14:58
> 
> Most of the ioctls to net protocols operates directly on userspace
> argument (arg). Usually doing get_user()/put_user() directly in the
> ioctl callback.  This is not flexible, because it is hard to reuse these
> functions without passing userspace buffers.
> 
> Change the "struct proto" ioctls to avoid touching userspace memory and
> operate on kernel buffers, i.e., all protocol's ioctl callbacks is
> adapted to operate on a kernel memory other than on userspace (so, no
> more {put,get}_user() and friends being called in the ioctl callback).
> 
> This changes the "struct proto" ioctl format in the following way:
> 
>     int                     (*ioctl)(struct sock *sk, int cmd,
> -                                        unsigned long arg);
> +                                        int *karg);

I think I'd add a karg_len field for the actual buffer length.
It will save embarrassment later on.

Do any of the ioctl functions return +ve values on success?
If not you can use the return value as the length for any
copy_to_user().

If all the current 'cmd' are 16bit, there is the option
of using 32bit IOR() etc commands to get automatic sizing.

	David

-
Registered Address Lakeside, Bramley Road, Mount Farm, Milton Keynes, MK1 1PT, UK
Registration No: 1397386 (Wales)
