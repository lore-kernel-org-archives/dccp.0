From: Christoph Hellwig <hch@lst.de>
Date: Sun, 26 Jul 2020 07:03:11 +0000
Subject: Re: get rid of the address_space override in setsockopt v2
Message-Id: <20200726070311.GA16687@lst.de>
List-Id: <dccp.vger.kernel.org>
References: <20200720124737.118617-1-hch@lst.de>
In-Reply-To: <20200720124737.118617-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Fri, Jul 24, 2020 at 03:43:42PM -0700, David Miller wrote:
> > Changes since v1:
> >  - check that users don't pass in kernel addresses
> >  - more bpfilter cleanups
> >  - cosmetic mptcp tweak
> 
> Series applied to net-next, I'm build testing and will push this out when
> that is done.

The buildbot found one warning with the isdn debug code after a few
days, here is what I think is the best fix:

---
From 6601732f7a54db5f04efba08f7e9224e5b757112 Mon Sep 17 00:00:00 2001
From: Christoph Hellwig <hch@lst.de>
Date: Sun, 26 Jul 2020 09:00:09 +0200
Subject: mISDN: remove a debug printk in data_sock_setsockopt

The %p won't work with the new sockptr_t type.  But in the times of
ftrace, bpftrace and co these kinds of debug printks are pretty anyway,
so just remove the whole debug printk.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 drivers/isdn/mISDN/socket.c | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/drivers/isdn/mISDN/socket.c b/drivers/isdn/mISDN/socket.c
index 1b2b91479107bc..2c58a6fe6d129e 100644
--- a/drivers/isdn/mISDN/socket.c
+++ b/drivers/isdn/mISDN/socket.c
@@ -406,10 +406,6 @@ static int data_sock_setsockopt(struct socket *sock, int level, int optname,
 	struct sock *sk = sock->sk;
 	int err = 0, opt = 0;
 
-	if (*debug & DEBUG_SOCKET)
-		printk(KERN_DEBUG "%s(%p, %d, %x, %p, %d)\n", __func__, sock,
-		       level, optname, optval, len);
-
 	lock_sock(sk);
 
 	switch (optname) {
-- 
2.27.0
