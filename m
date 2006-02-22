From: Arnaldo Carvalho de Melo <acme@mandriva.com>
Date: Wed, 22 Feb 2006 21:38:41 +0000
Subject: [PATCH 0/4][DCCP]: Improvements
Message-Id: <11406443213110-git-send-email-acme@mandriva.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hi David,

   Please consider pulling from:

master.kernel.org:/pub/scm/linux/kernel/git/acme/net-2.6.17.git

Best Regards,

P.S.: Testing git-send-email.perl from latest git repo, please let me know
of any bogosity.

- Arnaldo

 include/linux/dccp.h   |   10 ---
 include/linux/sysctl.h |   16 ++++++
 net/dccp/Makefile      |    2
 net/dccp/ccids/Kconfig |    7 +-
 net/dccp/dccp.h        |   14 +++++
 net/dccp/ipv4.c        |   10 +--
 net/dccp/options.c     |   22 ++++----
 net/dccp/proto.c       |    9 +++
 net/dccp/sysctl.c      |  125 ++++++++++++++++++++++++++++++++++++++++++++++++-
 9 files changed, 184 insertions(+), 31 deletions(-)

