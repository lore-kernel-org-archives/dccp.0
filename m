From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 07 Apr 2008 07:46:19 +0000
Subject: Re: compatibility issues
Message-Id: <20080407074619.GF6146@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <200804062210.03693.tomasz@grobelny.oswiecenia.net>
In-Reply-To: <200804062210.03693.tomasz@grobelny.oswiecenia.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

| Recently I switched to the origin/dccp branch of dccp test tree. And noticed 
| that dccp communication between kernel build from origin/dccp branch and 
| kernel build from origin/master branch is not possible. When kernels are from 
| the same branch (no matter if it is origin/dccp or origin/master) the problem 
| does not occur. Is it a known issue?
| -- 
The test tree contains fixes for bugs that are in the mainline kernel
and is thus not bug-compatible with the mainline tree (origin/master).

I can't tell from your description where exactly the communication is "not
possible", but one likely cause is the feature negotiation. This is
definitively broken in origin/master: when setting up the receiver with
CCID-2, and the sender with CCID-3, both will end up using these CCIDs with
correspondingly horrible performance; since the origin/master implementation
performs "feature announcement" rather than "feature negotiation".

The test tree has a full implementation of feature negotiation and will
refuse to start communication if parameters are incompatible. It may
allow communication to an origin/master implementation as long as the
origin/master implementation conforms in its behaviour to  RFC 4340,
section 6. Thus the "communication not possible" is not unconditional.

If you think you have found a bug, please provide more detailed information.


The University of Aberdeen is a charity registered in Scotland, No SC013683.

