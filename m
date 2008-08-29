From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 29 Aug 2008 05:41:29 +0000
Subject: Re: [PATCH 04/37] dccp: Per-socket initialisation of feature
Message-Id: <20080829054129.GB3557@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <1219945512-7723-5-git-send-email-gerrit@erg.abdn.ac.uk>
In-Reply-To: <1219945512-7723-5-git-send-email-gerrit@erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

| > --- a/include/linux/dccp.h
| > +++ b/include/linux/dccp.h
| > @@ -421,6 +422,7 @@ struct dccp_request_sock {
| >  	__u64			 dreq_iss;
| >  	__u64			 dreq_isr;
| >  	__be32			 dreq_service;
| > +	struct list_head	 dreq_featneg;
| 
| Wouldn't be better to use hlist here? So that we use 8 bytes less per
| struct dccp_request_sock, after all we don't use struct sock while in
| embryonic stage exactly to reduce the footprint at this point in the
| socket lifetime :-)
| 
That may be a possible consideration for future time, but I have doubts
from the feature-negotiation side: true, the feature-negotiation list is
sorted in ascending order, but it is frequently necessary to delete an
entry in the middle or at the end of the list (when a pending Confirm has
arrived), and there may be other parts that need changing.
On the whole, I have tried to use as little space as possible, which
accounts for some of the perhaps non-obvious design decisions.

| > +/* generate @to as full clone of @from - @to must not contain any nodes */
| > +int dccp_feat_clone_list(struct list_head const *from, struct list_head *to)
| > +{
| > +	struct dccp_feat_entry *entry, *new;
| > +
| > +	INIT_LIST_HEAD(to);
| > +	list_for_each_entry(entry, from, node) {
| > +		new = dccp_feat_clone_entry(entry);
| 
| dccp_feat_clone_entry uses kmemdup for a new dccp_feat_entry _and_
| possibly for sp.vec, and goes on adding it to the 'to' list, but if
| one fails you go to cloning_failed: and dccp_feat_list_purge will
| call just dccp_feat_entry_destructor that doesn't frees the
| dccp_feat_entry instances, just the sp.vec. 
| 
| Looks like major leakage, or am I missing something?
| 
Hm, I am beginning to doubt that I have chosen the right granularity for
the patches. Apparently this format is confusing and makes discussion
difficult. Here is the definition, taken from the other patch:

static struct dccp_feat_entry *
              dccp_feat_clone_entry(struct dccp_feat_entry const *original)
{
        struct dccp_feat_entry *new;
        u8 type = dccp_feat_type(original->feat_num);

        if (type = FEAT_UNKNOWN)
                return NULL;

        new = kmemdup(original, sizeof(struct dccp_feat_entry), gfp_any());
        if (new = NULL)
                return NULL;

        if (type = FEAT_SP && dccp_feat_clone_sp_val(&new->val,
                                                      original->val.sp.vec,
                                                      original->val.sp.len)) {
                kfree(new);
                return NULL;
        }
        return new;
}

Now, dccp_feat_clone_entry returns NULL:
 * when the feature is not known - in this case no new memory is allocated;
 * when kmemdup fails 
 * when, for an SP feature, dccp_feat_clone_sp_val fails
So we need to continue with its definition, below:

static int dccp_feat_clone_sp_val(dccp_feat_val *fval, u8 const *val, u8 len)
{
        fval->sp.len = len;
        if (fval->sp.len > 0) {
                fval->sp.vec = kmemdup(val, len, gfp_any());
                if (fval->sp.vec = NULL) {
                        fval->sp.len = 0;
                        return -ENOBUFS;
                }
        }
        return 0;
}

The function returns a non-0 value if kmemdup fails. 

To summarize, I think I have chosen the wrong granularity for the
patches. Sorry, I actually intended to make it easier to spot mistakes.
I thank you for checking through.
