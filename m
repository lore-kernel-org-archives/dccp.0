From: Jan Kara <jack@suse.cz>
Date: Mon, 06 Aug 2018 20:20:17 +0000
Subject: Re: SLAB_TYPESAFE_BY_RCU without constructors (was Re: [PATCH v4 13/17] khwasan: add hooks implement
Message-Id: <20180806202017.lrzihv42b4mtcgrn@quack2.suse.cz>
List-Id: <dccp.vger.kernel.org>
References: <e3b48104-3efb-1896-0d46-792419f49a75@virtuozzo.com>
In-Reply-To: <e3b48104-3efb-1896-0d46-792419f49a75@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Wed 01-08-18 10:46:35, Dmitry Vyukov wrote:
> I guess it would be useful to have such extensive comment for each
> SLAB_TYPESAFE_BY_RCU use explaining why it is needed and how all the
> tricky aspects are handled.
> 
> For example, the one in jbd2 is interesting because it memsets the
> whole object before freeing it into SLAB_TYPESAFE_BY_RCU slab:
> 
> memset(jh, JBD2_POISON_FREE, sizeof(*jh));
> kmem_cache_free(jbd2_journal_head_cache, jh);
> 
> I guess there are also tricky ways how it can all work in the end
> (type-stable state is only a byte, or we check for all possible
> combinations of being overwritten with JBD2_POISON_FREE). But at first
> sight it does look fishy.

The RCU access is used from a single place:

fs/jbd2/transaction.c: jbd2_write_access_granted()

There are also quite some comments explaining why what it does is safe. The
overwrite by JBD2_POISON_FREE is much older than this RCU stuff (honestly I
didn't know about it until this moment) and has nothing to do with the
safety of RCU access.

								Honza

-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
