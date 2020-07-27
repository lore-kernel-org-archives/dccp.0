From: Ido Schimmel <idosch@idosch.org>
Date: Mon, 27 Jul 2020 18:22:59 +0000
Subject: Re: [PATCH 19/26] net/ipv6: switch ipv6_flowlabel_opt to sockptr_t
Message-Id: <20200727182259.GA1931870@shredder>
List-Id: <dccp.vger.kernel.org>
References: <20200723060908.50081-20-hch@lst.de>
In-Reply-To: <20200723060908.50081-20-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Mon, Jul 27, 2020 at 06:15:55PM +0200, Christoph Hellwig wrote:
> I have to admit I didn't spot the difference between the good and the
> bad output even after trying hard..
> 
> But can you try the patch below?
> 
> ---
> From cce2d2e1b43ecee5f4af7cf116808b74b330080f Mon Sep 17 00:00:00 2001
> From: Christoph Hellwig <hch@lst.de>
> Date: Mon, 27 Jul 2020 17:42:27 +0200
> Subject: net: remove sockptr_advance
> 
> sockptr_advance never properly worked.  Replace it with _offset variants
> of copy_from_sockptr and copy_to_sockptr.
> 
> Fixes: ba423fdaa589 ("net: add a new sockptr_t type")
> Reported-by: Jason A. Donenfeld <Jason@zx2c4.com>
> Reported-by: Ido Schimmel <idosch@idosch.org>
> Signed-off-by: Christoph Hellwig <hch@lst.de>

Tested-by: Ido Schimmel <idosch@mellanox.com>

Thanks!
