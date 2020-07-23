From: Christoph Hellwig <hch@lst.de>
Date: Thu, 23 Jul 2020 16:44:32 +0000
Subject: Re: [PATCH 04/26] net: add a new sockptr_t type
Message-Id: <20200723164432.GA20917@lst.de>
List-Id: <dccp.vger.kernel.org>
References: <20200723060908.50081-5-hch@lst.de>
In-Reply-To: <20200723060908.50081-5-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Thu, Jul 23, 2020 at 09:40:27AM -0700, Eric Dumazet wrote:
> I am not sure why you chose sockptr_t   for something that really seems generic.
> 
> Or is it really meant to be exclusive to setsockopt() and/or getsockopt() ?
> 
> If the first user of this had been futex code, we would have used
> futexptr_t, I guess.

It was originally intended to be generic and called uptr_t, based
on me misunderstanding that Linus wanted a file operation for it,
which he absolutely didn't and hate with passion.  So the plan is to
only use it for setsockopt for now, although there are some arguments
for also using it in sendmsg/recvmsg.  There is no need to use it for
getsockopt.
