From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 21 Mar 2007 18:43:59 +0000
Subject: [PATCH 0/25]: CCID3/TFRC updates, net timestamps, TX locking, bug fixes,
Message-Id: <200703211843.59964@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This is the first lot of patches for CCID3 and TFRC. The second lot
will be submitted subsequently, when a dependency with an earlier
patch has been resolved. 

All patches have been tested for over a month, this particular configuration
has additionally been compile-tested and performance-tested, and uploaded to
     http://www.erg.abdn.ac.uk/users/gerrit/dccp/patch-backlog



		P a t c h   S e t   S u m m a r y
		---------------------------------

Patch 1: Bug fix for CCID3 - avoids that X hits zero (which is not standard-conform
         due to min rate of 1 packet/64 sec; and triggers divide-by-zero exception)

Patch 2: Avoid accumulation of send credits (has been added to rfc3448bis, too).

Patch 3: Yet another `more debug statements' patch.

Patch 4: Cheaper & smaller timestamping; by not computing offsets (see next patches).
         I found it important to reduce the cost of timestamping, since CCID 3 makes
         intensive use of it.

Patch 5: Complete missing documentation for dccp_sock (related to patch #4).

Patch 6: TX timestamping, use net timestamps (i.e. as soon as the packet is received)
         to increase accuracy of timestamping. 

Patch 7: RX timestamping, analogue of patch #6.

Patch 8: Honour initial (from Request/Response exchange) RTT estimate. Having integrated
         using the initial handshake RTT sample, this patch uses the initial seed when
         available.

Patch 9: Make CCID 3 TX feedback reception ignore irrelevant states (further simplification).

Patch 10: Collapse a statement for computing `p' (also a simplification).

Patch 11: Bug fix which corrects setting the `idle' flag after nofeedback timer expiry.

Patch 12: Use t_RTO instead of ccid3hctx_state to test whether any (initial) feedback has been
          received so far. No functional change, but better exploitation of available data.

Patch 13: Match up nofeedback timer handling with rfc3448bis and track state changes
          feedback received (fb. packet arrives) <=> nofeedback (nofeedback timer expires). 
          This makes the internal state machine more realistic: it moves between the states
          NO_FBACK and FBACK, according to which condition holds.

Patch 14: Implements rfc3448bis changes the computation of X when feedback is received.
          (NB: At the time of printing, the changes were correct with regard to rfc3448bis-01.
           The IETF folks keep changing this draft, may have to update at some point, but
           can not track weekly the draft changes. Or we decide to completely ignore all drafts
           and stick rigidly with RFC 3448 / 4342).

Patch 15: Disable softirqs in the transition "send skb in dccp_write_xmit" => "call ccid_hc_tx
          packet_sent". This cured one synchronisation problem I observed in CCID3.

Patch 16: Preparation for using rw_locks on the sender TX history lists. Functions write and
          read on the TX history asynchronously; this retrofits required locks.

Patch 17: TX history locking with analysis when Softirqs should be disabled.

Patch 18: Reduce time when TX lock is held - an optimisation of patch #17.

Patch 19: Remove unused fields from TX packet history structure - now even smaller.

Patch 20: Socket option to query current MPS - a `should' from RFC 4340, easy and useful to have.

Patch 21: Small optimisation for the dccp_wait_for_ccid loop.

Patch 22: Makes all `debug' parameters of type `bool' (since we are not using variable debug levels).

Patch 23: Fix for 64-bit architectures - use `get_unaligned' to avoid `kernel unaligned access' exception.

Patch 24: Macro for moving average - this is so often used in CCID3/TFRC that a macro becomes useful.        

Patch 25: Add a test function dccp_data_packet (the analogue of `dccp_non_data_packet').
