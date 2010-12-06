From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 06 Dec 2010 07:44:02 +0000
Subject: net-next-2.6 [PATCH 0/2] dccp: Policy-based packet dequeueing interface
Message-Id: <1291621444-5927-1-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hi Dave,

please find attached a self-contained 2-patch set by Tomasz which adds an API
to influence DCCP packet dequeueing. It evolved from discussions in 2008,
adding and adds basic building blocks for sending congestion controlled
multimedia packets that have a priority or a deadline attached to them.

Occasionally people still make new suggestions for such an API, apparently
overlooking the excellent work Tomasz has done and which has been in the
test tree for two years.

 Patch #1: introduces the new policy-based packet dequeueing infrastructure.
 Patch #2: adds parameter (sanity) checking of cmsg qpolicy parameters.

I have also placed this in into a fresh (today's) copy of net-next-2.6, on

    git://eden-feed.erg.abdn.ac.uk/net-next-2.6        [subtree 'dccp']

The set is fully bisectable.
---
 Documentation/networking/dccp.txt |   20 ++++++
 include/linux/dccp.h              |   21 ++++++
 net/dccp/Makefile                 |    4 +-
 net/dccp/dccp.h                   |   13 ++++
 net/dccp/output.c                 |    7 +-
 net/dccp/proto.c                  |   71 ++++++++++++++++++-
 net/dccp/qpolicy.c                |  137 +++++++++++++++++++++++++++++++++++++
 7 files changed, 264 insertions(+), 9 deletions(-)
