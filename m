From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sat, 08 Dec 2007 10:06:20 +0000
Subject: [PATCH 0/8] [DCCP]: Updates and fixes to ensure code works with recent changes
Message-Id: <11971083882331-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Some of the recent changes in 2.6.25 cause problems with the existing implementation (i.e. break
the code). This patch set therefore provides fixes and resubmits one subsequent patch which
has not been considered so far, but which is part of the tfrc_lib package.

  Patch #1: Performs whitespace cleanups.
  Patch #2: Migrates all loss interval / packet history initialisation code into tfrc.c.
  Patch #3: Removes two unused functions/function calls that have become obsolete now.
  Patch #4: Splits rx_hist_add_packet() into its original constituents -- they are needed.
  Patch #5: Restores the parts of the macro/inline conversion that broke the algorithm.
  Patch #6: Is a v2 patch - the Loss Intervals code, now updated to work with the recent changes.
  Patch #7: Reverts hiding inlines which are needed by the calling CCID module.
  Patch #8: Also a patch v2 - shows how all the new stuff is integrated to work with CCID3.

The code compiles cleanly, all patches have been uploaded to the test tree (backported from 2.6.25),
  git://eden-feed.erg.abdn.ac.uk/dccp_exp 	[dccp]

So far only a few quick bandwidth tests have been performed. These merely confirm that the stack
does not crash. Since most of this patch set deals with loss detection and re-ordering, some more
detailed tests are needed to ensure that the code, as before, deals well with loss, reordering,
and duplication (this requires at least one NetEm box).

Updates to the CCID4 subtree need to be suspended for a few days. There are too many fiddly changes
all over the place; until we understand exactly what is going on and if there has been a
regression, it is not a good idea to track everything.

