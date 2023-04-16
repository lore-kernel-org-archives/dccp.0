From: Ming Lei <ming.lei@redhat.com>
Date: Sun, 16 Apr 2023 09:51:14 +0000
Subject: Re: [PATCH RFC] io_uring: Pass whole sqe to commands
Message-Id: <ZDvFEkRo+yor7FM+@ovpn-8-16.pek2.redhat.com>
List-Id: <dccp.vger.kernel.org>
References: <20230406165705.3161734-1-leitao@debian.org>
In-Reply-To: <20230406165705.3161734-1-leitao@debian.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Fri, Apr 14, 2023 at 03:56:47PM +0100, Pavel Begunkov wrote:
> On 4/14/23 14:59, Ming Lei wrote:
> [...]
> > > > Will this kind of inconsistency cause trouble for driver? Cause READ
> > > > TWICE becomes possible with this patch.
> > > 
> > > Right it might happen, and I was keeping that in mind, but it's not
> > > specific to this patch. It won't reload core io_uring bits, and all
> > 
> > It depends if driver reloads core bits or not, anyway the patch exports
> > all fields and opens the window.
> 
> If a driver tries to reload core bits and even worse modify io_uring
> request without proper helpers, it should be rooted out and thrown
> into a bin. In any case cmds are expected to exercise cautiousness
> while working with SQEs as they may change. I'd even argue that
> hiding it as void *cmd makes it much less obvious.

Fair enough, if it is well documented, then people will know these
problems and any change in this area can get careful review.


Thanks, 
Ming
