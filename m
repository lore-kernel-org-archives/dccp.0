From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Thu, 13 Dec 2007 15:05:53 +0000
Subject: [PATCHES 0/12]: DCCP patches for 2.6.25
Message-Id: <1197558365-31134-1-git-send-email-acme@redhat.com>
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

 Documentation/networking/dccp.txt |    6 +
 include/linux/dccp.h              |   24 ++++++-
 net/dccp/dccp.h                   |   10 ++-
 net/dccp/feat.c                   |   29 ++++----
 net/dccp/feat.h                   |   26 -------
 net/dccp/input.c                  |   28 +++++---
 net/dccp/ipv4.c                   |    8 +-
 net/dccp/ipv6.c                   |    8 +-
 net/dccp/minisocks.c              |   33 +++++----
 net/dccp/options.c                |  126 +++++++++++++++++++++++++-------------
 net/dccp/output.c                 |   21 +++++-
 net/dccp/proto.c                  |   34 +++-------
 12 files changed, 208 insertions(+), 145 deletions(-)
