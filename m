From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 07 Jan 2011 11:35:27 +0000
Subject: net-next-2.6 [PATCH 0/3] dccp: several sequence-number validation fixes
Message-Id: <1294400130-5604-1-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hi Dave,

please find attached 3 bug fixes which recently came up on dccp@vger.

 Patch #1: fixes a bug which wrongly classified sequence-invalid packets. 
 Patch #2: fixes a bug in updating the Greatest Sequence number Received (GSR).
 Patch #3: fixes an inconsistency in setting the sequence window on 32/64 bit.

I have also placed this in into a fresh (today's) copy of net-next-2.6, on

    git://eden-feed.erg.abdn.ac.uk/net-next-2.6        [subtree 'dccp']

---
 Documentation/networking/dccp.txt |    1 +
 net/dccp/dccp.h                   |    3 ++-
 net/dccp/input.c                  |    2 +-
 net/dccp/sysctl.c                 |    4 +++-
 4 files changed, 7 insertions(+), 3 deletions(-)
