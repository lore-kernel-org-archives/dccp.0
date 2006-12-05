From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 05 Dec 2006 20:37:25 +0000
Subject: [PATCH 0/7]: Two more bugs found, finer-grained resolution, time types
Message-Id: <200612052037.25304@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This is a small patch set - and two more bugs busted.

Patch 1: Checks against too large p. This cropped up in a
         discussion a few days ago. In all cases, p < 100%
         as necessary.

Patch 2: Two optimisations for recomputing the sending rate X.

Patch 3: Two bug fixes - both are my own fault (shame :-|),
         twice I did confuse max with min. 

Patch 4: Finer-grained resolution of sending rates. This implements 
         the strategy sent earlier on 
         http://www.mail-archive.com/dccp@vger.kernel.org/msg01040.html

Patch 5: Continues by replacing the remaining calls to usecs_div
         with scaled_div32 (which includes overflow warning).

Patch 6: Simplifies the calculation of fval in reverse-lookup of p.

Patch 7: Changes in almost all cases the storage type for time
         calculations to `signed'. Warning messages against negative
         results (which otherwise would go undetected) are added.
         I think it might be a (useful?) idea to do an analogous
         systematical check for sequence operations [with regard to 
         the strange bug Ian reported where the sequence numbers were
         twisted].
