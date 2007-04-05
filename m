From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 05 Apr 2007 15:32:52 +0000
Subject: [PATCH 0/43]:  CCID3 fixes / standalone TFRC loss-detection and loss intervals database / DCCP closi
Message-Id: <200704051632.52678@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This is the completion of the CCID3 fixes begun with the last patch set, plus work on DCCP passive-close.
I apologize for the mass of output. On the other hand, it is probably not that much, since I have been
anxious to split each logical change into a separate patch. I have not always managed to eliminate overriding 
by a later one, but tried to avoid this as good as possible.

The patches divide into the following groups, the bulk of work is in II/III. All patches have been uploaded
to http://www.erg.abdn.ac.uk/users/gerrit/dccp/patch-backlog/ , on top of the basic CCID3 patches.

Due to the mass of outstanding patches, I offer to split them into separate directories and create 
separate blocks of descriptions -- please do let me know if you would like to make use of this.

====================================================I. Basic CCID3 Patches
===========

Patch #1: Implements circular modulo-16 arithmetic for working with window counters.

Patch #2: Bug-fix: CCID3 receiver (hc_rx) does not set CCVal window counter.

Patch #3: Remove the redundancy of keeping both p and p_inv = 1/p on the CCID3 socket.
          The socket size shrinks a bit further and the code becomes simpler.

Patch #4: Avoids redundant history access when copying received-packet information over
          to send CCID3 feedback. Simplification and less prone to problems with 
          concurrent access to data structures.

Patch #5: Provide dedicated "tfrc_module.c" source file to mark structure of tfrc_lib;
          and provide the missing "tfrc_pr_debug()" macro for debugging.

====================================================II. New CCID3 RX History Structure |
==================
The RX history structure has been much revised, in particular it has been reduced to a fixed-size rinbuffer
of size 4. This is the minimally required size to perform loss detection. In addition, a more robust form of
receiver-based RTT sampling is also performed on top of this structure.
As a result, more functionality becomes available with simpler code. 

 
Patch #6: New RX history infrastructure - data structures. 

Patch #7: "Glue patch" to allow the transition, using mainly #if 0 ... to allow a transition.
          This patch is entirely overwritten by later patches, but is necessary if people want
          to test just the first 6 patches on their own.

Patch #8: RX history constructor / destructor. 
          NB: I left the old dccp_rx_hist_new() / dccp_rx_hist_delete() in case someone wants to
              build some other RX history in the future; but in fact none of the code uses them now.

Patch #9: Takes care of always-tracking the highest-received sequence number in the new RX structure.


Patch #10: Fallback RTT value from RFC 4340, 4.3. Seems to be an oversight, we need a fallback RTT in
           quite a few cases; this patch adds it for DCCP-wide use; plus update on RTT sanity-check.

Patch #11: Receiver RTT sampling algorithm - I fine-tuned the algorithm from RFC 4342 for robustness.

Patch #12: Integrate new RX history structure with CCID3 packet reception (hc_rx). Now has all the 
           features and checks required by RFC 3448/4342 on receiving a new CCID3 packet.

Patch #13: Add loss detection, complete with handling reordering/late arrival and filling of seqno holes.

Patch #14: Loss detection continued - recycling of loss records under bursts of losses.

Patch #15: Removes the old RX history functions which have been replaced.

====================================================II. New CCID3 Loss Intervals Database Structure |
========================This implements an entirely new loss intervals database which interfaces with the RX history structure.
It is also part of the tfrc_lib module and so has the added benefit that (i) loss detection, (ii)
detection whether a loss is indeed new and (iii) adding a new loss interval record to the LI database
can all be done in one step - as a service provided by the tfrc_lib module.
A nice feature is on-demand allocation, i.e. loss-free connections have very little memory consumption.


Patch #16: Basic ringbuffer structure (just declarations and some inline test/initialisation functions).

Patch #17: Access macros to encapsulate access to the internals of the structure.

Patch #18: Slab cache on-demand allocation and de-allocation. There is one central slab cache which works
           as `array factory' for all clients. No memory is allocated when the connection is loss-free.

Patch #19: Routines for computing and updating I_mean as required by RFC 3448, 6. Since this is a TFRC
           mechanism, it is also provided and exported as a service of the tfrc_lib module.

Patch #20: Insert and Update routines for the LI database, as well as support for CCVal-based decision
           whether a loss is new (using the test from RFC 4342, 10.2).

Patch #21: Makes calculation of first loss interval local to the client of the tfrc_lib module. This is
           better since the caller knows better its own variables.

Patch #22: Integrate the Loss Interval database with RX history so that they can talk to each other.

Patch #23: Fix header #includes so that services exported by tfrc_lib become accessible.

Patch #24: Hook up the new LI database with CCID3.


====================================================III. Miscellaneous CCID3 patches |
=================

Patch #25: Update copyrights - this is Ian's patch. I have added University of Aberdeen; they paid for this work.

Patch #26: Simplifies an often-repeated test for NULL by doing it centrally in the conversion/cast function.

Patch #27: Bug fix - handle CCID3 "Idle and Application-Limited Periods" correctly. This wasn't done correctly
           in the current code. The actual interface is open to debate/modularisation. For now, I have used the
           definition of idleness from rfc3448bis -- found this a useful one.

Patch #28: Bug fix - X_recv was not computed over the last R_m seconds as required by RFC 3448, 6. The solution
           used by this patch also makes the feedback handling more transparent, by using explicit states.

Patch #29: Axe a few chars from the long variable name hcrx->ccid3hcrx_tstamp_last_feedback.


====================================================IV. Work on DCCP States |
============This contains updates to the internal naming and handling of states. It clarifies the interrelation with 
TCP statenames, and adds the two new states PASSIVE_1/PASSIVE_2 which are necessary to handle passive-close
correctly (blurb is on http://www.erg.abdn.ac.uk/users/gerrit/dccp/docs/closing_states/ )
During the past days I have been leaning over backwards to try and make this break. I could not find any
way to create a crashing or sick termination, it terminates cleanly in many settings now. But it could still
be that I missed something, I'd be grateful for any comments and suggestions.


Patch #30: Insert a divider to the DCCP-states enum, to separate specific from general states.

Patch #31: Decouples PARTOPEN from TCP-specific stream-states, as suggested by a FIXME-comment.

Patch #32: Implement dedicated PASSIVE_1/2 states to support passive-close.

Patch #33: Integrate the new states from #32 and add necessary state transitions.

Patch #34: Perform both SHUT_RD and SHUT_WR on close (to respect DCCP's absence of half-close).

Patch #35: When the node is in state CLOSING, no more data is accepted (in the same spirit as #34).

Patch #36: Shift retransmit timer for active-close from proto.c into output.c.

Patch #37: Use the maximum RTO from RFC spec (64 secs instead of TCP 120 sec); another Fixme.

Patch #38: Support for server holding TIMEWAIT state - as in the RFC

Patch #39: Protect against Reset/Sync floods. This will happen when client crashes during connection.

Patch #40: Collapse repeated `len' statements into one.

====================================================IV. Work on DCCP abnormal termination |
===================Some missing bits are added to support active reset when a client crashes or is terminated with a SO_LINGER
time of 0; the API now behaves as in TCP.

Patch #41: Check for unread data on close (same handling now as in TCP).

Patch #42: Implement TCP-like ABORT function.

====================================================V. Last |
====
Patch #43: Update API Documentation.
