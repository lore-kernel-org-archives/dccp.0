From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Fri, 06 Apr 2007 03:32:00 +0000
Subject: Re: [PATCH 8/43]: New RX History Step 2 - Initialisation and cleanup
Message-Id: <5640c7e00704052032n17d841f8vc1fd55ee6fda7b48@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200704051633.46816@strip-the-willow>
In-Reply-To: <200704051633.46816@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 4/6/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> [CCID 3]: New RX History Step 2 - Initialisation and cleanup
> +int tfrc_rx_hist_init(struct tfrc_rx_hist *h)
> +{
> +       int i;
> +
> +       for (i = 0; i <= NDUPACK; i++) {
> +               h->ring[i] = kmem_cache_alloc(tfrcxh->dccprxh_slab, GFP_ATOMIC);
> +               if (h->ring[i] = NULL)
> +                       return 1;
> +       }
> +       spin_lock_init(&h->lock);
> +       h->loss_count = 0;
> +       h->loss_start = 0;
> +       return 0;
> +}
> +
> +EXPORT_SYMBOL_GPL(tfrc_rx_hist_init);

Given that you are allocating a fixed size amount of memory which is
known at compile time I think that allocating one block per entry is
the wrong approach and you lose half the value of having it in a ring
buffer as you still have to dereference. This uses more memory to
store each of the pointers and there is a good chance that they may
not be contiguous in memory and thus your cache memory gets more
dirty.

When I started working on the code to remove linked list I was looking
at creating an array of 8 all in one operation when going to be first
used. I also share Eddies comment about the size of this.

NB I'm not saying that this shouldn't go in. I'm just saying this is
not the most efficient.

Ian
-- 
Web: http://wand.net.nz/~iam4/
Blog: http://iansblog.jandi.co.nz
WAND Network Research Group
