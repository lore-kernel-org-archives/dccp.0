From: Breno Leitao <leitao@debian.org>
Date: Tue, 18 Apr 2023 13:23:15 +0000
Subject: Re: [PATCH 0/5] add initial io_uring_cmd support for sockets
Message-Id: <ZD6Zw1GAZR28++3v@gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <20230406144330.1932798-1-leitao@debian.org>
In-Reply-To: <20230406144330.1932798-1-leitao@debian.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Thu, Apr 13, 2023 at 10:24:31AM -0400, Willem de Bruijn wrote:
> > How to handle these contradictory behaviour ahead of time (at callee
> > time, where the buffers will be prepared)?
> 
> Ah you found a counter-example to the simple pattern of put_user.
> 
> The answer perhaps depends on how many such counter-examples you
> encounter in the list you gave. If this is the only one, exceptions
> in the wrapper are reasonable. Not if there are many.


Hello Williem,

I spend sometime dealing with it, and the best way for me to figure out
how much work this is, was implementing a PoC. You can find a basic PoC
in the link below. It is not 100% complete (still need to convert 4
simple ioctls), but, it deals with the most complicated cases. The
missing parts are straighforward if we are OK with this approach.

	https://github.com/leitao/linux/commits/ioctl_refactor

Details
===
1)  Change the ioctl callback to use kernel memory arguments. This
changes a lot of files but most of them are trivial. This is the new
ioctl callback:

struct proto {

        int                     (*ioctl)(struct sock *sk, int cmd,
-                                        unsigned long arg);
+                                        int *karg);

	You can see the full changeset in the following commit (which is
	the last in the tree above)
	https://github.com/leitao/linux/commit/ad78da14601b078c4b6a9f63a86032467ab59bf7

2) Create a wrapper (sock_skprot_ioctl()) that should be called instead
of sk->sk_prot->ioctl(). For every exception, calls a specific function
for the exception (basically ipmr_ioctl and ipmr_ioctl) (see more on 3)

	This is the commit https://github.com/leitao/linux/commit/511592e549c39ef0de19efa2eb4382cac5786227

3) There are two exceptions, they are ip{6}mr_ioctl() and pn_ioctl().
ip{6}mr is the hardest one, and I implemented the exception flow for it.

	You could find ipmr changes here:
	https://github.com/leitao/linux/commit/659a76dc0547ab2170023f31e20115520ebe33d9

Is this what you had in mind?

Thank you!
