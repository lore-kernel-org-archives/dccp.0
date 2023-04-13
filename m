From: Ming Lei <ming.lei@redhat.com>
Date: Thu, 13 Apr 2023 02:56:49 +0000
Subject: Re: [PATCH RFC] io_uring: Pass whole sqe to commands
Message-Id: <ZDdvcSKLa6ZEAhRW@ovpn-8-18.pek2.redhat.com>
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
> 
> Suggested-by: Pavel Begunkov <asml.silence@gmail.com>
> Signed-off-by: Breno Leitao <leitao@debian.org>
> ---

...

> diff --git a/io_uring/uring_cmd.c b/io_uring/uring_cmd.c
> index 2e4c483075d3..9648134ccae1 100644
> --- a/io_uring/uring_cmd.c
> +++ b/io_uring/uring_cmd.c
> @@ -63,14 +63,15 @@ EXPORT_SYMBOL_GPL(io_uring_cmd_done);
>  int io_uring_cmd_prep_async(struct io_kiocb *req)
>  {
>  	struct io_uring_cmd *ioucmd = io_kiocb_to_cmd(req, struct io_uring_cmd);
> -	size_t cmd_size;
> +	size_t size = sizeof(struct io_uring_sqe);
>  
>  	BUILD_BUG_ON(uring_cmd_pdu_size(0) != 16);
>  	BUILD_BUG_ON(uring_cmd_pdu_size(1) != 80);
>  
> -	cmd_size = uring_cmd_pdu_size(req->ctx->flags & IORING_SETUP_SQE128);
> +	if (req->ctx->flags & IORING_SETUP_SQE128)
> +		size <<= 1;
>  
> -	memcpy(req->async_data, ioucmd->cmd, cmd_size);
> +	memcpy(req->async_data, ioucmd->sqe, size);

The copy will make some fields of sqe become READ TWICE, and driver may see
different sqe field value compared with the one observed in io_init_req().

Can this kind of inconsistency cause trouble to driver?

If it isn't one problem, this patch looks fine.

But I guess any access on cmd->sqe in driver may have to be careful for dealing
with potential post-sqe-update.

Thanks,
Ming
