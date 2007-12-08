From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Sat, 08 Dec 2007 18:52:10 +0000
Subject: [PATCHES 0/3]: DCCP patches for 2.6.25
Message-Id: <1197139933-11609-1-git-send-email-acme@redhat.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hi David,

	Please consider pulling from:

master.kernel.org:/pub/scm/linux/kernel/git/acme/net-2.6.25

Best Regards,

- Arnaldo

 b/net/dccp/ccids/ccid3.c              |   16 ++++++++--------
 b/net/dccp/ccids/lib/loss_interval.c  |    2 +-
 b/net/dccp/ccids/lib/packet_history.c |   13 ++++++-------
 net/dccp/ccids/ccid3.c                |    4 +---
 net/dccp/ccids/lib/packet_history.c   |    6 ------
 5 files changed, 16 insertions(+), 25 deletions(-)
