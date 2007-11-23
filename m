From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 23 Nov 2007 10:49:29 +0000
Subject: Re: TX history patches was: Re: Test tree patch inventory - update
Message-Id: <20071123104929.GB7983@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <20071122203015.GE17441@ghostprotocols.net>
In-Reply-To: <20071122203015.GE17441@ghostprotocols.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

|         ------------------------------------------------------
|     The patch set migrates TFRC TX history to a singly-linked list.
|     
|     The details are:
|      * use of a consistent naming scheme (all TFRC functions now begin with `tfrc_');
|      * allocation and cleanup are taken care of internally;
|      * provision of a lookup function, which is used by the CCID TX infrastructure
|        to determine the time a packet was sent (in turn used for RTT sampling);
|      * integration of the new interface with the present use in CCID3.
|         ------------------------------------------------------
|     
|     Simplifications I did:
|     
|     . removing the tfrc_tx_hist_head that had a pointer to the list head and
|       another for the slabcache.
|     . No need for creating a slabcache for each CCID that wants to use the TFRC
|       tx history routines, create a single slabcache when the dccp_tfrc_lib module
|       init routine is called.
|     
These two above points are a good job and are useful. Well done. However, you have
added other changes which are not in the above list, where I would like to make two suggestions.

Also did you test this code? The patch on which this is based has been
subjected to some extensive regression-testing. I can't tell if it will
perform as intended.

| --- a/net/dccp/ccids/ccid3.c
| +++ b/net/dccp/ccids/ccid3.c
|  static void ccid3_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
|  {
|  	struct ccid3_hc_tx_sock *hctx = ccid3_hc_tx_sk(sk);
|  	struct ccid3_options_received *opt_recv;
| +	struct tfrc_tx_hist_entry *packet;
|  	ktime_t now;
|  	unsigned long t_nfb;
|  	u32 pinv, r_sample;
| @@ -425,16 +414,19 @@ static void ccid3_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
|  	switch (hctx->ccid3hctx_state) {
|  	case TFRC_SSTATE_NO_FBACK:
|  	case TFRC_SSTATE_FBACK:
| +		/* estimate RTT from history if ACK number is valid */
| +		packet = tfrc_tx_hist_find_entry(hctx->ccid3hctx_hist,
| +						 DCCP_SKB_CB(skb)->dccpd_ack_seq);
| +		if (packet = NULL) {
| +			DCCP_WARN("%s(%p): %s with bogus ACK-%llu\n", dccp_role(sk), sk,
| +				  dccp_packet_name(DCCP_SKB_CB(skb)->dccpd_type),
| +				  (unsigned long long)DCCP_SKB_CB(skb)->dccpd_ack_seq);
|  			return;
|  		}
| +		/*
| +		 * Garbage-collect older (irrelevant) entries
| +		 */
| +		tfrc_tx_hist_purge(&packet->next);
|  
|  		/* Update receive rate in units of 64 * bytes/second */
|  		hctx->ccid3hctx_x_recv = opt_recv->ccid3or_receive_rate;
<snip>
|  		/*
|  		 * Calculate new RTT sample and update moving average
|  		 */
| +		r_sample = dccp_sample_rtt(sk, ktime_us_delta(now, packet->stamp));
|  		hctx->ccid3hctx_rtt = tfrc_ewma(hctx->ccid3hctx_rtt, r_sample, 9);
|  
Sorry but I don't like this at all. 

All the low-level details of the packet_history interface are now again
integrated into ccid3.c, so that ccid3.c ends up doing the job that
packet_history can just as well do:

 * first find the entry
 * then purge all older entries
 * then look into the packet entry to read the timestamp

CCID3 (and for that matter CCID4 also) use the TX history only for a single purpose - to look
up the send time. If there was another method, the entire TX history could go. 

The main intention of this patch set has been to separate more clearly between ccid3.c,
loss_interval.c, and packet_history.c. If RTT measurement is done in the above way, then
we don't gain much from the new patches. And other modules using tfrc_lib, such as CCID4, 
will have to perform the same manual steps all over again (i.e. code duplication).

Can you therefore please consider to keep the function tfrc_hist_when() from the original patch
(or using a similar name).

That function only exposes what CCID3 is interested in - the send time - and takes care of the
low-level detail. With regard to your new interface, it would look like

	int tfrc_tx_hist_when(ktime_t *stamp, struct tfrc_tx_hist_head *head, u64 ackno)
	{
	       struct tfrc_tx_hist_entry *entry = tfrc_tx_find_entry(head, ackno);

	       if (entry != NULL) {
		       *stamp = entry->stamp;
		       tfrc_tx_hist_purge(&entry->next);
		       return 1;
	       }
	       return 0;
	}

One of the main problems in the TFRC/CCID3 code has been (and to some extent still is)
that the code is so deeply intertwined that it is almost impossible to keep functionality separate.

The comment below has the same background, but I suspect that you did
this only as a temporary solution to make the module compile?

| --- a/net/dccp/ccids/lib/loss_interval.c
| +++ b/net/dccp/ccids/lib/loss_interval.c
|
| -static __init int dccp_li_init(void)
| +int __init dccp_li_init(void)

| -static __exit void dccp_li_exit(void)
| +void dccp_li_exit(void)
Here it is declared non-static so that packet_history can call it. 

| --- a/net/dccp/ccids/lib/packet_history.c
| +++ b/net/dccp/ccids/lib/packet_history.c

| +extern int __init dccp_li_init(void);
| +extern void dccp_li_exit(void);
| +
| +static __init int packet_history_init(void)
| +{
| +	if (dccp_li_init() != 0)
| +		goto out;
<snip>
| +static __exit void packet_history_exit(void)
| +{
| +	if (tfrc_tx_hist != NULL) {
| +		kmem_cache_destroy(tfrc_tx_hist);
| +		tfrc_tx_hist = NULL;
| +	}
| +	dccp_li_exit();
| +}
The routine is called `packet_history_init()' and calls an initialisation routine
in a different module (loss_interval.c). It is the same problem again
that loss_interval and packet_history keep being intertwined.

A fix is available a few patches down the line; but more than likely you
already noticed it. The patch introduces a separate source file
tfrc_module.c which calls the individual initialisation routines of the
source files that make up dccp_tfrc_lib:

 tfrc_module_init()
   - calls packet_history_init()
   - calls loss_interval_init()
   - does internal stuff

I think this is clearer, and it is extensible since then there is a dedicated
file for dccp_tfrc_lib which can take up all the code which does not serve one
of the particular purposes 
 * TFRC fixpoint lookup arithmetic (tfrc_equation.c)
 * header includes for TFRC fixpoint arithmetic (tfrc.h)
 * RX history and TX history interface (packet_history.{ch})
 * book-keeping for loss intervals and computing loss event rates (loss_interval.{c,h})
