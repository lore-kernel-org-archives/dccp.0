From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sat, 03 Nov 2007 12:03:50 +0000
Subject: [PATCH 0/9]: CCID2 fixes part 2/2
Message-Id: <200711031323.30274@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This is the second part of various fixes / cleanups for CCID2.
Quite a few variables and functions are removed, making it easier
to follow what is going on in the code. This set has been tested
for a while, further progress with CCID2 depends on the Ack Vector
set (which is in the testing phase, but confident that it is coming 
close to being bug-free). 

This set contains:

Patch #1: Disables a broken algorithm for decreasing Ack Ratio which 
          is based on ideas different from the ones in the RFC, is not
          related to the formula introduced there, and hence will decrease
          Ack Ratio unexpectedly and at the wrong times.

Patch #2: Dead code elimination (unused variable).

Patch #3: Read-only variable replaced by constant.

Patch #4: Inline/one-line function replaced by its body (cwnd).

Patch #5: Same as patch #4, but for pipe, obsoletes a BUG_ON.

Patch #6: Removes redundant debugging output (subsumed by other messages).

Patch #7: Removes redundant synchronisation variable.

Patch #8: Removes redundant ack-counting variable.

Patch #9: Misleading comment (false alarm); please see subsequent RFC message.
          
