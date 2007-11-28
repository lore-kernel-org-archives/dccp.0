From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Wed, 28 Nov 2007 15:23:47 +0000
Subject: [PATCHES 0/5]: DCCP patches for 2.6.25
Message-Id: <1196263432-17390-1-git-send-email-acme@redhat.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hi Herbert,

	Please consider pulling from:

master.kernel.org:/pub/scm/linux/kernel/git/acme/net-2.6.25

Best Regards,

- Arnaldo

 b/include/linux/dccp.h                |   56 +++++++++----
 b/net/dccp/ccids/ccid3.c              |   57 ++++----------
 b/net/dccp/ccids/ccid3.h              |    3 
 b/net/dccp/ccids/lib/loss_interval.c  |   12 +-
 b/net/dccp/ccids/lib/packet_history.c |  138 +++++++++++++++-------------------
 b/net/dccp/ccids/lib/packet_history.h |   80 +++----------------
 b/net/dccp/input.c                    |   88 +++++++++++++++++----
 b/net/dccp/output.c                   |    3 
 b/net/dccp/proto.c                    |   23 ++---
 include/linux/dccp.h                  |    1 
 net/dccp/input.c                      |    7 -
 net/dccp/proto.c                      |   89 ++++++++++++++-------
 12 files changed, 287 insertions(+), 270 deletions(-)
