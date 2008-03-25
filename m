From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 25 Mar 2008 16:20:04 +0000
Subject: [DCCP] [Patch 0/7]: Bug-Fixes and Clean-Ups
Message-Id: <1206462011-24907-1-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This set contains bug-fixes and clean-ups.  The first two are already
in the test tree:

Patch #1: Fixes a bug where CCID-3 tries to sample the RTT while the
          history is empty.
	  Leandro - I have added the same bug fix in the CCID-4 tree,
	  just after patch #24.

Patch #2: Deprecates the Ack Ratio sysctl as per earlier discussion.


The following are kept back for the moment, since the first patch is
an RFC patch, and since a lot of the CCID-4 code depends on this:

Patch #3: Continues for consistency the earlier patch which removed the
          long prefixes for CCID-3.
	  Arnaldo - can you please check. Also Leandro, can you also
	  check this - it has implications for CCID-4, too; which is
	  why I have not put it into the test tree immediately.

Patch #4: Fixes two sparse warnings.

Patch #5: Found out that RFC3390 code is identically applied in three
          places (TCP, CCID-2, and CCID-3): this consolidates the
          duplicated code.
          Note: there is a fourth place where this code is duplicated
                (CCID-4), but this needs to be patched separately.

Patch #6: Tidies up the slow-path input processing for DCCP (i.e. input
	  for states other than OPEN). This addresses some reordering
          quirks by putting steps in their RFC4340-like order, ensures
	  that CCID/Ack Vector input is indeed confined to the fast-path,
	  and contains one bug fix.

Patch #7: Removes dead states, thanks to an observation by Leandro and
          his colleagues.
	  Note: This would also need to be ported to CCID-4, since it
	        uses the same (dead) states.

If no one shouts, I will put that into the tree approximately by the end of
the week. In any case it would be good to know if the CCID-4 tree is still
active, since porting these changes will take quite a bit of work.

In particular - patch #5 may be ported to CCID-4 as well, but it depends
on whether people find the code consolidation acceptable.

The first two patches can be obtained in the sets from

 (1) DCCP     git pull dccp://eden-feed.erg.abdn.ac.uk/dccp_exp +dccp:my_dccp
 (2) CCID-4   git pull dccp://eden-feed.erg.abdn.ac.uk/dccp_exp +ccid4:my_ccid4
