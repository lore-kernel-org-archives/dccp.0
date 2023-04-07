From: Keith Busch <kbusch@kernel.org>
Date: Fri, 07 Apr 2023 18:51:44 +0000
Subject: Re: [PATCH RFC] io_uring: Pass whole sqe to commands
Message-Id: <ZDBmQOhbyU0iLhMw@kbusch-mbp.dhcp.thefacebook.com>
List-Id: <dccp.vger.kernel.org>
References: <20230406165705.3161734-1-leitao@debian.org>
In-Reply-To: <20230406165705.3161734-1-leitao@debian.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Thu, Apr 06, 2023 at 09:57:05AM -0700, Breno Leitao wrote:
> Currently uring CMD operation relies on having large SQEs, but future
> operations might want to use normal SQE.
> 
> The io_uring_cmd currently only saves the payload (cmd) part of the SQE,
> but, for commands that use normal SQE size, it might be necessary to
> access the initial SQE fields outside of the payload/cmd block.  So,
> saves the whole SQE other than just the pdu.
> 
> This changes slighlty how the io_uring_cmd works, since the cmd
> structures and callbacks are not opaque to io_uring anymore. I.e, the
> callbacks can look at the SQE entries, not only, in the cmd structure.
> 
> The main advantage is that we don't need to create custom structures for
> simple commands.

This looks good to me. The only disadvantage I can see is that the async
fallback allocates just a tiny bit more data than before, but no biggie.

Reviewed-by: Keith Busch <kbusch@kernel.org>
 
> @@ -63,14 +63,15 @@ EXPORT_SYMBOL_GPL(io_uring_cmd_done);
>  int io_uring_cmd_prep_async(struct io_kiocb *req)
>  {
>  	struct io_uring_cmd *ioucmd = io_kiocb_to_cmd(req, struct io_uring_cmd);
> -	size_t cmd_size;
> +	size_t size = sizeof(struct io_uring_sqe);
>  
>  	BUILD_BUG_ON(uring_cmd_pdu_size(0) != 16);
>  	BUILD_BUG_ON(uring_cmd_pdu_size(1) != 80);

One minor suggestion. The above is the only user of uring_cmd_pdu_size() now,
which is kind of a convoluted way to enfoce the offset of the 'cmd' field. It
may be more clear to replace these with:

	BUILD_BUG_ON(offsetof(struct io_uring_sqe, cmd) = 48);
  
> -	cmd_size = uring_cmd_pdu_size(req->ctx->flags & IORING_SETUP_SQE128);
> +	if (req->ctx->flags & IORING_SETUP_SQE128)
> +		size <<= 1;
>  
> -	memcpy(req->async_data, ioucmd->cmd, cmd_size);
> +	memcpy(req->async_data, ioucmd->sqe, size);
>  	return 0;
>  }
