From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 30 Aug 2010 05:23:09 +0000
Subject: net-2.6 [PATCH 0/5] dccp: ccid-2 clean-up; code sharing between TCP and DCCP
Message-Id: <1283145794-5615-1-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Dave,

please can you have a look at the attached set from the DCCP test tree; it 
tidies up CCID-2 code and implements sharing of code common to TCP and DCCP.

Patch #1: aligns CCID-2 timestamps with those used by TCP.
Patch #2: removes redundant CCID-2 sk-timer functions.
Patch #3: consolidates RFC3390 initial-window code common to TCP and CCID-2 
	  (please note that this still uses the old numbers which have been
	   updated by RFC 5681: I'll send a separate patch documenting that).
Patch #4: shares the minimum-RTO code between TCP and CCID-2.
Patch #5: shares the minimum-RTO code between TCP and CCID-3.

All patches have been tested to compile independently and are at the top of
git://eden-feed.erg.abdn.ac.uk/dccp_exp (subtree 'dccp').
