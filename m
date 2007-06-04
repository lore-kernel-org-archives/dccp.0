From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Mon, 04 Jun 2007 01:21:44 +0000
Subject: Re: [PATCH 1/3] DCCP: Remove dccp_li_hist_entry_delete
Message-Id: <5640c7e00706031821j713c8f0eoccb58c3e58bf605c@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200706041149.45174.ian.mcdonald@jandi.co.nz>
In-Reply-To: <200706041149.45174.ian.mcdonald@jandi.co.nz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 6/4/07, Arnaldo Carvalho de Melo <acme@ghostprotocols.net> wrote:
> On 6/3/07, Ian McDonald <ian.mcdonald@jandi.co.nz> wrote:
> > This removes dccp_li_hist_entry_delete as it's not used anywhere.
>
> Yes, it is not being used, question is if it should be removed or if
> we have to convert the open coded calls to
> kmem_cache_free(dccp_li_cachep, entry) to use it, I think we should
> use it, its the logical counterpart to dccp_li_hist_entry_new.
>
> That or we kill also dccp_li_entry_new and use kmem_cache_alloc where
> it is being used now. I prefer to keep both.
>
> - Arnaldo

OK. Will rework in that way.

Ian
-- 
Web: http://wand.net.nz/~iam4/
Blog: http://iansblog.jandi.co.nz
WAND Network Research Group
