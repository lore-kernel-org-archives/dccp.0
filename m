From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 18 Jun 2007 14:40:30 +0000
Subject: [PATCH 0/3]: The last three
Message-Id: <200706181540.30737@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

These three patches finally complete the set. Yes, it's done.


Patch #1: Makes CCID3 feedback explicit (initial | periodic | parameter-change)
          and makes the estimate of X_recv more reliable in the following combined
          case: (a) loss has occurred already; (b) periodic feedback has been sent.
          In this case, the previously computed value for X_recv is reused (from
          the last periodic feedback), since it has been computed over a longer time
          (one RTT or more); whereas in contrast the time between current feedback
          and the instant of the last periodic feedback is smaller - and hence X_recv
          less accurate.

Patch #2: Removes redundant variable for `p': we use `pinv' exclusively in the CCID3 
          code, and updating both p and pinv for each incoming packet is very expensive.


Patch #3: Update copyrights of CCID3/TFRC files. This has been diffed and `updated'
          with regards to the recent changes in Arnaldos tree.
          

Note: As of now, the whole patch set is available within the experimental test tree, 
      as sub-branch `dccp' on  	git://eden-feed.erg.abdn.ac.uk/dccp_exp

      Detailed instructions how to pull the tree will follow in separate email.
      Patches on this tree will be updated with regard to results of discussions
      on this list, so please test, comment, and contribute.
     
      If you have a recent davem-2.6 tree, you can pull the sub-tree by

        1. checking out a branch `dccp':         git checkout -b dccp master
	2. pulling the subtree into this branch: 
                 git pull git://eden-feed.erg.abdn.ac.uk/dccp_exp.git dccp
           
         
