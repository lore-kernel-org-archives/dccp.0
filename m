From: David Miller <davem@davemloft.net>
Date: Mon, 20 Jul 2020 01:16:59 +0000
Subject: Re: sockopt cleanups
Message-Id: <20200719.181659.1807927650741641565.davem@davemloft.net>
List-Id: <dccp.vger.kernel.org>
References: <20200717062331.691152-1-hch@lst.de>
In-Reply-To: <20200717062331.691152-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Christoph Hellwig <hch@lst.de>
Date: Fri, 17 Jul 2020 08:23:09 +0200

> this series cleans up various lose ends in the sockopt code, most
> importantly removing the compat_{get,set}sockopt infrastructure in favor
> of just using in_compat_syscall() in the few places that care.

Series applied to net-next, thanks.
