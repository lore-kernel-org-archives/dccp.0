From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Date: Tue, 31 Jul 2018 17:01:30 +0000
Subject: SLAB_TYPESAFE_BY_RCU without constructors (was Re: [PATCH v4 13/17] khwasan: add hooks implementatio
Message-Id: <e3b48104-3efb-1896-0d46-792419f49a75@virtuozzo.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org


On 07/31/2018 07:04 PM, Andrey Ryabinin wrote:
>> Somewhat offtopic, but I can't understand how SLAB_TYPESAFE_BY_RCU
>> slabs can be useful without ctors or at least memset(0). Objects in
>> such slabs need to be type-stable, but I can't understand how it's
>> possible to establish type stability without a ctor... Are these bugs?
> 
> Yeah, I puzzled by this too. However, I think it's hard but possible to make it work, at least in theory.
> There must be an initializer, which consists of two parts:
> a) initilize objects fields
> b) expose object to the world (add it to list or something like that)
> 
> (a) part must somehow to be ok to race with another cpu which might already use the object.
> (b) part must must use e.g. barriers to make sure that racy users will see previously inilized fields.
> Racy users must have parring barrier of course.
> 
> But it sound fishy, and very easy to fuck up. I won't be surprised if every single one SLAB_TYPESAFE_BY_RCU user
> without ->ctor is bogus. It certainly would be better to convert those to use ->ctor.
> 
> Such caches seems used by networking subsystem in proto_register():
> 
> 		prot->slab = kmem_cache_create_usercopy(prot->name,
> 					prot->obj_size, 0,
> 					SLAB_HWCACHE_ALIGN | SLAB_ACCOUNT |
> 					prot->slab_flags,
> 					prot->useroffset, prot->usersize,
> 					NULL);
> 
> And certain protocols specify SLAB_TYPESAFE_BY_RCU in ->slab_flags, such as:
> llc_proto, smc_proto, smc_proto6, tcp_prot, tcpv6_prot, dccp_v6_prot, dccp_v4_prot.
> 
> 
> Also nf_conntrack_cachep, kernfs_node_cache, jbd2_journal_head_cache and i915_request cache.
> 


[+CC maintainer of the relevant code.]

Guys, it seems that we have a lot of code using SLAB_TYPESAFE_BY_RCU cache without constructor.
I think it's nearly impossible to use that combination without having bugs.
It's either you don't really need the SLAB_TYPESAFE_BY_RCU, or you need to have a constructor in kmem_cache.

Could you guys, please, verify your code if it's really need SLAB_TYPSAFE or constructor?

E.g. the netlink code look extremely suspicious:

	/*
	 * Do not use kmem_cache_zalloc(), as this cache uses
	 * SLAB_TYPESAFE_BY_RCU.
	 */
	ct = kmem_cache_alloc(nf_conntrack_cachep, gfp);
	if (ct = NULL)
		goto out;

	spin_lock_init(&ct->lock);

If nf_conntrack_cachep objects really used in rcu typesafe manner, than 'ct' returned by kmem_cache_alloc might still be
in use by another cpu. So we just reinitialize spin_lock used by someone else?

