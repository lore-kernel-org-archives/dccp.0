From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Fri, 11 May 2007 00:59:45 +0000
Subject: Re: [PATCH 2/3] DCCP: Shift code around
Message-Id: <5640c7e00705101759u68a88da9y3a209660e3bef6e8@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200705101542.15374.ian.mcdonald@jandi.co.nz>
In-Reply-To: <200705101542.15374.ian.mcdonald@jandi.co.nz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 5/11/07, Arnaldo Carvalho de Melo <acme@ghostprotocols.net> wrote:
> On 5/10/07, Ian McDonald <ian.mcdonald@jandi.co.nz> wrote:
> > This is just shifting code around and involves no renames except for module
> > initialisation. Also add/remove static, includes, EXPORT_SYMBOL_GPL as
> > needed. We remove dccp_li_hist_entry_delete as it's not actually used
> > anywhere!
>
> Ian,
>
>       Could you please split this up into several patches:

Working on that at moment. About to post one patch which stands alone OK.

> ---------
> [acme@mica net-2.6]$ find net/dccp/  -type f | xargs grep ccid3_li_hist
> net/dccp/ccids/ccid3.c: dccp_li_hist_purge(ccid3_li_hist,
> &hcrx->ccid3hcrx_li_hist);
> net/dccp/ccids/lib/loss_interval.c:struct dccp_li_hist *ccid3_li_hist;
> net/dccp/ccids/lib/loss_interval.c:EXPORT_SYMBOL_GPL(ccid3_li_hist);
> net/dccp/ccids/lib/loss_interval.c:             if
> (!dccp_li_hist_interval_new(ccid3_li_hist,
> net/dccp/ccids/lib/loss_interval.c:             entry > dccp_li_hist_entry_new(ccid3_li_hist, GFP_ATOMIC);
> net/dccp/ccids/lib/loss_interval.c:
> kmem_cache_free(ccid3_li_hist->dccplih_slab, tail);
> net/dccp/ccids/lib/loss_interval.c:     ccid3_li_hist > dccp_li_hist_new("ccid3");
> net/dccp/ccids/lib/loss_interval.c:     if (ccid3_li_hist = NULL)
> net/dccp/ccids/lib/loss_interval.c:     if (ccid3_li_hist != NULL) {
> net/dccp/ccids/lib/loss_interval.c:
> dccp_li_hist_delete(ccid3_li_hist);
> net/dccp/ccids/lib/loss_interval.c:             ccid3_li_hist = NULL;
> net/dccp/ccids/lib/loss_interval.h:extern struct dccp_li_hist *ccid3_li_hist;
> [acme@mica net-2.6]$
> ---------
>
> dccp_li_hist_purge() with your patch becomes the only reason for
> ccid3_li_hist to be exported, so please just don't pass it as this
> function is _already_ in loss_interval.c where ccid3_li_hist is. Then
> make ccid3_li_hist static, unexport it and rename it to dccp_li_hist,
> just like all the other code and variables in loss_interval.c.

I actually had picked that up but saved it for later.... Was trying
not to overwhelm you with patches but backfired a little ;-)

> Patches that do many things are always bad for reviewing, sorry.

Understand. You said that last time when it was 3, and now it's about
10-15 patches I think after I do this work... I should have learnt by
now!

> No need to resend the first one in the series, the copyrights one,
> I've already applied that to my local tree.

Thanks

> Too convoluted. The rc variable has no reason to exist, please rewrite it as:
>

Done in patches that I will submit next week.

> static __init int li_module_init(void)
> {
>         dccp_li_hist = dccp_li_hist_new("ccid3");
>         return dccp_li_hist = NULL ? -ENOBUFS : 0;
> }
>
> The rename to dccp_li_hist is as suggested above.
>
Also in a later patch set that I will submit next week.

Ian
-- 
Web: http://wand.net.nz/~iam4/
Blog: http://iansblog.jandi.co.nz
WAND Network Research Group
