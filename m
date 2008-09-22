From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Mon, 22 Sep 2008 14:10:55 +0000
Subject: Re: [PATCH 1/5] dccp: Basic data structure for feature negotiation
Message-Id: <20080922141055.GA16625@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
References: <1222068117-13401-2-git-send-email-gerrit@erg.abdn.ac.uk>
In-Reply-To: <1222068117-13401-2-git-send-email-gerrit@erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Em Mon, Sep 22, 2008 at 09:21:53AM +0200, Gerrit Renker escreveu:
> This patch prepares for the new and extended feature-negotiation routines.
> 
> The following feature-negotiation data structures are provided:
> 	* a container for the various (SP or NN) values,
> 	* symbolic state names to track feature states,
> 	* an entry struct which holds all current information together,
> 	* elementary functions to fill in and process these structures.
> 
> Entry structs are arranged as FIFO for the following reason: RFC 4340 specifies
> that if multiple options of the same type are present, they are processed in the
> order of their appearance in the packet; which means that this order needs to be
> preserved in the local data structure (the later insertion code also respects
> this order).
> 
> The struct list_head has been chosen for the following reasons: the most
> frequent operations are
>  * add new entry at tail (when receiving Change or setting socket options);
>  * delete entry (when Confirm has been received);
>  * deep copy of entire list (cloning from listening socket onto request socket).
> 
> The NN value has been set to 64 bit, which is a currently sufficient upper limit
> (Sequence Window feature has 48 bit).
> 
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
> Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
> ---
>  net/dccp/feat.c |   14 ++++++++++++
>  net/dccp/feat.h |   60 +++++++++++++++++++++++++++++++++++++++++++++++++++++++
>  2 files changed, 74 insertions(+), 0 deletions(-)
> 
> --- a/net/dccp/feat.c
> +++ b/net/dccp/feat.c
> @@ -23,6 +23,20 @@
>  
>  #define DCCP_FEAT_SP_NOAGREE (-123)
>  
> +/* copy constructor, fval must not already contain allocated memory */
> +static int dccp_feat_clone_sp_val(dccp_feat_val *fval, u8 const *val, u8 len)
> +{
> +	fval->sp.len = len;
> +	if (fval->sp.len > 0) {
> +		fval->sp.vec = kmemdup(val, len, gfp_any());
> +		if (fval->sp.vec = NULL) {
> +			fval->sp.len = 0;
> +			return -ENOBUFS;
> +		}
> +	}
> +	return 0;
> +}
> +
>  int dccp_feat_change(struct dccp_minisock *dmsk, u8 type, u8 feature,
>  		     u8 *val, u8 len, gfp_t gfp)
>  {
> --- a/net/dccp/feat.h
> +++ b/net/dccp/feat.h
> @@ -14,6 +14,66 @@
>  #include <linux/types.h>
>  #include "dccp.h"
>  
> +enum dccp_feat_type {
> +	FEAT_AT_RX   = 1,	/* located at RX side of half-connection  */
> +	FEAT_AT_TX   = 2,	/* located at TX side of half-connection  */
> +	FEAT_SP      = 4,	/* server-priority reconciliation (6.3.1) */
> +	FEAT_NN	     = 8,	/* non-negotiable reconciliation (6.3.2)  */
> +	FEAT_UNKNOWN = 0xFF	/* not understood or invalid feature	  */
> +};
> +
> +enum dccp_feat_state {
> +	FEAT_DEFAULT = 0,	/* using default values from 6.4 */
> +	FEAT_INITIALISING,	/* feature is being initialised  */
> +	FEAT_CHANGING,		/* Change sent but not confirmed yet */
> +	FEAT_UNSTABLE,		/* local modification in state CHANGING */
> +	FEAT_STABLE		/* both ends (think they) agree */
> +};
> +
> +/**
> + * dccp_feat_val  -  Container for SP or NN feature values
> + * @nn:     single NN value
> + * @sp.vec: single SP value plus optional preference list
> + * @sp.len: length of @sp.vec in bytes
> + */
> +typedef union {
> +	u64 nn;
> +	struct {
> +		u8	*vec;
> +		u8	len;
> +	}   sp;
> +} dccp_feat_val;
> +
> +/**
> + * struct feat_entry  -  Data structure to perform feature negotiation
> + * @feat_num: one of %dccp_feature_numbers
> + * @val: feature's current value (SP features may have preference list)
> + * @state: feature's current state
> + * @needs_mandatory: whether Mandatory options should be sent
> + * @needs_confirm: whether to send a Confirm instead of a Change
> + * @empty_confirm: whether to send an empty Confirm (depends on @needs_confirm)
> + * @is_local: feature location (1) or feature-remote (0)
> + * @node: list pointers, entries arranged in FIFO order
> + */
> +struct dccp_feat_entry {
> +	u8                      feat_num;
> +	dccp_feat_val           val;
> +	enum dccp_feat_state    state:8;
> +	bool			needs_mandatory:1,
> +				needs_confirm:1,
> +				empty_confirm:1,
> +				is_local:1;
> +
> +	struct list_head	node;
> +};

As above:

[acme@doppio ~]$ pahole -C dccp_feat_entry dccp
struct dccp_feat_entry {
	u8                    feat_num;             /*     0     1 */

	/* XXX 7 bytes hole, try to pack */

	dccp_feat_val         val;                  /*     8    16 */
	enum dccp_feat_state  state:8;              /*    24:24  4 */

	/* Bitfield combined with next fields */

	_Bool                 needs_mandatory:1;    /*    25: 7  1 */
	_Bool                 needs_confirm:1;      /*    25: 6  1 */
	_Bool                 empty_confirm:1;      /*    25: 5  1 */
	_Bool                 is_local:1;           /*    25: 4  1 */

	/* XXX 4 bits hole, try to pack */
	/* XXX 6 bytes hole, try to pack */

	struct list_head      node;                 /*    32    16 */

	/* size: 48, cachelines: 1, members: 8 */
	/* sum members: 35, holes: 2, sum holes: 13 */
	/* bit holes: 1, sum bit holes: 4 bits */
	/* last cacheline: 48 bytes */
};

In this case, unless you plan to put more stuff into this struct in the
future, using a bitfield for the bool members is a pessimization, as we
will use the same amount of memory and generate more complex code. So I
suggest:

struct dccp_feat_entry {
	dccp_feat_val         val;                  /*     0    16 */
	enum dccp_feat_state  state:8;              /*    16:24  4 */

	/* Bitfield combined with next fields */

	u8                    feat_num;             /*    17     1 */
	_Bool                 needs_mandatory;      /*    18     1 */
	_Bool                 needs_confirm;        /*    19     1 */
	_Bool                 empty_confirm;        /*    20     1 */
	_Bool                 is_local;             /*    21     1 */

	/* XXX 2 bytes hole, try to pack */

	struct list_head      node;                 /*    24    16 */

	/* size: 40, cachelines: 1, members: 8 */
	/* sum members: 38, holes: 1, sum holes: 2 */
	/* last cacheline: 40 bytes */
};

- Arnaldo
