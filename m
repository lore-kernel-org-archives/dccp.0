From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 15 Nov 2010 06:29:01 +0000
Subject: net-next-2.6 [PATCH 0/6]: dccp ccid-2: Ack Vector patch set second/concluding part II
Message-Id: <1289802547-5617-1-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hi Dave,

please find attached part II of the Ack Vector patch set, concluding
the submission (part I) begun last week.

 Patch #1: algorithm to update/clear Ack Vector state in the circular buffer.
 Patch #2: algorithm to register new packets as received in the circular buffer.
 Patch #3: consolidates/updates Ack Vector processing in the main DCCP module.
 Patch #4: schedules DCCP-Sync in case there is no space left for Ack Vectors.
 Patch #5: removes the replaced parts of the old Ack Vector infrastructure.
 Patch #6: Ack Vectors provide information specific to CCIDs; this patch thus
           moves Ack Vector processing from main DCCP into the CCID module(s).
 

I have also placed this in into a fresh (today's) copy of net-next-2.6, on

    git://eden-feed.erg.abdn.ac.uk/net-next-2.6        [subtree 'dccp']

The set is fully bisectable.
---
 include/linux/dccp.h   |    2 +
 net/dccp/ackvec.c      |  417 +++++++++++++++++++++++++-----------------------
 net/dccp/ackvec.h      |   38 +++--
 net/dccp/ccids/ccid2.c |  134 +++++-----------
 net/dccp/ccids/ccid2.h |    2 +
 net/dccp/input.c       |   31 +---
 net/dccp/options.c     |   43 ++++--
 net/dccp/output.c      |   15 ++
 8 files changed, 339 insertions(+), 343 deletions(-)
