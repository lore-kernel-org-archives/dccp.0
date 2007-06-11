From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 11 Jun 2007 12:41:18 +0000
Subject: [PATCH 0/6]: Locking and simplification for TFRC TX history
Message-Id: <200706111341.18240@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This third bundle (3 more to come in this patch set) is largely self-contained
does the following for the TFRC history

  * implements locking
  * removes unused fields (smaller footprint of structure)
  * simplifies to use singly-linked list (suggestion by Arnaldo)

Little is added here, many lines are removed.


Patch #1: Removes two fields, _sent, and _rtt, which are referenced nowhere in the code.

Patch #2: Migration to singly-linked TX history -- introduction of data structures.

Patch #3: Introduction of consistent naming scheme for functions and fields located
          in the dccp_tfrc_lib module: all such objects now start with `tfrc_' prefix.

Patch #4: Allocation (constructor) and de-allocation (destructor) routines for TFRC TX history.

Patch #5: Querying function to look up the send time, lock-protected against concurrent write.

Patch #6: Update CCID3 TX RTT sampling to use ktime_t
          (Ian, this is one of the dependencies: upgrading to ktime_t could only be done
           after introducing the TX history; ccid3_hc_tx_update_x() is resolved subsequently.
