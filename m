From: Arnaldo Carvalho de Melo <acme@mandriva.com>
Date: Thu, 09 Mar 2006 03:08:08 +0000
Subject: [PATCH 0/5][DCCP]: Improvements
Message-Id: <11418736883636-git-send-email-acme@mandriva.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hi David,

   Please consider pulling from:

master.kernel.org:/pub/scm/linux/kernel/git/acme/net-2.6.17.git

   Mostly tidy-ups done while working on feature negotiation, that is still
under work, to reduce the size of the patch these are going first.

Best Regards,

- Arnaldo

 b/net/dccp/ackvec.c      |   14 +++---
 b/net/dccp/ccid.h        |   18 ++++---
 b/net/dccp/ccids/ccid3.c |   37 ++++++++-------
 b/net/dccp/dccp.h        |    2
 b/net/dccp/ipv4.c        |   11 ++--
 b/net/dccp/ipv6.c        |   23 +++------
 b/net/dccp/options.c     |    3 -
 b/net/dccp/output.c      |   30 ++++++------
 net/dccp/dccp.h          |    8 +--
 net/dccp/ipv4.c          |    9 ---
 net/dccp/ipv6.c          |   10 ----
 net/dccp/options.c       |  109 +++++++++++++++++++----------------------------
 net/dccp/output.c        |   19 ++++++--
 13 files changed, 135 insertions(+), 158 deletions(-)

