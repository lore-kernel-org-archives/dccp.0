From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 19 Dec 2007 14:25:41 +0000
Subject: [DCCP] [RFC] [Patch 0/14]: Ack Vector implementation + fixes
Message-Id: <1198074355-18842-1-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This set of patches adds functionality to the existing DCCP Ack Vector
implementation, extends it to a full circular buffer, and fixes two
previously undiscovered problems which otherwise result in a corrupted
buffer state. 
It is important that Ack Vectors run reliably since otherwise problems in
other parts (in particular CCID2) can not be fixed.

Quite some testing has been performed so that I am almost convinced it is
bug free. To make 100% sure that it contains no further hidden issues
as before, I would like to post this as RFC, to be eventually submitted
next year.


Patch  #1: Fixes the problem that CCID2 ignores Ack Vectors on some packets.
Patch  #2: Adds a tail pointer to the buffer and makes the size configurable.
Patch  #3: Decouples the use of Elapsed Time from the use of Ack Vectors. 
Patch  #4: Provides inlines for Ack Vector state and run length.
Patch  #5: Removes redundancies from the allocation / de-allocation routines.
Patch  #6: Splits Ack Vector specific code from option-specific code.
Patch  #7: Avoids doing unnecessary work when clearing state: the sender of
           Ack Vectors is only interested in the highest-received Ack Number
	   when clearing state. Hence parsing any Ack Vectors for this purpose
	   (which only contain lower Ack Numbers) is entirely unnecessary.
Patch  #8: Replaces #defines for Ack Vector states with enum.
Patch  #9: Provides two extensions required for robustness: overflow handling
           (indicated by a flag) and tracking the lowest-unacknowledged sequence
	   number (tail_ackno)
Patch #10: Inlines for buffer index manipulation, dynamic buffer length calculation.
Patch #11: Implements algorithm to clear buffer state (non-trivial).
Patch #12: Updates the code which registers incoming packets in the buffer.
Patch #13: Aggregates Ack-Vector specific code into one function, thus making it
           easier/simpler for the main DCCP module to use Ack Vectors.
Patch #14: Cleans up old and now unused bits.


The above patches have been uploaded to 

	git://eden-feed.erg.abdn.ac.uk/dccp_exp		[dccp]

but please note that the server will be switched off from 21/12 ... 01/08.

Detailed information and documentation can be found on 
	http://www.erg.abdn.ac.uk/users/gerrit/dccp/notes/ack_vectors/
