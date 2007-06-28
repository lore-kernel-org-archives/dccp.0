From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 28 Jun 2007 14:10:26 +0000
Subject: [PATCH 0/4]: DCCP Miscellany
Message-Id: <200706281510.26899@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This is a small set of miscellaneous DCCP patches which initially
were very early in the test tree. To simplify going through the
patches, they have been deferred until now:

Patch #1: Add socket option to query the current MPS. In the presence of
          `EMSGSIZE' complaints and in the absence of fragmentation, this
	  provides support for querying the current Maximum Packet Size.

Patch #2: Consistently sets all 4 different DCCP debug parameters 
          (dccp_debug, ccid2_debug, tfrc_debug, ccid3_debug) to have type `bool'.

Patch #3: Cures unaligned pointer access. Some non-64 bit quantities are accessed
          not on word boundaries, so that the exception handler is called, which is
          expensive. Using a solution provided by the kernel sources.

Patch #4: Updates API documentation.


Along with the Sync-Flood fixes, these could be considered for general purpose, I'll
put them into the test tree for now.
