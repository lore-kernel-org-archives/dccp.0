From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 22 Sep 2008 07:21:52 +0000
Subject: [PATCH 0/5] dccp: Feature negotiation, Part I - Underlying data structures
Message-Id: <1222068117-13401-1-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hi Dave,

please find the first set summarised below.


This is the first set of the feature negotiation patches. These provide a 
self-contained feature negotiation API for the DCCP protocol (RFC 4340-2).

The whole set is structured into 3 main blocks - (1) basis, (2) core,
(3) integration and cleanup. Within these blocks, this is the first,
self-contained, set and its purpose is to provide
 (a) the underlying datastructures
 (b) initialisation and cleanup routines for the new datastructures.

List of patches in this set:
----------------------------
Patch #1: Provides the basic datastructure for feature negotiation. It gets 
          around the problem that feature-negotiation values have no uniform
	  type - they can be 48-bit numbers, single characters, 2-byte integers
	  or a list of unsigned chars.
Patch #2: Provides a lookup-table for the different negotiable features.
Patch #3: Adds list management for the list keeping the negotiation-options.
Patch #4: Initialisation routines (for request sockets and normal sockets).
Patch #5: Analogous to #4, this provides the cleanup routines.	  


The set is also available for viewing online, beginning at
http://eden-feed.erg.abdn.ac.uk/cgi-bin/gitweb.cgi?p=net-next-2.6.git;a=commitdiff;hR3d8569f1200e57d010d8ec0240b931b667ea59

Patch stats:
------------
 include/linux/dccp.h |   13 +-
 net/dccp/dccp.h      |    5 
 net/dccp/feat.c      |  277 +++++++++++++++++++++++++++++++++++++++++++++++++++
 net/dccp/feat.h      |   61 +++++++++++
 net/dccp/input.c     |    2 
 net/dccp/ipv4.c      |    4 
 net/dccp/ipv6.c      |    4 
 net/dccp/minisocks.c |    7 +
 net/dccp/proto.c     |    3 
 9 files changed, 365 insertions(+), 11 deletions(-)
