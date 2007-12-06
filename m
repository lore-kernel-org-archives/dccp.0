From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Thu, 06 Dec 2007 21:02:47 +0000
Subject: [PATCHES 0/7]: DCCP patches for 2.6.25
Message-Id: <1196974974-31531-1-git-send-email-acme@redhat.com>
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

 b/net/dccp/ccids/Kconfig              |   13 
 b/net/dccp/ccids/ccid3.c              |   35 --
 b/net/dccp/ccids/ccid3.h              |   14 
 b/net/dccp/ccids/lib/Makefile         |    2 
 b/net/dccp/ccids/lib/loss_interval.c  |   14 
 b/net/dccp/ccids/lib/packet_history.c |   27 -
 b/net/dccp/ccids/lib/packet_history.h |    3 
 b/net/dccp/ccids/lib/tfrc.c           |   48 +++
 b/net/dccp/ccids/lib/tfrc.h           |   18 -
 b/net/dccp/dccp.h                     |   13 
 net/dccp/ccids/ccid3.c                |  322 ++++++++--------------
 net/dccp/ccids/lib/loss_interval.c    |   13 
 net/dccp/ccids/lib/packet_history.c   |  496 +++++++++++++++++++---------------
 net/dccp/ccids/lib/packet_history.h   |  177 ++++--------
 14 files changed, 579 insertions(+), 616 deletions(-)
