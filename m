From: Florian Westphal <fw@strlen.de>
Date: Tue, 31 Jul 2018 17:09:57 +0000
Subject: Re: SLAB_TYPESAFE_BY_RCU without constructors (was Re: [PATCH v4 13/17] khwasan: add hooks implement
Message-Id: <20180731170957.o4vhopmzgedpo5sh@breakpoint.cc>
List-Id: <dccp.vger.kernel.org>
References: <e3b48104-3efb-1896-0d46-792419f49a75@virtuozzo.com>
In-Reply-To: <e3b48104-3efb-1896-0d46-792419f49a75@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Andrey Ryabinin <aryabinin@virtuozzo.com> wrote:
> Guys, it seems that we have a lot of code using SLAB_TYPESAFE_BY_RCU cache without constructor.
> I think it's nearly impossible to use that combination without having bugs.
> It's either you don't really need the SLAB_TYPESAFE_BY_RCU, or you need to have a constructor in kmem_cache.
> 
> Could you guys, please, verify your code if it's really need SLAB_TYPSAFE or constructor?
> 
> E.g. the netlink code look extremely suspicious:
> 
> 	/*
> 	 * Do not use kmem_cache_zalloc(), as this cache uses
> 	 * SLAB_TYPESAFE_BY_RCU.
> 	 */
> 	ct = kmem_cache_alloc(nf_conntrack_cachep, gfp);
> 	if (ct = NULL)
> 		goto out;
> 
> 	spin_lock_init(&ct->lock);
> 
> If nf_conntrack_cachep objects really used in rcu typesafe manner, than 'ct' returned by kmem_cache_alloc might still be
> in use by another cpu. So we just reinitialize spin_lock used by someone else?

That would be a bug, nf_conn objects are reference counted.

spinlock can only be used after object had its refcount incremented.

lookup operation on nf_conn object:
1. compare keys
2. attempt to obtain refcount (using _not_zero version)
3. compare keys again after refcount was obtained

if any of that fails, nf_conn candidate is skipped.
