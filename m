From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Wed, 12 Dec 2007 16:36:46 +0000
Subject: [PATCHES 0/7]: DCCP patches for 2.6.25
Message-Id: <1197477413-1456-1-git-send-email-acme@redhat.com>
List-Id: <dccp.vger.kernel.org>
References: <1196974974-31531-1-git-send-email-acme@redhat.com>
In-Reply-To: <1196974974-31531-1-git-send-email-acme@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hi David,

	Please consider pulling from:

master.kernel.org:/pub/scm/linux/kernel/git/acme/net-2.6.25

Best Regards,

- Arnaldo

 b/net/dccp/ccids/ccid3.c              |    2 
 b/net/dccp/ccids/ccid3.h              |    5 
 b/net/dccp/ccids/lib/loss_interval.c  |  161 ++++++++++++++++++-
 b/net/dccp/ccids/lib/loss_interval.h  |   56 ++++++
 b/net/dccp/ccids/lib/packet_history.c |   68 +++-----
 b/net/dccp/ccids/lib/packet_history.h |   36 ++++
 b/net/dccp/ccids/lib/tfrc.c           |   32 ++-
 b/net/dccp/ccids/lib/tfrc.h           |    4 
 b/net/dccp/dccp.h                     |    8 
 net/dccp/ccids/ccid3.c                |   72 +++++++-
 net/dccp/ccids/ccid3.h                |   10 -
 net/dccp/ccids/lib/loss_interval.c    |  284 +---------------------------------
 net/dccp/ccids/lib/loss_interval.h    |   11 -
 net/dccp/ccids/lib/packet_history.c   |  279 +++++++++++++++++++++++++--------
 net/dccp/ccids/lib/packet_history.h   |   47 ++++-
 net/dccp/ccids/lib/tfrc.c             |   10 -
 16 files changed, 643 insertions(+), 442 deletions(-)
