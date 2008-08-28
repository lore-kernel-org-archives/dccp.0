From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Thu, 28 Aug 2008 19:43:36 +0000
Subject: Re: [PATCH 03/37] dccp: List management for new feature negotiation
Message-Id: <20080828194336.GJ9193@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
References: <1219945512-7723-4-git-send-email-gerrit@erg.abdn.ac.uk>
In-Reply-To: <1219945512-7723-4-git-send-email-gerrit@erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Em Thu, Aug 28, 2008 at 07:44:38PM +0200, Gerrit Renker escreveu:
> This adds list fields and list management functions for the new feature
> negotiation implementation. The new code is kept in parallel to the old
> code, until removed at the end of the patch set.
> 
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
> Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
> ---
>  net/dccp/feat.c |  129 +++++++++++++++++++++++++++++++++++++++++++++++++++++++
>  1 files changed, 129 insertions(+), 0 deletions(-)
> 
> --- a/net/dccp/feat.c
> +++ b/net/dccp/feat.c
> @@ -147,6 +147,135 @@ static void dccp_feat_entry_destructor(struct dccp_feat_entry *entry)
>  	}
>  }
>  
> +/*
> + *	List management functions
> + */
> +
> +/**
> + * dccp_feat_entry_new  -  Central list update routine (called by all others)
> + * @fn: list to add to
> + * @feat: feature number
> + * @is_local: whether the local (1) or remote feature with number @feat is meant
> + * The function maintains and relies on the following invariants:
> + *  - each feat_num in the list is known, ie. we know its type and default value
> + *  - each feat_num/is_local combination is unique (old entries are overwritten)
> + *  - SP values are always freshly allocated
> + *  - list is sorted in increasing order of feature number (faster lookup)
> + */
> +static struct dccp_feat_entry *
> +	      dccp_feat_entry_new(struct list_head *fn, u8 feat, u8 is_local)
> +{
> +	struct dccp_feat_entry *entry;
> +	struct list_head *pos_head = fn;
> +
> +	list_for_each(pos_head, fn) {
> +		entry = list_entry(pos_head, struct dccp_feat_entry, node);

Why not use list_for_each_entry()?

> +		if (feat < entry->feat_num)
> +			break;
> +		if (entry->feat_num = feat && entry->is_local = is_local) {
> +			dccp_feat_val_destructor(entry->feat_num, &entry->val);

<first reaction>
You call dccp_feat_val_destructor on entry->val, that kfrees a field and
then return it? I havent checked, but would it be safer to set the field
kfree'ed in dccp_feat_val_destructor to NULL since
dccp_feat_val_destructor is not a destructor (i.e. its not the last
function in the life of dccp_feat_val)?

Humm, and shouldn't this entry be removed from the list?
</>

I got confused with a _new routine that ends up not being a constructor
and _destructor being called on an object, then not setting what it
frees to NULL and then reusing it somehow

> +			return entry;
> +		}
> +	}
> +	entry = kmalloc(sizeof(struct dccp_feat_entry), gfp_any());
> +	if (entry != NULL) {
> +		entry->feat_num = feat;
> +		entry->is_local = is_local;
> +		list_add_tail(&entry->node, pos_head);
> +	}
> +	return entry;
> +}
> +
> +static struct dccp_feat_entry *dccp_feat_list_lookup(struct list_head *fn_list,
> +						     u8 feat_num, u8 is_local)
> +{
> +	struct dccp_feat_entry *entry;
> +
> +	list_for_each_entry(entry, fn_list, node)

cool, here you use list_for_each_entry :-)

> +		if (entry->feat_num = feat_num && entry->is_local = is_local)
> +			return entry;
> +		else if (entry->feat_num > feat_num)
> +			break;
> +	return NULL;
> +}

Humm, wouldn't it be better to make the users of dccp_feat_entry_new
call dccp_feat_list_lookup and if it returns NULL call
dccp_feat_entry_new that now would just be what its name implies, i.e. a
constructor, doing just the kmalloc + member init?

> +/**
> + * dccp_feat_push_change  -  Add/overwrite a Change option in the list
> + * @fn_list: feature-negotiation list to update
> + * @feat: one of %dccp_feature_numbers
> + * @local: whether local (1) or remote (0) @feat_num is meant
> + * @needs_mandatory: whether to use Mandatory feature negotiation options
> + * @fval: pointer to NN/SP value to be inserted (will be copied)
> + */
> +static int dccp_feat_push_change(struct list_head *fn_list, u8 feat, u8 local,
> +				 u8 mandatory, dccp_feat_val *fval)
> +{
> +	struct dccp_feat_entry *new = dccp_feat_entry_new(fn_list, feat, local);
> +
> +	if (new = NULL)
> +		return -ENOMEM;
> +
> +	new->feat_num	     = feat;
> +	new->is_local	     = local;
> +	new->state	     = FEAT_INITIALISING;
> +	new->needs_confirm   = 0;
> +	new->empty_confirm   = 0;
> +	new->val	     = *fval;
> +	new->needs_mandatory = mandatory;
> +
> +	return 0;
> +}
> +
> +/**
> + * dccp_feat_push_confirm  -  Add a Confirm entry to the FN list
> + * @fn_list: feature-negotiation list to add to
> + * @feat: one of %dccp_feature_numbers
> + * @local: whether local (1) or remote (0) @feat_num is being confirmed
> + * @fval: pointer to NN/SP value to be inserted or NULL
> + * Returns 0 on success, a Reset code for further processing otherwise.
> + */
> +static int dccp_feat_push_confirm(struct list_head *fn_list, u8 feat, u8 local,
> +				  dccp_feat_val *fval)
> +{
> +	struct dccp_feat_entry *new = dccp_feat_entry_new(fn_list, feat, local);
> +
> +	if (new = NULL)
> +		return DCCP_RESET_CODE_TOO_BUSY;
> +
> +	new->feat_num	     = feat;
> +	new->is_local	     = local;
> +	new->state	     = FEAT_STABLE;	/* transition in 6.6.2 */
> +	new->needs_confirm   = 1;
> +	new->empty_confirm   = (fval = NULL);
> +	new->val.nn	     = 0;		/* zeroes the whole structure */
> +	if (!new->empty_confirm)
> +		new->val     = *fval;
> +	new->needs_mandatory = 0;
> +
> +	return 0;
> +}
> +
> +static int dccp_push_empty_confirm(struct list_head *fn_list, u8 feat, u8 local)
> +{
> +	return dccp_feat_push_confirm(fn_list, feat, local, NULL);
> +}
> +
> +static inline void dccp_feat_list_pop(struct dccp_feat_entry *entry)
> +{
> +	list_del(&entry->node);
> +	dccp_feat_entry_destructor(entry);
> +}

So dccp_feat_entry will always be embedded on other structs? i.e.
dccp_feat_entry_destructor doesn't frees its space, only fields that
points to memory allocated elsewhere

> +void dccp_feat_list_purge(struct list_head *fn_list)
> +{
> +	struct dccp_feat_entry *entry, *next;
> +
> +	list_for_each_entry_safe(entry, next, fn_list, node)
> +		dccp_feat_entry_destructor(entry);
> +	INIT_LIST_HEAD(fn_list);
> +}

Ditto, who frees the struct dccp_feat_entry instances?

- Arnaldo
