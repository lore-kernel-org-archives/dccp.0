From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 12 Dec 2007 16:56:32 +0000
Subject: Re: [PATCH 8/8] [PATCH v2] [CCID3]: Interface CCID3 code with newer Loss Intervals Database
Message-Id: <20071212165632.GB2282@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <11971083882534-git-send-email-gerrit@erg.abdn.ac.uk>
In-Reply-To: <11971083882534-git-send-email-gerrit@erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

| This time around I'm not doing any reordering, just trying to use your
| patches as is, but adding this patch as-is produces a kernel that will
| crash, no?
| 
| > The loss history and the RX/TX packet history slabs are all created in
| > tfrc.c using the three different __init routines of the dccp_tfrc_lib.
| 
| Yes, the init routines are called and in turn they create the slab
| caches, but up to the patch "[PATCH 8/8] [PATCH v2] [CCID3]: Interface
| CCID3 code with newer Loss Intervals Database" the new li slab is not
| being created, no? See what I'm talking?
| 
Sorry, there is some weird kind of mix-up going on. Can you please check
your patch set: it seems this email exchange refers to an older variant.
In the most recent patch set, the slab is introduced in the patch

	[TFRC]: Ringbuffer to track loss interval history

--- a/net/dccp/ccids/lib/loss_interval.c
+++ b/net/dccp/ccids/lib/loss_interval.c
@@ -27,6 +23,54 @@ struct dccp_li_hist_entry {
        u32              dccplih_interval;
 };

+static struct kmem_cache  *tfrc_lh_slab  __read_mostly;	/* <== */
+/* Loss Interval weights from [RFC 3448, 5.4], scaled by 10 */
+static const int tfrc_lh_weights[NINTERVAL] = { 10, 10, 10, 10, 8, 6, 4, 2 };
// ...

And this is 6/8, i.e. before 8/8, cf.
	http://www.mail-archive.com/dccp@vger.kernel.org/msg03000.html
     
I don't know which tree you are working off, would it be possible to
check against the test tree
	git://eden-feed.erg.abdn.ac.uk/dccp_exp		[dccp]

