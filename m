From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 29 Jul 2008 14:06:07 +0000
Subject: [RFC/RFT] [PATCH 0/6] dccp ccid-3: Last batch of test-tree updates (sender side)
Message-Id: <1217340373-12620-1-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This is the third and last patch set containing updates for CCID-3. While
the first two focused on the receiver side, this set contains updates
for the sender side. Review and comments are welcome.

Patch #1: Implements rfc3448bis changes to computing the initial sending rate.
Patch #2: Adds support/choice for measuring the packet size `s' wrt. rfc3448bis.
Patch #3: Removes an unused Kconfig statement. 
Patch #4: Simplifies computations for checking the range of t_ipi. 
Patch #5: Implements Oscillation-Reduction as per rfc3448bis, 4.5 
Patch #6: Use sysfs to change debug parameters when module is loaded. 


The now-updated test tree is available via

	git://eden-feed.erg.abdn.ac.uk/dccp_exp		(subtree `dccp')

All changes have been ported to the CCID-4 tree as well and are on

	git://eden-feed.erg.abdn.ac.uk/dccp_exp		(subtree `ccid4')

There is also a web view available. Changes have been tested for both CCID-3/4.
