From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 10 Jun 2008 12:53:36 +0000
Subject: [Patch 0/7] [dccp]: DCCP bug-fixes for net-2.6
Message-Id: <1213102423-27486-1-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hi David,

please consider pulling from

	git://eden-feed.erg.abdn.ac.uk/net-2.6 

This set has bug-fixes only, non-bug fixes will follow at a later stage.

Some test-tree patches need to be reworked with regard to prefix conventions,
will send a request-for-comments later this week to enquire about this.     

Patch #1: Fixes a divide-by-zero bug in CCID-3.
Patch #2: Resolves sparse warnings (gathered from several patches in the tree). 
Patch #3: Enforces that Ack Vectors are not interpreted on request sockets.
Patch #4: Computation error in CCID-3 allowed sending rate.
Patch #5: Sending rate in CCID-3 truncated due to u64 -> u32 conversion.
Patch #6: Typo in initial sequence number assignment.
Patch #7: Bug in the initialisation of v4/v6 request-socket option areas.
