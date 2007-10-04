From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 04 Oct 2007 14:01:41 +0000
Subject: [PATCH 0/5]: Last batch for feature negotiation
Message-Id: <200710041501.41799@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This is the last batch of the feature negotiation set, after which I would like to release it into the test tree.

I hold back another complete batch, which is the use of feature negotiation to dynamically update
Ack Ratio (as per patch#5). The batch itself works; the problem is that the current CCID code is buggy and
thus only works when setting Ack Ratio constantly to 1. Some of the causes seem to be

 * the loss detection is extremely messy and it seems it suffers from sequence number wraparound issues;
 * Ack loss detection is not done at all;
 * when cwnd=1 and ack ratio =2, a timeout results and the connection hangs for 1..3 seconds;
 * dead code in several places.

Hence I think it is better to remain with the current solution and leave Ack Ratio at 1 and treat the 
issues one-by-one, until CCID2 can take Ack Ratio changes more gracefully.


Patch #1: Provides a DCCP-specific wrapper around inet_csk_schedule_ack(), for functions which want to
          signal that they have something urgent (FN option, Ack Vector, Data Dropped, ...) to signal to the peer.

Patch #2: Adds in-kernel API support to register `fast-path' non-negotiable options in established state. Only NN 
          options are supported, since the outcome of SP negotiation is unpredictable unless using singleton values.
          Some further documentation in section 1.2 of 
          http://www.erg.abdn.ac.uk/users/gerrit/dccp/notes/feature_negotiation/implementation_notes.html

Patch #3: Complements patch #2 by adding reception and handling of ChangeL/ConfirmR for NN options.

Patch #4: Minisock becomes unemployed.

Patch #5: Adds a FIXME for making CCID2 cope gracefully with Ack Ratios different than 1 
          which currently it does not). I regret leaving this open, but remember that the whole feature-negotiation
          patch initially resulted from a discussion where we agreed that Ack Ratios should be enabled according to
          which CCID is loaded. These problems are now separate ones.


By the way, although Arnaldo pointed this out as a FIXME almost a full year ago, I think I have found
a solution for the problem of estimating headroom in calculating the MPS. If possible, please have a look
at http://www.erg.abdn.ac.uk/users/gerrit/dccp/notes/misc_notes/estimating_option_sizes_for_MPS.txt
