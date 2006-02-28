From: Arnaldo Carvalho de Melo <acme@mandriva.com>
Date: Tue, 28 Feb 2006 22:09:02 +0000
Subject: [PATCH 0/4][DCCP]: Fixes and cleanups
Message-Id: <11411645423360-git-send-email-acme@mandriva.com>
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

 ccids/ccid2.c |   77 +++++------------
 ccids/ccid3.c |   11 +-
 ipv6.c        |  257 +++++++++++++++++++++++++++++-----------------------------
 options.c     |    8 +
 4 files changed, 168 insertions(+), 185 deletions(-)

