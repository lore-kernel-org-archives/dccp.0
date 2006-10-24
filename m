From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 24 Oct 2006 13:58:51 +0000
Subject: [PATCH 0/17] [DCCP]: patch-backlog, bug-fixes, some code simplifications
Message-Id: <200610241458.51517@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

As promised earlier, this is the set of patches which I have been
keeping up-to-date; they divide into:

	* patches sent to this list that have not been merged
	  [I claim that this is exhaustive, i.e. all other patches
           have been merged - notify me if there is one missing]
	* bug fixes
	* `cosmetic' patches to simplify and consolidate code

The set is consistent in itself and patches on top of the latest davem-2.6
tree, but: all are stacked, i.e. the best way of applying is

	for p in $patches; do git-apply < $p; done

There are no new files introduced, so this works without problem. I have put
in extra time to check / tidy each and every one. I hope that this will pay
off, as I have little benefit from this and had to take this time away from
other commitments.


Gerrit
