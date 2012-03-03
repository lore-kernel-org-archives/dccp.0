From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sat, 03 Mar 2012 16:33:51 +0000
Subject: [PATCH 0/2][BUG-FIX] dccp: two bug-fixes
Message-Id: <1330792433-15415-1-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

please find attached two bug fix patches for DCCP.  

 Patch #1: removes a BUG_ON which got triggered under normal operational conditions,
           found that it is not even necessary, hence replaced;
 Patch #2: fixes sequence number handling during initial connection setup, ensuring
           connection establishment even if one or more initial Request(s) get lost.

The patches are also available applied on top of today's net-next, at

	git://eden-feed.erg.abdn.ac.uk/net-next  [subtree 'dccp']

All patches have been tested and compile independently.
---	   
 include/linux/dccp.h   |    8 ++++++--
 net/dccp/ccids/ccid3.c |    3 +--
 net/dccp/ipv4.c        |    8 +++++---
 net/dccp/ipv6.c        |    8 +++++---
 net/dccp/minisocks.c   |   18 +++++++++++-------
 net/dccp/output.c      |   10 +++++-----
 6 files changed, 33 insertions(+), 22 deletions(-)
