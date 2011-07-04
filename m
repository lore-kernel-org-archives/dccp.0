From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 04 Jul 2011 19:01:13 +0000
Subject: net-next-2.6 [PATCH 0/6] dccp: several long-tested updates from dccp test tree
Message-Id: <1309806079-21604-1-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Dear Dave,

in the usual slow steps (i.e. only a few patches per week) I would like to
continue submitting the DCCP test tree patches. Most of these have been in
tested for several years, several fix bugs or open issues, some are needed
by subsequent test tree patches.

This set contains several minor fixes and CWV for CCID-2.

  Patch #1: fixes several issues in slow-path input processing.
  Patch #2: refactors common pattern (queueing + cloning) into the same function.
  Patch #3: straightens cosmetics of info message appearing in logs.
  Patch #4: puts frequently used CCID-2 inline function into header file. 
  Patch #5: reuses existing function to test for data packets in CCID-2.
  Patch #6: implements congestion window validation (RFC 2861) in CCID-2.


This set is also available for today's net-next-2.6 at

	git://eden-feed.erg.abdn.ac.uk/net-next-2.6   ==>   subtree "dccp"

---
 net/dccp/ccid.c        |    4 +-
 net/dccp/ccids/ccid2.c |  109 ++++++++++++++++++++++++++++++++++++++----------
 net/dccp/ccids/ccid2.h |   25 +++++++++++-
 net/dccp/input.c       |   61 +++++++++++++--------------
 net/dccp/output.c      |   14 +++---
 5 files changed, 150 insertions(+), 63 deletions(-)
