From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 22 Sep 2008 04:57:44 +0000
Subject: Re: net-next-2.6 [pull-request] [PATCH 0/37] dccp: Revised set of
Message-Id: <20080922045744.GA6889@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <20080901164633.GA6456@gerrit.erg.abdn.ac.uk>
In-Reply-To: <20080901164633.GA6456@gerrit.erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hi Dave,

it has been unfortunate that there had been an error in the submission
of the DCCP feature negotiation patch set.

I would like to return to the submission of the original set of patches,
i.e. those 37 that were discussed and for which fixes had been uploaded.

The changeset provides infrastructure for doing end-to-end feature negotiation,
is self-contained, has been tested for a long while, and is free from
duct-tape fixes.  
(Just for reference - the count of `XXX'-es in the current feat.c is 15,
plus 2 FIXMEs.)

There is a benefit of using this patch set, as it will make it easier
for other people to add code (new CCIDs) to DCCP. 
Only 2 CCIDs exist so far, whose performance and scope is somewhat limited.
There is room for about 250 more CCIDs, for different and completely new
algorithms.

To plug in new CCIDs, feature negotiation at the endpoints is necessary.

The extensions that Arnaldo had suggested are also much easier to
construct with this set. With the present code I think it is nearly impossible.

If you would like to reopen review and discussion, I am willing to address
any further comments.

I have put the set of 37 patches (complete list below) onto a freshly cloned
net-next-2.6 (from today), compile-tested (it is bisectable), and uploaded to

	git://eden-feed.erg.abdn.ac.uk/net-next-2.6 	[subtree `master']

The revised changeset can be also be viewed at:
	http://eden-feed.erg.abdn.ac.uk/cgi-bin/gitweb.cgi?p=net-next-2.6.git


Best regards	
Gerrit


List of patches in this set
---------------------------
Patch #1: Provides the basic datastructure for feature negotiation. It gets 
          around the problem that feature-negotiation values have no uniform
	  type - they can be 48-bit numbers, single characters, 2-byte integers
	  or a list of unsigned chars.
Patch #2: Provides a lookup-table for the different negotiable features.
Patch #3: Adds list management for the list keeping the negotiation-options.
Patch #4: Initialisation routines (for request sockets and normal sockets).
Patch #5: Analogous to #4, this provides the cleanup routines.	  
Patch #6: Changes the existing policy to allow anytime changes as that lead
          to unpredictable results.
Patch #7: Adds registration routines. These form part of the user interface
          and are later used by the socket API to set individual preferences.
Patch #8: CCIDs are a negotiable feature. This patch adds support to query the
          supported CCIDs, so as to advertise only the locally supported ones.
Patch #9: The choice of CCID in turn creates new feature dependencies. The patch
          adds automatic tracking of such dependencies to avoid later failure.

Patch #10: Provides a mechanism to then resolve CCID-dependent features. Since
           CCIDs are a server-priority feature, this is done by the server.
Patch #11: Deprecates old featneg API, as it was dangerous/clumsy.
Patch #12: Support to negotiate checksum-coverage values (as in UDP-Lite).
Patch #13: Deprecates Ack Ratio sysctl, to enable automatic updating.
Patch #14: Tidies up the setsockopt interface for new additions.
Patch #15: Set/getsockopt support to negotiate CCIDs with the peer.
Patch #16: Socket API to query the current CCID from userspace.
Patch #17: Prepares the variable-length htonl/ntohl functions for 48 bits.
           Such a length is needed by e.g. the Sequence Window feature.
Patch #18: Support for DCCP `Mandatory' type options (RFC 4340, 5.8.2).
Patch #19: Routine to insert feature-negotiation header options.
Patch #20: Complements #19, to add feature-negotiation options onto the skb.
Patch #21: Complements #20 and completes the insertion of featneg options.
Patch #22: Logic/algorithm to actually reconcile negotiation options.
Patch #23: Receiver support to process incoming Change L/R options. 
Patch #24: Receiver support to process incoming Confirm R/L options.
Patch #25: Handlers for activating successfully negotiated features.

Patch #26: Integration of dynamic negotiation, part I (socket setup).
Patch #27: Integration of dynamic negotiation, part II (server side).
Patch #28: Integration of dynamic negotiation, part III (client side).

Patch #29: Cleans up the older infrastructure.
Patch #30: Removes obsolete parts of the old CCID interface.
Patch #31: Removes manual intervention on NDP count (now automatic).
Patch #32: Removes Ack Vector sysctl (handled automatically now).

Patch #33: Initialisation framework for the supported features.
Patch #34: Auto-loading of CCID modules so that the modules are available
           when the negotiation is completed.
Patch #35: Adds full support for local/remote Sequence Window.
Patch #36: Initialisation and type-checking of involved sysctls.
Patch #37: A set of (useful) debugging/printing helper functions.
