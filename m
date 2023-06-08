From: Breno Leitao <leitao@debian.org>
Date: Thu, 08 Jun 2023 08:43:13 +0000
Subject: Re: [PATCH net-next v6] net: ioctl: Use kernel memory on protocol ioctl callbacks
Message-Id: <ZIGUofpP4k24qfQs@gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <20230606180045.827659-1-leitao@debian.org>
In-Reply-To: <20230606180045.827659-1-leitao@debian.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hello Kuniyuki,
On Wed, Jun 07, 2023 at 10:31:42AM -0700, Kuniyuki Iwashima wrote:
> > +/* This is the most common ioctl prep function, where the result (4 bytes) is
> > + * copied back to userspace if the ioctl() returns successfully. No input is
> > + * copied from userspace as input argument.
> > + */
> > +static int sock_ioctl_out(struct sock *sk, unsigned int cmd, void __user *arg)
> > +{
> > +	int ret, karg = 0;
> > +
> > +	ret = sk->sk_prot->ioctl(sk, cmd, &karg);
> 
> We need READ_ONCE(sk->sk_prot) as IPv4 conversion or ULP chnage could
> occur at the same time.

Thanks for the heads-up. I would like to pick you brain and understand
a bit more about READ_ONCE() and what is the situation that READ_ONCE()
will solve.

Is the situation related to when sock_ioctl_out() start to execute, and
"sk->sk_prot" changes in a different thread? If that is the case, the
arguments (cmd and arg) will be from the "previous" instance.

Also, grepping for "sk->sk_prot->", I see more than a bunch of calls
that do not use READ_ONCE() barrier. Why is this case different?

Thank you
