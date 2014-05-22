From: =?utf-8?B?566h6Zuq5rab?= <gxt@pku.edu.cn>
Date: Thu, 22 May 2014 23:58:11 +0000
Subject: =?utf-8?Q?=E5=9B=9E=E5=A4=8D=EF=BC=9A_Re:_[PATCH_linux-nex?= =?utf-8?Q?t]_net/dccp/timer.c:_use_?=
Message-Id: <263613432.57393.1400803091663.JavaMail.root@bj-mail03.pku.edu.cn>
List-Id: <dccp.vger.kernel.org>
References: <579164883.46799.1400720806850.JavaMail.root@bj-mail03.pku.edu.cn>
In-Reply-To: <579164883.46799.1400720806850.JavaMail.root@bj-mail03.pku.edu.cn>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: dccp@vger.kernel.org


----- David Miller <davem@davemloft.net> 写道：
> From: Chen Gang <gang.chen.5i5j@gmail.com>
> Date: Wed, 21 May 2014 08:19:34 +0800
> 
> > 'dccp_timestamp_seed' is initialized once by ktime_get_real() in
> > dccp_timestamping_init(). It is always less than ktime_get_real()
> > in dccp_timestamp().
> > 
> > Then, ktime_us_delta() in dccp_timestamp() will always return positive
> > number. So can use manual type cast to let compiler and do_div() know
> > about it to avoid warning.
> > 
> > The related warning (with allmodconfig under unicore32):
> > 
> >     CC [M]  net/dccp/timer.o
> >   net/dccp/timer.c: In function ‘dccp_timestamp’:
> >   net/dccp/timer.c:285: warning: comparison of distinct pointer types lacks a cast
> > 
> > 
> > Signed-off-by: Chen Gang <gang.chen.5i5j@gmail.com>
> 
> Applied to net-next, thanks.
> 
> But that type check in include/asm-generic/div64.h is bogus, it should
> be checking sizeof(X) = 8 rather than the type thing, it just wants to
> make sure that the value is 64-bit regardless of it's signedness.
> 
> The arch local implementations do not do this, and that's why very few
> other people notice this warning.

Arch-dependent codes implement it with unsigned long long type.
And, every warning should not be ignored.
