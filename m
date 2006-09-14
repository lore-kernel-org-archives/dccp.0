From: Arnaldo Carvalho de Melo <acme@mandriva.com>
Date: Thu, 14 Sep 2006 17:05:11 +0000
Subject: [PATCH 0/10][DCCP]: Merge Andrea Bittau CCID2 work
Message-Id: <20060914170511.GA20651@mandriva.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hi David,

   Please consider pulling from:

master.kernel.org:/pub/scm/linux/kernel/git/acme/net-2.6.19.git

Best Regards,

- Arnaldo

 b/net/dccp/ackvec.c      |   12 +--
 b/net/dccp/ackvec.h      |    4 -
 b/net/dccp/ccids/Kconfig |    8 ++
 b/net/dccp/ccids/ccid2.c |   31 ++++++--
 b/net/dccp/ccids/ccid2.h |    2 
 net/dccp/ackvec.c        |    8 --
 net/dccp/ccids/ccid2.c   |  173 ++++++++++++++++++++++++++++++-----------------
 net/dccp/ccids/ccid2.h   |    7 +
 8 files changed, 160 insertions(+), 85 deletions(-)
