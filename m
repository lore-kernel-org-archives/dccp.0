From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sat, 12 Sep 2009 18:32:22 +0000
Subject: Re: [PATCH 1/5] First Patch on TFRC-SP. Copy base files from TFRC
Message-Id: <20090912183222.GA5706@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <cb00fa210909011944o46ba33dbn6d26c69f0a838411@mail.gmail.com>
In-Reply-To: <cb00fa210909011944o46ba33dbn6d26c69f0a838411@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hi Ivo,

you have made a really good job of sticking to code conventions (see other
posting). There are a few things that needed tending to in the first patch.

(1) Version changes
=========It seems that you applied something like s/\*\*/*/g to the first instance of
the patch, in order to remove duplicate asterisks. This caused a problem:

--- tfrc_sp_receiver_01.patch   2009/09/12 08:37:12     1.1
+++ tfrc_sp_receiver_01.patch   2009/09/08 17:34:40
@@ -1001,8 +1001,8 @@ Index: dccp_tree_work4/net/dccp/ccids/li
 +
 +#endif
 +
-+extern int  tfrc_sp_tx_hist_add(struct tfrc_tx_hist_entry **headp, u64 seqno);
-+extern void tfrc_sp_tx_hist_purge(struct tfrc_tx_hist_entry **headp);
++extern int  tfrc_sp_tx_hist_add(struct tfrc_tx_hist_entry *headp, u64 seqno);
++extern void tfrc_sp_tx_hist_purge(struct tfrc_tx_hist_entry *headp);

I have reverted the bug, also to minimise the difference to the existing (non
TFRC-SP) files.


(2) Other changes that I edited out
=================(Other than whitespace changes.)

net/dccp/ccids/lib/loss_interval_sp.c
-------------------------------------
I replaced the following dead code
        if ((tfrc_lh_slab != NULL))
                return 0;

        if (tfrc_lh_slab != NULL) {
                kmem_cache_destroy(tfrc_lh_slab);
                tfrc_lh_slab = NULL;
        }
        return -ENOBUFS;
with 
        return tfrc_lh_slab = NULL ? -ENOBUFS : 0;

Also separated the conditions
+               if ((len <= 0) || 
+                   (!tfrc_lh_closed_check(cur, cong_evt->tfrchrx_ccval))) {
back into 
                if (len <= 0)
                        return false;

                if (!tfrc_lh_closed_check(cur, cong_evt->tfrchrx_ccval))
                        return false;

I removed the following unnecessary inclusion:
+#include <linux/random.h>


The following function pokes a hole in thei so far "abstract" data type;
the convention has been to access the internals of the struct only via
get-functions:

static inline struct tfrc_loss_interval
        *tfrc_lh_get_loss_interval(struct tfrc_loss_hist *lh, const u8 i)
{
        BUG_ON(i >= lh->counter);
        return lh->ring[LIH_INDEX(lh->counter - i - 1)];
}

(You use it in patch 3/5 to gain access to li_ccval and li_losses.
Better would be to have two separate accessor functions.)


net/dccp/ccids/lib/tfrc_equation_sp.c
-------------------------------------
This is a prime candidate for removal. After editing out the whitespace
differences, I found that it is 100% identical with tfrc_equation.c.

The result of this editing has been uploaded to
http://eden-feed.erg.abdn.ac.uk/tfrc_sp_receiver_01.patch
