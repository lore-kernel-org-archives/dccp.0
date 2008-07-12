From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sat, 12 Jul 2008 14:51:46 +0000
Subject: [PATCH 0/4] dccp: Fixes for TFRC/CCID-3 loss detection
Message-Id: <1215874310-10534-1-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hi Dave,

can you please have a look at this set of fixes.  These address errors which
recently have been found in the TFRC loss detection:

  Patch #1: Fixes an error appearing throughout the TFRC loss detection code.
  Patch #2: Updates the NDP count option to 6 bytes (code was limited to 3).
  Patch #3: Fixes a bug in CCID-3 loss detection (causing false positives).
  Patch #4: Fixes an error in computing the most recent loss interval.

Following your recent suggestions, each patch addresses a single issue only,
and if a patch contains additional (small) changes, these are remarked in
the changelog.

Can you please consider pulling from

	git://eden-feed-erg.abdn.ac.uk/net-2.6		(subtree `master')

At your discretion, since none of the bugs is severe, the set is also on	

	git://eden-feed-erg.abdn.ac.uk/net-next-2.6	(subtree `master')

Both trees have been freshly cloned from today, all patches have been thoroughly
tested. Tests are encouraging - recovery from loss is now much faster.

Thank you.

(The online documentation for the loss detection has also been updated:
 http://www.erg.abdn.ac.uk/users/gerrit/dccp/notes/\
 ccid3/ccid3_packet_reception/loss_detection/loss_detection_algorithm_notes.txt)
