From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 15 Dec 2006 10:49:49 +0000
Subject: [PATCH 0/8]: Sequence numbers, larger windows revisited, minor cleanups
Message-Id: <200612151049.50073@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This is a small set of patches, likely the last for this year.
I have run my whitespace test script over them and gave them a
test run (sorry, the sparc64 is not yet up).

Patch 1: Adds the add48/sub48 functions to dccp.h. This was
         inspired by Ian McDonald

Patch 2: Changes dccp_delta_seqno(a, b) to return signed numbers,
         depending on whether a sequence number a is `before' b or not

Patch 3: Makes `before48' unambiguous, following the previous discussions.
         I have kept Arnaldo's basic concept, only the subtraction and
         comparison changes. Thanks to Eddie for discussions. 

Patch 4: Fixes a problem with follows48, solved as a byproduct of dccp_delta_seqno

Patch 5: Moves ccid3_pr_debug into header file so that the macro can be used by
         other files. Thanks to Ian McDonald who raised this.

Patch 6: Removes a now redundant `len' test in ccid3_hc_tx_update_s

Patch 7: Re-orders ccid3.c in a TX/RX section, following the ordering in packet_history.{c,h}

Patch 8: Now uses MSS instead of `s' for larger windows -- and now finally also larger throughput :)

