From: Christoph Hellwig <hch@lst.de>
Date: Fri, 07 Aug 2020 07:21:20 +0000
Subject: Re: [PATCH 25/26] net: pass a sockptr_t into ->setsockopt
Message-Id: <20200807072120.GB2086@lst.de>
List-Id: <dccp.vger.kernel.org>
References: <20200723060908.50081-26-hch@lst.de>
In-Reply-To: <20200723060908.50081-26-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Thu, Aug 06, 2020 at 03:21:25PM -0700, Eric Dumazet wrote:
> converting get_user(...)   to  copy_from_sockptr(...) really assumed the optlen
> has been validated to be >= sizeof(int) earlier.
> 
> Which is not always the case, for example here.

Yes.  And besides the bpfilter mess the main reason I even had to add
the sockptr vs just copying optlen in the high-level socket code.

Please take a look at the patch in the other thread to just revert to
the "dumb" version everywhere.
