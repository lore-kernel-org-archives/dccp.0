From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 14 Jul 2011 13:42:28 +0000
Subject: dccp test-tree [RFC] [PATCH 0/7] dccp: dynamic feature negotiation + CCID-2 fixes
Message-Id: <1310650955-5159-1-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

DCCP dynamic feature negotiation and Ack Ratio / Sequence Window update patch set

This submission is just for RFC (request for comments/confirmation).

Patches #1, #2, #4 still need::
 * Signed-off-bys from Samuel (please confirm),
   since he significantly contributed to the improvement of this set;
 * Ian - I have kept your old Acked-by's despite the updates of the
   patches, please can you check if you are still ok with them.
   
Changes have been mostly edits to resolve patch dependencies, and to compile
independently. For reference I have added the commit messages from previous
iterations (these will be removed in the final version).

Please review.

I) The first part concerns negotiating features in established state:
---------------------------------------------------------------------
  Patch #1: part 1/2 of negotiating feature changes in established state.
            => I would like to add Samuel's Signed-off-by here.
  Patch #2: part 2/2 of that set.
            => I would like to add Samuel's Signed-off-by here.
  Patch #3: send Confirm options only once.


II) The second part uses these changes to improve CCID-2:
---------------------------------------------------------
  Patch #4: adds the hooks to update Ack Ratio dynamically, but keeps it
            disabled. Merged with Samuel's patch (=> Signed-off-by please),
	    I just updated the FIXME.
  Patch #5: prevents CCID-2 cwnd > sequence window.
  Patch #6: increment CCID-2 cwnd correctly.
  Patch #7: check ack ratio when reducing cwnd

---
 ccids/ccid2.c |   88 +++++++++++++++++++------
 ccids/ccid2.h |    6 +
 dccp.h        |    1 
 feat.c        |  203 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
 feat.h        |    1 
 proto.c       |    1 
 6 files changed, 274 insertions(+), 26 deletions(-)
