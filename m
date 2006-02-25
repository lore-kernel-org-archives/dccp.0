From: Arnaldo Carvalho de Melo <acme@mandriva.com>
Date: Sat, 25 Feb 2006 21:16:11 +0000
Subject: [PATCH 0/3][DCCP]: Fixes
Message-Id: <1140902171303-git-send-email-acme@mandriva.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hi David,

   Please consider pulling from:

master.kernel.org:/pub/scm/linux/kernel/git/acme/net-2.6.17.git

Best Regards,

- Arnaldo

 b/net/dccp/Kconfig       |    9 ------
 b/net/dccp/ccids/ccid3.c |   10 +++----
 b/net/dccp/dccp.h        |   49 +----------------------------------
 b/net/dccp/input.c       |    7 ++---
 b/net/dccp/ipv4.c        |    3 --
 b/net/dccp/ipv6.c        |   44 ++++++++++++++++++++++++++++---
 b/net/dccp/output.c      |    2 -
 b/net/dccp/proto.c       |   53 +++++++++++++++++++++++++++++++++++++-
 net/dccp/ccids/ccid3.c   |    9 ------
 net/dccp/dccp.h          |    4 --
 net/dccp/ipv4.c          |   65 ++++++++++++++++++++---------------------------
 net/dccp/proto.c         |    7 +----
 12 files changed, 136 insertions(+), 126 deletions(-)

