From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 25 Jul 2008 09:02:52 +0000
Subject: [net-2.6 PATCH 0/6] dccp: ICMP bug fixes by Wei Yongjun
Message-Id: <1216976578-17767-1-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hi Dave, 

can you please have a look at this set of ICMP/DCCP bug fixes by Wei Yongjun,
augmented by two inter-related test tree patches that solve a related bug.

Patch #1: Provides a way to distinguish original from retransmitted packets.
Patch #2: Fixes a bug - AWL was never updated. Needed by the third patch.
Patch #3: Corrects ICMPv4 sequence number check to use AWL/H instead of SWL/H.
Patch #4: Implements check from patch #3 for ICMPv6.
Patch #5: Fixes an insufficient-length check for 

All patches have been compile-tested, the first two have been in the test
tree for over at least one month.

Can you please consider pulling from

	git://eden-feed.erg.abdn.ac.uk/net-2.6		(subtree `master')

At your discretion, as none of the bugs is severe,

   	git://eden-feed.erg.abdn.ac.uk/net-next-2.6	(subtree `master')

contains the same set of patches. Both trees have been freshly cloned today.	
