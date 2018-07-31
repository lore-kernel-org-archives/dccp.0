From: Christopher Lameter <cl@linux.com>
Date: Tue, 31 Jul 2018 17:36:36 +0000
Subject: Re: SLAB_TYPESAFE_BY_RCU without constructors (was Re: [PATCH v4 13/17] khwasan: add hooks implement
Message-Id: <01000164f169bc6b-c73a8353-d7d9-47ec-a782-90aadcb86bfb-000000@email.amazonses.com>
List-Id: <dccp.vger.kernel.org>
References: <e3b48104-3efb-1896-0d46-792419f49a75@virtuozzo.com>
In-Reply-To: <e3b48104-3efb-1896-0d46-792419f49a75@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Tue, 31 Jul 2018, Andrey Ryabinin wrote:

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

ct may still be read by another cpu in a RCU section but the object was
freed elsewhere so no other processor may modify the object.

The lock must have been released before freeing the slab object and thus
the initialization of the spinlock is unnecessary if it was
initialized in ctor.

If there is refcounting going on then why use SLAB_TYPESAFE_BY_RCU?

