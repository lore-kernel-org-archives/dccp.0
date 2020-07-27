From: Al Viro <viro@zeniv.linux.org.uk>
Date: Mon, 27 Jul 2020 13:48:14 +0000
Subject: Re: get rid of the address_space override in setsockopt v2
Message-Id: <20200727134814.GD794331@ZenIV.linux.org.uk>
List-Id: <dccp.vger.kernel.org>
References: <20200720124737.118617-1-hch@lst.de>
In-Reply-To: <20200720124737.118617-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Mon, Jul 27, 2020 at 09:51:45AM +0000, David Laight wrote:

> I'm sure there is code that processes options in chunks.
> This probably means it is possible to put a chunk boundary
> at the end of userspace and continue processing the very start
> of kernel memory.
> 
> At best this faults on the kernel copy code and crashes the system.

Really?  Care to provide some details, or is it another of your "I can't
be possibly arsed to check what I'm saying, but it stands for reason
that..." specials?
