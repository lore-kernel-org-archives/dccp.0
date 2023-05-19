From: Breno Leitao <leitao@debian.org>
Date: Fri, 19 May 2023 15:19:10 +0000
Subject: Re: [PATCH 0/1] net: ioctl: Use kernel buffer on proto ioctl callbacks
Message-Id: <ZGeTbsnCZtkewPzu@gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <20230519135821.922326-1-leitao@debian.org>
In-Reply-To: <20230519135821.922326-1-leitao@debian.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Fri, May 19, 2023 at 08:15:26AM -0700, Jakub Kicinski wrote:
> On Fri, 19 May 2023 06:58:20 -0700 Breno Leitao wrote:
> > With the implementation of network ioctl on io_uring[1], Willem
> > suggested[2] that the "struct proto" ioctls functions should be reused,
> > instead of duplicating the code.
> > For that, the ioctl callbacks need to be more flexible, and avoid
> > operating on userspace buffers (doing get/put_user()) directly on the
> > callbacks. This patch adds this flexibility, so, the io_uring plumbing
> > becomes more clean, avoiding duplicating code. This may also benefit
> > BPF.
> > 
> > For that, a wrapper is created, which will copy from/to userspace, and
> > the ioctl callback will rely on the wrapper to do userspace memory
> > copies.
> > 
> > I've tested this patch in three different ways:
> > 1) Created a simple testcase for TCP/UDP [3]
> > 2) Run relevant LTP tests, such as: sockioctl, setsockopt, bind, sendto,
> > 				    fanout, ns-udpsender, etc
> > 3) Run basics network selftests
> > 
> > PS: There are some `strcmp()` in the `sock_skprot_ioctl()`, that I was
> > not able to find a better way to deal with it. Any feedback is
> > appreciated.
> 
> Why not CC netdev@ on this?

Oops, my mistake. I will do it on V2.
