From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 23 Aug 2010 05:41:35 +0000
Subject: netdev-2.6 [PATCH 0/5] dccp: ccid-2/3 code clean up; TCP RTT estimator
Message-Id: <1282542100-5799-1-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Dear Dave,

please would you consider consider the following DCCP CCID-2/3 set (applies to
netdev-2.6): it does code clean-up and adds a better RTO estimation to CCID-2.


Patch #1: aggregates the cosmetic changes (whitespace, documentation etc.).

Patch #2: removes redundant test for CCID block in LISTEN state. As a byproduct
          of integrating the feature-negotiation changeset last year, that test
	  is now redundant, simplifying the code.

Patch #3: removes a sanity-check function from CCID-2 and provides a (lengthy)
	  explanation why this test is indeed redundant.
	  
Patch #4: simplifies and consolidates the code to rearm the CCID-2 RTO timer.

Patch #5: replaces the broken CCID-2 RTT estimator algorithm with a better one
          ('better' means "stolen from the TCP code", this was not done blindly
	   but as a result of testing, it may even be possible to later share
	   the RTT estimation code between TCP and CCID-2).


All patches have been in the test tree at git://eden-feed.erg.abdn.ac.uk 
for more than 2 years and compile independently.
