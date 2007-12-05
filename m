From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 05 Dec 2007 10:27:36 +0000
Subject: Re: [RFC][PATCHES 0/7]: Reorganization of RX history patches
Message-Id: <20071205102736.GF5177@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <1196631416-17778-1-git-send-email-acme@redhat.com>
In-Reply-To: <1196631416-17778-1-git-send-email-acme@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Today being Wednesday, below is some feedback after working through the patch set.
Hope this is helpful. 

Patch #1:
---------
  Several new good points are introduced:
  - IP_DCCP_TFRC_DEBUG is made dependent on IP_DCCP_TFRC_DEBUG which is useful
  - the select from CONFIG_IP_DCCP_CCID3 => CONFIG_DCCP_TFRC_LIB
  - the cleanup action in tfrc_module_init() (when packet_history_init() fails)
    was previously missing, this is a good catch.
  Also a note: tfrc_pr_debug() is not currently used (but may be later should the 
               code common to both CCID3 and CCID4 be shared).
  		  
Patches #2/#6:
--------------
  Separated from main patch, no problems (were initially submitted in this format).
  I wonder whether switching back to smaller patch sizes is better?

Patch #3: 
---------
  Renames s/tfrc_tx_hist/tfrc_tx_hist_slab/g; no problems.

Patch #4:
---------
  packet_history_init() initialises both RX and TX history and is later called by the module_init()
  function in net/dccp/ccids/lib/tfrc.c. Just a suggestion, it is possible to simplify this further,
  by doing all the initialisation / cleanup in tfrc.c:
    int __init {rx,tx}_packet_history_init()
    {
	    tfrc_{rx,tx}_hist_slab = kmem_cache_create("tfrc_{rx,tx}_hist", ...);
	    return tfrc_{rx,tx}_hist_slab = NULL ? - ENOBUFS : 0;
    }
  and then call these successively in tfrc_module_init().

Patch #5:
---------
  The naming scheme introduced here is 
	  s/dccp_rx/tfrc_rx/g; 
	  s/dccphrx/tfrchrx/g;
  I wonder, while at it, would it be possible to extend this and extend this to other parts
  of the code? Basically this is the same discussion as earlier on dccp@vger with Leandro,
  who first came up with this naming scheme. There the same question came up and the result
  of the discussion was that a prefix of  `tfrchrx' is cryptic; if something simpler is 
  possible then it would be great.

Patch #7:
---------
 * ccid3_hc_rx_detect_loss() can be fully removed since no other code references it any
   further.
 * bytes_recv also counts the payload_size's of non-data packets, which is wrong (it should only
   sum up the sum of bytes transferred as data packets)	 

 * loss handling is not correctly taken care of: unlike in the other part, both data and non-data
   packets are used to detect loss (this is not correctly handled in the current Linux implementation).


 * tfrc_rx_hist_entry_data_packet() is not needed:
   - a similar function, called dccp_data_packet(), was introduced in patch 2/7
   - code compiles cleanly without tfrc_rx_hist_entry_data_packet()
   - all references to this function are deleted by patch 7/7
 * is another header file (net/dccp/ccids/lib/packet_history_internal.h) really necessary?
   - net/dccp/ccids/lib has already 3 x header file, 4 x source file
   - with the removal of tfrc_rx_hist_entry_data_packet(), only struct tfrc_rx_hist_entry
     remains as the sole occupant of that file
   - how about hiding the internals of struct tfrc_rx_hist_entry by putting it into packet_history.c,
     as it was done previously in a similar way for the TX packet history?

 * in ccid3_hc_rx_insert_options(), due to hunk-shifting or something else, there is still the
   call to dccp_insert_option_timestamp(sk, skb)
   --> this was meant to be removed by an earlier patch (which also removed the Elapsed Time option);
   --> in the original submission of this patch the call to dccp_insert_option_timestamp() did no
       longer appear (as can be found in the dccp@vger mailing list archives), and the test tree
       likewise does not use it;
   --> it can be removed with full confidence since no part of the code uses timestamps sent by the
       HC-receiver (only the HC-sender timestamps are used); and it is further not required by the
       spec to send HC-receiver timestamps (RFC 4342, section 6)

 * one of the two variables ccid3hcrx_tstamp_last_feedback and ccid3hcrx_tstamp_last_ack is
   redundant and can be removed (this may be part of a later patch); the variable ccid3hcrx_tstamp_last_feedback
   is very long (function is clear due to type of ktime_t).


 * the inlines are a good idea regarding type safety, but I take it that we can now throw overboard the old rule
   of 80 characters per line? Due to the longer names of the inlines, some expressions end at column 98 (cf. 
   tfrc_rx_hist_sample_rtt(); but to be honest I'd rather get rid of that function since the receiver-RTT
   sampling is notoriously inaccurate (wrong place to measure) and then there is little left to argue with the inlines).

 * with regard to RX history initialisation, would you be amicable to the idea of performing the RX/TX history, and
   loss intervals history in tfrc.c, as suggested for patch 1/7 (shortens the routines)?


 * tfrc_rx_hist_entry is lacking documentation (my fault, had been forgotten in the initial submission):
	/** 
	 * tfrc_rx_hist_entry - Store information about a single received packet
	 * @ptype:   the type (5.1) of the packet
	 ...
	 */
  
 * is it really necessary to give the field members of known structures long names such as
	   tfrc_rx_hist_loss_prev(h)->tfrchrx_seqno?
   This is the same comment as per patch 5/7 and there has been an earlier discussion on dccp@vger where
   other developers (not just me) agreed that such long names are a burden to write; but we could leave that also for later.
