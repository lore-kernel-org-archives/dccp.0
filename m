From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 21 Feb 2008 09:09:18 +0000
Subject: [DCCP] [Patch 0/10]: Finish and repair existing Ack Vector implementation
Message-Id: <1203584968-8957-1-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This is a re-packaged resubmission (reduction from about 20 small patches) of the
Ack Vector patch set, which accomplishes two main things.

 First, it completes the implementation of a circular Ack Vector buffer. So far
 the buffer was implemented as a linear array which dropped packets on overflow.

 Second, it makes the Ack Vector implementation workable for Ack Ratios greater
 than 1. The code does not currently work when Ack Ratio is greater than 1.
 
 The reason that existing problems were not observed is that the main module 
 sets Ack Ratio to 1, which in effect bypasses Ack Vectors entirely.
 
 Several bugs with regard to a basic implementation of RFC 4340 Ack Vectors
 were fixed and protections against corrupting buffer state added:
 * successive overlapping Ack Vectors were corrupting buffer state;
 * a protection against outdated entries was missing;
 * a modification was necessary to compute ECN nonces over multiple vectors;
 * reserving entries (one per packet) didn't work well with large burst losses;
 
A summary of the problems that were fixed and full code documentation is on
http://www.erg.abdn.ac.uk/users/gerrit/dccp/notes/ack_vectors/

The code has been tested extensively and has been part of the test tree for over
two months.

Ack Vectors are a necessary requirement of CCID-2, so it expected that CCID-2
can subsequently also be improved.
 
 Short summary
 -------------
 Patch # 1: Fixes an oversight: Ack Vectors need to be ignored as long as
            feature-negotiation is processing.
 Patch # 2: Ack Vector interface clean-up -- preparation for subsequent patches.
 Patch # 3: Separates Ack Vector - specific code from option-inserting code.
 Patch # 4: Completes the implementation of a fully circular Ack Vector buffer. 
 Patch # 5: Adds a tested algorithm to update Ack Vector buffer state.
 Patch # 6: Updates and revises the way new Ack Vector information is registered.
 Patch # 7: Consolidates Ack Vector processing within DCCP main module.
 Patch # 8: Adds a fallback solution - scheduling a Sync when out-of-space.
 Patch # 9: Removes older and now unused parts of the Ack Vector infrastructure.
 Patch #10: Separates the task of parsing Ack Vectors from the CCID(-2) code.

The revised patch set has been uploaded to
	git://eden-feed.erg.abdn.ac.uk/dccp_exp 	[dccp]
