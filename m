From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 25 Jul 2011 13:36:29 +0000
Subject: net-next-2.6 [PATCH 0/7] dccp: add support for dynamic parameter updates
Message-Id: <1311600996-6712-1-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hi Dave,

please find attached a 2-part patch set to implement features required by the RFCs:

 a) exchange of "non-negotiable" (NN) feature options (RFC 4340, 6.3.2), which are
    used to dynamically update known parameters during an established connection;
 b) use of this new API to improve the current state of the CCID-2 (RFC 4341)
    implementation for updating Ack Ratio and Sequence Window features.

Both sets are thanks to the good work done by Samuel Jero.    


General DCCP part:
 Patch #1: introduces sender-signalling part for exchange of NN options.
 Patch #2: implements the receiver-side and activation part for NN options.
 Patch #3: bug-fix to send Confirm options in the RFC-specified manner.

CCID-2 part: 
 Patch #4: adds initial code for CCID-2 Ack Ratio exchange.
 Patch #5: fixes issues with cwnd/Sequence Window relationship in CCID-2. 
 Patch #6: fixes a bug in incrementing the cwnd of CCID-2.
 Patch #7: fixes a bug in updating Ack Ratio relative to cwnd in CCID-2.


I have also placed this in into a fresh (today's) copy of net-next-2.6, on

    git://eden-feed.erg.abdn.ac.uk/net-next-2.6        [subtree 'dccp']

---
 ccids/ccid2.c |   88 +++++++++++++++++++------
 ccids/ccid2.h |    6 +
 dccp.h        |    1 
 feat.c        |  202 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
 feat.h        |    1 
 proto.c       |    1 
 6 files changed, 273 insertions(+), 26 deletions(-)
