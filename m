From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 15 Sep 2010 12:10:20 +0000
Subject: net-next-2.6 [PATCH 0/3] dccp: ccid-3 fixes and simplifications
Message-Id: <1284552623-16283-1-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Dave,

please find attached a set of 3 CCID-3 patches from the test tree.
All have been in the test tree a long time and compile independently.

 Patch #1: Fixes a bug and simplifies the packet scheduling algorithm.
 Patch #2: Replaces buggy RTT sampling history lookup.
 Patch #3: Simplifies the CCID-3 tx-option parsing routine.

This set is also available based on a fresh (today's) copy of net-next-2.6, 

	git://eden-feed.erg.abdn.ac.uk/net-next-2.6  [subtree 'dccp']

