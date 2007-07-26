From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 26 Jul 2007 12:56:12 +0000
Subject: [PATCH 0/5]: CCID3 update and minor DCCP tidy-ups
Message-Id: <200707261356.12419@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

These are the last 4 patches from my patch set, plus an update
with regard to the CCID3 code. I compile-tested these and 
(#1..#4 have been in my private tree for about 3 months), and 
performed a test run.

Patch #1: Gathers all scattered sysctl variables into the single
          file sysctl.c - they are quite spread out over the code
          and if they are declared `extern' in the header file 
          anyway, using a single file eases to find `where is what'.

Patch #2: For same reasons, minisock initialisation code is moved from
          options.c to minisock.c - where it is more naturally expected.
 
Patch #3: One-liner -- wrong printk format.

Patch #4: Makes Ackvecs non-optional (as in fact they are not really optional).

Patch #5: Reverts the use of `MSS' instead of `s' in the CCID3 code. MSS had 
          been used for a short while in rfc3448bis, but both rfc3448bis and
          the faster restart draft now consistently use `s' - fixed by this patch.
          

It may be possible to further update the code with regard to rfc3448bis, 
but it seems better to wait until the discussion and the specification somewhat 
stabilises.

