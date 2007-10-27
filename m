From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sat, 27 Oct 2007 11:34:17 +0000
Subject: [PATCH 0/6]: Bug fixes part 1
Message-Id: <200710271234.17427@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

A small batch of bug fixes, all for CCID2 apart from the first one.
I have another small batch of CCID2 fixes and cleanups, which will
be sent next week. All fixes are related to the problem that CCID2
can not currently deal well with Ack Ratios different from 1. To 
fully tackle this, Ack Vectors need a slight upgrade (see below).


Patch #1: Fixes a Feature-Negotiation problem where an Ack was parsed twice.
          I submit this for the record, but would like to merge this patch
          (one-liner) with the one it is supposed to improve: this is the 
          test-tree patch:
          "[DCCP]: Integration of dynamic feature activation - part 3 (client side)"

Patch #2: Fixes a CCID2 bug in parsing Ack Vectors (triggers congestion event).

Patch #3: Fixes sequence number arithmetic in CCID2.

Patch #4: Avoids using negative values for Ack Ratio in assignment.

Patch #5: Tackles the problem of deadlock when cwnd < Ack Ratio.

Patch #6: Larger Initial Windows (RFC 3390) now also for CCID2.


Ack Vector update: The design and initial testing is largely finished, documentation
                   is on http://www.erg.abdn.ac.uk/users/gerrit/dccp/notes/ack_vectors/
