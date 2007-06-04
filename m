From: "Arnaldo Carvalho de Melo" <acme@ghostprotocols.net>
Date: Mon, 04 Jun 2007 00:07:06 +0000
Subject: Re: [PATCH 1/3] DCCP: Remove dccp_li_hist_entry_delete
Message-Id: <39e6f6c70706031707jf817ebbu110ddc5e1c6ae5a9@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200706041149.45174.ian.mcdonald@jandi.co.nz>
In-Reply-To: <200706041149.45174.ian.mcdonald@jandi.co.nz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 6/3/07, Ian McDonald <ian.mcdonald@jandi.co.nz> wrote:
> This removes dccp_li_hist_entry_delete as it's not used anywhere.

Yes, it is not being used, question is if it should be removed or if
we have to convert the open coded calls to
kmem_cache_free(dccp_li_cachep, entry) to use it, I think we should
use it, its the logical counterpart to dccp_li_hist_entry_new.

That or we kill also dccp_li_entry_new and use kmem_cache_alloc where
it is being used now. I prefer to keep both.

- Arnaldo

>
> Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
> ---
> diff --git a/net/dccp/ccids/lib/loss_interval.c
> b/net/dccp/ccids/lib/loss_interval.c
> index 83b5504..fd9c6d9 100644
> --- a/net/dccp/ccids/lib/loss_interval.c
> +++ b/net/dccp/ccids/lib/loss_interval.c
> @@ -34,12 +34,6 @@ static inline struct dccp_li_hist_entry
> *dccp_li_hist_entry_new(const gfp_t prio
>         return kmem_cache_alloc(dccp_li_cachep, prio);
>  }
>
> -static inline void dccp_li_hist_entry_delete(struct dccp_li_hist_entry
> *entry)
> -{
> -       if (entry != NULL)
> -               kmem_cache_free(dccp_li_cachep, entry);
> -}
> -
>  void dccp_li_hist_purge(struct list_head *list)
>  {
>         struct dccp_li_hist_entry *entry, *next;
> -
> To unsubscribe from this list: send the line "unsubscribe dccp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
