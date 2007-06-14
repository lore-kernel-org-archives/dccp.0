From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 14 Jun 2007 09:04:34 +0000
Subject: [PATCH 0/5]: Misc CCID3 patches | TFRC separate module | end of first half
Message-Id: <200706141004.34231@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This patch bundle completes the `first round' of the patch set. 

I have put in some work to make it compileable - there is
just one patch interdepence with regard to line 961 - the 
receiver RTT sampling, which is part of the second half of the
patch set.

However, for best results I do recommend applying all patches.

Patch submission will continue with the second half tomorrow; 
this has 21 patches,  so that the `end' can be expected by mid next week.

Comments will be addressed, and if there are no major disagreements,
I'd suggest to place the set into the test tree and make it available 
for pulling - in that way the changes are much easier to see.


Patch #1: CCID3 receiver does not set CCVal - fixed hereby.

Patch #2: Avoids double access of TX history when sending CCID3 feedback,
          removes an unused state and redundant variables in send_feedback(),
          and converts it to use the newer ktime_t interface.
          => This resolves one more dependency in the upgrade to ktime_t.        

Patch #3: Gathers repeated use of test-for-NULL statement into function call.

Patch #4: Update for the wait_for_ccid code (small optimisation)

Patch #5: Creates a central module source file, dccp/ccids/lib/tfrc_module.c,
          as a main file for dccp_tfrc_lib. Previously the module has been 
          assembled from packet_history.c, loss_interval.c, and tfrc_equation.c.
          Since each of these source files serves a distinct purpose, it was
          not clear where module initialisation, cleanup, and module parameters
          are to be stored - done now in this file. Plus a separate tfrc debug macro.
