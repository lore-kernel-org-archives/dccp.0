From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 12 Oct 2010 05:15:45 +0000
Subject: net-next-2.6 [PATCH 0/6] dccp: miscellaneous fixes and helper functions
Message-Id: <1286860551-6809-1-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Dave,

please can you consider the following set of DCCP patches: the first is a bug
fix, the rest perform refactoring and provide helper functions.

 Patch #1: fixes two problems in the DCCP  (AWL/SWL) window-size adjustment.
 Patch #2: refactors the connect_init() function by combining related code.
 Patch #3: removes an never-user argument from the CCID tx function.
 Patch #4: provides a function to generalize the data-loss condition 
           (patch originally came from the ccid-4 subtree).
 Patch #5: schedules an Ack as carrier for a pending timestamp echo.
 Patch #6: tidies up the format of DCCP per-connection warnings.

The set has also been placed into a fresh (today's) copy of net-next-2.6, on

    git://eden-feed.erg.abdn.ac.uk/net-next-2.6        [subtree 'dccp']

All patches have been in the test tree for a long while and are bisectable.
