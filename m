From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 19 Dec 2006 09:55:46 +0000
Subject: Re: [PATCH 1/1] DCCP: Fix non-conformance to RFC
Message-Id: <200612190955.46805@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200612191436.01509.ian.mcdonald@jandi.co.nz>
In-Reply-To: <200612191436.01509.ian.mcdonald@jandi.co.nz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Quoting Ian McDonald:
|  This works out when to recalculate the loss rate due to significant
|  non-loss interval. We do this at time of recalulating loss rate to save
|  having to do it every packet. Instead we just check if it's time to
|  recalculate. It looked like there was an early attempt to do this but it
|  was quite wrong in its implementation.

|  This patch applies on top of Gerrit's patches.
I had difficulties applying it (cf below).

I have added in the failing hunk by hand and uploaded the file as:
      3_CCID3_recalculate_loss_RFC_McDonald.diff

==> Ian can you please check the uploaded patch and whether that is
     what you wanted? I don't have the time to give it a full testing at 
     the moment, I just came in to check some emails.

|  Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
Acked-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>


|  @@ -384,6 +384,9 @@ static void ccid3_hc_tx_packet_sent(struct sock *sk, int more,
|   	packet->dccphtx_rtt    = hctx->ccid3hctx_rtt;
|   	packet->dccphtx_sent   = 1;
|   	hctx->ccid3hctx_idle   = 0;
|  +
|  +	ccid3_pr_debug("seqno = %llu, rtt = %u\n",
|  +	   (long long unsigned)packet->dccphtx_seqno, packet->dccphtx_rtt);
|   }
Is this statement really necessary - both values appear somewhere else and neither is specific
to ccid3_hc_tx_packet_sent.


|  @@ -158,6 +158,7 @@ enum ccid3_hc_rx_states {
|    *  @ccid3hcrx_s  -  Received packet size in bytes
|    *  @ccid3hcrx_pinv  -  Inverse of Loss Event Rate (RFC 4342, sec. 8.5)
|    *  @ccid3hcrx_elapsed_time  -  Time since packet reception
|  + *  @ccid3hcrx_seq_recalc_loss - when to recalc loss due to non-loss
Would it be possible to use a reference to the RFC section here - the entry is slightly confusing.

The following hunk fails on my computer, 
|  @@ -14,6 +14,7 @@
|   #include <linux/module.h>
|   #include <net/sock.h>
|   #include "../../dccp.h"
|  +#include "../ccid3.h"
|   #include "loss_interval.h"
|   
|   struct dccp_li_hist *dccp_li_hist_new(const char *name)
|  @@ -81,31 +82,106 @@ static const int dccp_li_hist_w[DCCP_LI_HIST_IVAL_F_LENGTH] = {
|   	4, 4, 4, 4, 3, 2, 1, 1,
|   };
|   	list_for_each_entry_safe(li_entry, li_next, list, dccplih_node) {
|   		if (li_entry->dccplih_interval != ~0U) {
=> on my computer it says `li_entry->dccplih_interval != ~0'
I have added the hunk manually to the online version.

