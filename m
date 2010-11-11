From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 11 Nov 2010 06:07:30 +0000
Subject: net-next-2.6 [PATCH 0/3] dccp: Ack Vectors in circular buffer instead of array
Message-Id: <1289455653-5463-1-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Dave,

please can you consider this set, which is part I of a two-part patch set
to fix issues in the DCCP Ack Vector implementation.

It is a self-contained set to move away from a linear array to a circular
buffer with overflow handling. Part II would then follow next week.


 Patch #1: cleans up the old interface to prepare for the improved one.
 Patch #2: also tidies up the old interface, by separating the internals
           of Ack Vectors from the option-parsing code.
 Patch #3: Completes the implementation of a circular Ack Vector buffer.


I have also placed this in into a fresh (today's) copy of net-next-2.6, on

    git://eden-feed.erg.abdn.ac.uk/net-next-2.6        [subtree 'dccp']

The set has been tested for 3 years, and is fully bisectable.
---
 net/dccp/ackvec.c      |  251 ++++++++++++++++--------------------------------
 net/dccp/ackvec.h      |  115 +++++++++++++----------
 net/dccp/ccids/ccid2.c |   13 +--
 net/dccp/dccp.h        |   11 ++-
 net/dccp/input.c       |    6 +-
 net/dccp/options.c     |   65 ++++++++++++-
 6 files changed, 225 insertions(+), 236 deletions(-)
