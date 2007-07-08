From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sun, 08 Jul 2007 11:40:14 +0000
Subject: [PATCH 0/8]: CCID2 fixes + misc
Message-Id: <200707081240.14276@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

A few things that I found while looking at the CCID2 code.

Patch #1: Is a revised version of `allocation in atomic context' fix
          first submitted on http://www.mail-archive.com/dccp@vger.kernel.org/msg01941.html
          I found that there is an implicit assumption on the length of the pre-allocated
          list, which means that the allocation is always the same, which leads to further
          simplification.

Patch #2: Removes an ugly BUG_ON, spotted by Arnaldo, which directly hangs on patch #1.

Patch #3: Removes another BUG_ON, which was found to be redundant.

Patch #4: An entire switch/case block can go - dead code.

Patch #5: Sequence number wraparound issues - updated to use the newer seqno functions.

Patch #6: Spotted an instance of the DIV_ROUND_UP() macro and used it.

Patch #7: follows48() is nowhere used in the DCCP code and thus removed.

Patch #8: Removes redundant initialisation of "memset + assignment of zero". This was also
          spotted by Arnaldo - thanks again.
