From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sun, 17 Jun 2007 12:51:25 +0000
Subject: [PATCH 0/9]: New TFRC Loss Interval Database & Integration with CCID code
Message-Id: <200706171351.25957@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This patch set realises a new loss intervals database,
updating and extending existing loss handling functionality.

It is also an optimised structure which uses on-demand allocation.

This means that no extra memory is consumed when the link is loss-free.


Patch #1: Introduces the new, ring-buffer based data structure plus a
          few basic inline functions.

Patch #2: Provides accessor functions and macros (OO-like encapsulation).

Patch #3: Allocation/de-allocation routines and initialisation/cleanup routines.

Patch #4: Recomputation of I_mean (new algorithm + revised with regard to RFC 4342).

Patch #5: Insert/update routines for the database.

Patch #6: Integration with RX receiver history structure. This is one of the key
          points in the patch set - loss detection/handling are taken care of by
          the TFRC module (dccp_tfrc_lib) now. This patch integrates the new loss
          intervals structure into the TFRC module.

Patch #7: Let calling module compute first loss interval. TFRC needs a value for
          the first loss interval length as a seed. The problem which we have been
          discussing with this is that this generates a close integration of CCID3
          code with TFRC code. The approach taken here is to separate the interfaces
          by using a function pointer. 
          I believe that this is a useful approach: the calling module (be it CCID3,
          CCID3-FR, CCID4 ...) knows best its own internals - last RTT estimate, last
          time feedback was sent etc; the TFRC module doesn't need to know these details
          and just calls the function via the function pointer to obtain the first
          loss interval length.
          
Patch #8: Fixes and simplifies header includes with regard to the services exported by
          the TFRC module. This has been updated to reflect the recent changes in 
          Arnaldos tree.

Patch #9: And finally ... the integration of the Loss Interval Database with the CCID 3
          code. This is analogous to patch #6; but the difference is that, with regard to
          patch #8, RX history and LI database are no longer separate units, but rather
          a whole which is offered through the TFRC module.


This is almost everything, only one bundle left which I will send tomorrow or after we
have discussed the other things. With the next bundle, the patch set is complete, compiles
and works.
