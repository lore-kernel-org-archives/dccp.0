From: Arnaldo Carvalho de Melo <acme@mandriva.com>
Date: Thu, 23 Feb 2006 22:12:57 +0000
Subject: [PATCH 0/7][DCCP]: Improvements
Message-Id: <11407327772616-git-send-email-acme@mandriva.com>
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

 b/net/dccp/Makefile  |    7 -
 b/net/dccp/dccp.h    |    6 -
 b/net/dccp/input.c   |    2
 b/net/dccp/ipv4.c    |   26 ----
 b/net/dccp/ipv6.c    |    4
 b/net/dccp/options.c |    2
 b/net/dccp/output.c  |   30 ++++-
 b/net/dccp/proto.c   |  103 +++++++++++++++++++
 b/net/dccp/timer.c   |    3
 net/dccp/dccp.h      |   11 --
 net/dccp/ipv4.c      |  271 +++++++++++++++++++++++++++------------------------
 net/dccp/ipv6.c      |    2
 net/dccp/output.c    |    6 -
 net/dccp/proto.c     |  176 +++++++--------------------------
 14 files changed, 327 insertions(+), 322 deletions(-)

