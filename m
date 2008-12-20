From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sat, 20 Dec 2008 08:08:02 +0000
Subject: [RFC] [Patch 0/4] dccp: Working prototype of integrating the
Message-Id: <20081220080802.GA3853@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This set addresses the issues in making CCIDs an available part of DCCP.

I am sending this for discussion, it differs in one point from the previous
patch - this set does not keep the module loading and locking code.

The rationale for this is that
 * at the moment there are only 2 fully standardised CCIDs
 * this situation is not likely to change in the foreseeable
   future (RFC progress is very slow, the update of RFC 3448
   for instance took over 1 year and went through 6 revisions)
 * so it would only be research prototypes as candidates for
   the non-builtin case
 * and for this I think we are better off temporarily modifying
   the build process
 * this includes CCID-4, since its Internet draft has expired
   (http://www.ietf.org/internet-drafts/draft-ietf-dccp-ccid4-03.txt)
 * (but for heretics, we still have the "UDP-like" no-op module)

All patches apply on top of Arnaldo's (your) patch to simplify discussion.
Awaiting feedback, please do not apply immediately.

Patch #1: Removes CCID module references that were still around.
Patch #2: Removes the r/w locks around module loading.
Patch #3: Adds a missing ccid_unregister_builtins() function.
Patch #4: Integrates the TFRC library (which is a dependency of
          CCID-3/4) with DCCP, including necessary initialisation.

I have performed testing with this set yesterday, it worked very
well, including module unloading, use of dccp_probe, different links
(WiFi/Ethernet/loopback).

The set is also available via the test tree (git/patch/tarball):

	git://eden-feed.erg.abdn.ac.uk/dccp_exp	[subtree `dccp']
	http://  (same host)
