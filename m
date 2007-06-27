From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 27 Jun 2007 08:45:31 +0000
Subject: Re: [PATCH 1/1]: Revert code shifts
Message-Id: <200706270945.32003@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200706171223.21566@strip-the-willow>
In-Reply-To: <200706171223.21566@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

|  > [CCID3]: Revert code shifts
|  >
|  Don't totally agree with this approach but it is a hell of a lot
|  easier than reworking the patches I agree...
|  >
If there are any qualms I'd be happy to go over the patch again and discuss these.
Below are the major differences between code reverted by this patch set and test tree.

Basically, yes, this is the easier (and maybe cleaner) alternative. 

There is overlap between your and Arnaldo's work: I have just gathered all overlap
into one patch and verified afterwards that this combination of above patch plus the
other submitted patches doesn't introduce any other changes.


loss_interval.{c,h}:
==========
 * the patch reverts the following removals
	- struct dccp_li_hist  (became global variable `dccp_li_cachep' in loss_interval.c)
		=> the test tree uses exactly the same approach: static *tfrc_lh_slab
		=> I have now changed the implementation in the test tree to also use __read_mostly
                   This change is in the test-tree patch entitled "[TFRC]: Cache allocation of entries"
                   and the inter-diff to before reads:
			1531c1531
			< +static struct kmem_cache  *tfrc_lh_slab;
			---
			> +static struct kmem_cache  *tfrc_lh_slab  __read_mostly;

	- dccp_li_hist_new()
		=> also removed in test tree, due to the same approach of making slab local to dccp_tfrc_lib

	- struct dccp_li_hist_entry  (became local to loss_interval.c)
		=> this could be done in the test tree, but I don't see the advantages at the moment
		   
	- dccp_li_hist_entry_new()
		=> replaced by on-demand allocation in tfrc_lh_interval_add(), with low-level details hidden

	- dccp_li_hist_interval_new()
		=> integrated with  tfrc_lh_interval_add(), same as with dccp_li_hist_entry_new()

	-  dccp_li_hist_entry_delete()
		=> obsoleted by the use of ringbuffer, connection uses at most NINTERVAL+1=9 entries,
		   all cleanup is at connection end; no memory is required on lossless connections


 * the patch reverts the following additions made by your and Arnaldos work:
	- dccp_li_calc_first_li() => replaced by function pointer call (as discussed earlier on this list),
				     this separates the TFRC / CCID3 interfaces
	- dccp_li_update_li()  => this has been rewritten into  tfrc_lh_interval_add(), with much re-design


 * the patch changes the following which stayed the same in your and Arnaldos work:
	- dccp_li_hist_purge()		=>  becomes  tfrc_lh_cleanup()
	- dccp_li_hist_calc_i_mean()    =>  becomes tfrc_lh_update_i_mean() plus tfrc_lh_calc_i_mean()

	- dccp_li_init()	=> becomes li_init()
	- dccp_li_exit		=> becomes li_cleanup()


ccid3.c:
====
 * removal of ccid3_li_hist is the same in the test tree
 * ccid3_hc_rx_calc_first_li() stays in ccid3.c, but is rewritten into ccid3_first_li()
 * ccid3_hc_rx_update_li() is also removed in the test tree from ccid3.c (cf. above)
 * code that uses dccp_li_update_li() is removed in the test tree, due to use of tfrc_lh_interval_add()
 * module init/exit code has been updated analogously in the test tree
