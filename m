From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Mon, 18 Jan 2010 13:39:19 +0000
Subject: Re: [PATCH] dccp: fix dccp rmmod when kernel configured to use slub
Message-Id: <20100118133919.GA14636@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
References: <20100118031611.GA2221@localhost.localdomain>
In-Reply-To: <20100118031611.GA2221@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Em Sun, Jan 17, 2010 at 10:16:12PM -0500, Neil Horman escreveu:
> Hey all-
> 	I was tinkering with dccp recently and noticed that I BUG halted the
> kernel when I rmmod-ed the dccp module.  The bug halt occured because the page
> that I passed to kfree failed the PageCompound and PageSlab test in the slub
> implementation of kfree.  I tracked the problem down to the following set of
> events:
> 
> 1) dccp, unlike all other uses of kmem_cache_create, allocates a string
> dynamically when registering a slab cache.  This allocated string is freed when
> the cache is destroyed.
> 
> 2) Normally, (1) is not an issue, but when Slub is in use, it is possible that
> caches are 'merged'.  This process causes multiple caches of simmilar
> configuration to use the same cache data structure.  When this happens, the new
> name of the cache is effectively dropped.
> 
> 3) (2) results in kmem_cache_name returning an ambigous value (i.e.
> ccid_kmem_cache_destroy, which uses this fuction to retrieve the name pointer
> for freeing), is no longer guaranteed that the string it assigned is what is
> returned. 
> 
> 4) If such merge event occurs, ccid_kmem_cache_destroy frees the wrong pointer,
> which trips over the BUG in the slub implementation of kfree (since its likely
> not a slab allocation, but rather a pointer into the static string table
> section.
> 
> So, what to do about this.  At first blush this is pretty clearly a leak in the
> information that slub owns, and as such a slub bug.  Unfortunately, theres no
> really good way to fix it, without exposing slub specific implementation details
> to the generic slab interface.  Also, even if we could fix this in slub cleanly,
> I think the RCU free option would force us to do lots of string duplication, not
> only in slub, but in every slab allocator.  As such, I'd like to propose this
> solution.  Basically, I just move the storage for the kmem cache name to the
> ccid_operations structure.  In so doing, we don't have to do the kstrdup or
> kfree when we allocate/free the various caches for dccp, and so we avoid the
> problem, by storing names with static memory, rather than heap, the way all
> other calls to kmem_cache_create do.
> 
> I've tested this out myself here, and it solves the problem quite well.
> 
> Neil
> 
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>

Looks sane, from visual inspection you have my

Acked-by: Arnaldo Carvalho de Melo <acme@redhat.com>

Thanks!

- Arnaldo
