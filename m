From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 11 Jun 2008 10:36:47 +0000
Subject: [Patch 0/6] [dccp]: DCCP bug-fixes for net-2.6 (revision 01)
Message-Id: <20080611103647.GD8403@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hi David,

please consider the revised set of DCCP Bug-Fix patches
(changelog below), which can be pulled from:

	git://eden-feed.erg.abdn.ac.uk/net-2.6

All patches are in branch `master', on top of a freshly cloned net-2.6 tree.
Result has been compile-tested again.


            List of changes introduced in this submission
            ---------------------------------------------
Relative to yesterday's submission, only these things have changed:
  * rewrote and updated the commit message of the first patch, which was
    referencing a SHA1 ID only. This now has data and commit information added;
  * removed the request-sock initialisation patch, since this has already been
    fixed in your tree.


                     View-ability of changes
                     -----------------------
Since there are no code changes, I omit sending all the patches again. But
the differences can in any case be viewed on
http://eden-feed.erg.abdn.ac.uk/cgi-bin/gitweb.cgi?p=net-2.6.git;a=summary


                List of patches included in this set:
                -------------------------------------
Patch #1: Fixes a divide-by-zero bug in CCID-3.
Patch #2: Resolves sparse warnings (gathered from several patches in the tree).
Patch #3: Enforces that Ack Vectors are not interpreted on request sockets.
Patch #4: Computation error in CCID-3 allowed sending rate.
Patch #5: Sending rate in CCID-3 truncated due to u64 -> u32 conversion.
Patch #6: Typo in initial sequence number assignment.
