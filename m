From: "Arnaldo Carvalho de Melo" <acme@ghostprotocols.net>
Date: Thu, 10 May 2007 16:21:42 +0000
Subject: Re: [PATCH 2/3] DCCP: Shift code around
Message-Id: <39e6f6c70705100921q1ae680bbi1dae278e4d8b515b@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200705101542.15374.ian.mcdonald@jandi.co.nz>
In-Reply-To: <200705101542.15374.ian.mcdonald@jandi.co.nz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 5/10/07, Ian McDonald <ian.mcdonald@jandi.co.nz> wrote:
> This is just shifting code around and involves no renames except for module
> initialisation. Also add/remove static, includes, EXPORT_SYMBOL_GPL as
> needed. We remove dccp_li_hist_entry_delete as it's not actually used
> anywhere!

Ian,

      Could you please split this up into several patches:

- one that _just_ moves code around, i.e. no code change at all

- another one that moves ccid3_li_hist to
net/dccp/ccids/lib/loss_interval.c and please check this:

---------
[acme@mica net-2.6]$ find net/dccp/  -type f | xargs grep ccid3_li_hist
net/dccp/ccids/ccid3.c: dccp_li_hist_purge(ccid3_li_hist,
&hcrx->ccid3hcrx_li_hist);
net/dccp/ccids/lib/loss_interval.c:struct dccp_li_hist *ccid3_li_hist;
net/dccp/ccids/lib/loss_interval.c:EXPORT_SYMBOL_GPL(ccid3_li_hist);
net/dccp/ccids/lib/loss_interval.c:             if
(!dccp_li_hist_interval_new(ccid3_li_hist,
net/dccp/ccids/lib/loss_interval.c:             entry dccp_li_hist_entry_new(ccid3_li_hist, GFP_ATOMIC);
net/dccp/ccids/lib/loss_interval.c:
kmem_cache_free(ccid3_li_hist->dccplih_slab, tail);
net/dccp/ccids/lib/loss_interval.c:     ccid3_li_hist dccp_li_hist_new("ccid3");
net/dccp/ccids/lib/loss_interval.c:     if (ccid3_li_hist = NULL)
net/dccp/ccids/lib/loss_interval.c:     if (ccid3_li_hist != NULL) {
net/dccp/ccids/lib/loss_interval.c:
dccp_li_hist_delete(ccid3_li_hist);
net/dccp/ccids/lib/loss_interval.c:             ccid3_li_hist = NULL;
net/dccp/ccids/lib/loss_interval.h:extern struct dccp_li_hist *ccid3_li_hist;
[acme@mica net-2.6]$
---------

dccp_li_hist_purge() with your patch becomes the only reason for
ccid3_li_hist to be exported, so please just don't pass it as this
function is _already_ in loss_interval.c where ccid3_li_hist is. Then
make ccid3_li_hist static, unexport it and rename it to dccp_li_hist,
just like all the other code and variables in loss_interval.c.

- then the last one, delete unused functions.

Patches that do many things are always bad for reviewing, sorry.

More comments below, but I'll wait till you do what I suggested for a
more thorough review.

No need to resend the first one in the series, the copyrights one,
I've already applied that to my local tree.

Thanks,

- Arnaldo

<SNIP>

> diff --git a/net/dccp/ccids/lib/loss_interval.c
> b/net/dccp/ccids/lib/loss_interval.c
> index 3829afc..d067d4a 100644
> --- a/net/dccp/ccids/lib/loss_interval.c
> +++ b/net/dccp/ccids/lib/loss_interval.c

<SNIP>

> +static __init int li_module_init(void)
> +{
> +       int rc = -ENOBUFS;
> +
> +       ccid3_li_hist = dccp_li_hist_new("ccid3");
> +       if (ccid3_li_hist = NULL)
> +               return rc;
> +       else
> +               return 0;
> +}

Too convoluted. The rc variable has no reason to exist, please rewrite it as:

static __init int li_module_init(void)
{
        dccp_li_hist = dccp_li_hist_new("ccid3");
        return dccp_li_hist = NULL ? -ENOBUFS : 0;
}

The rename to dccp_li_hist is as suggested above.

<SNIP>
