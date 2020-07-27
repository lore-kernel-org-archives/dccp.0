From: Christoph Hellwig <hch@lst.de>
Date: Mon, 27 Jul 2020 16:23:57 +0000
Subject: Re: [PATCH 12/26] netfilter: switch nf_setsockopt to sockptr_t
Message-Id: <20200727162357.GA8022@lst.de>
List-Id: <dccp.vger.kernel.org>
References: <20200723060908.50081-13-hch@lst.de>
In-Reply-To: <20200723060908.50081-13-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Mon, Jul 27, 2020 at 06:16:32PM +0200, Jason A. Donenfeld wrote:
> Maybe sockptr_advance should have some safety checks and sometimes
> return -EFAULT? Or you should always use the implementation where
> being a kernel address is an explicit bit of sockptr_t, rather than
> being implicit?

I already have a patch to use access_ok to check the whole range in
init_user_sockptr.
