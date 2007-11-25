From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Sun, 25 Nov 2007 00:21:25 +0000
Subject: [PATCHES 0/18]: DCCP patches for 2.6.25
Message-Id: <1195950103-18102-1-git-send-email-acme@redhat.com>
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

 b/net/dccp/ackvec.c      |  163 +++++++++++++++------------------
 b/net/dccp/ackvec.h      |   63 ++++++------
 b/net/dccp/ccids/ccid2.c |    3 
 b/net/dccp/ccids/ccid2.h |    5 -
 b/net/dccp/proto.c       |   26 ++---
 net/dccp/ccids/ccid2.c   |  230 ++++++++++++++++++++---------------------------
 net/dccp/ccids/ccid2.h   |   23 +---
 net/dccp/proto.c         |   27 ++++-
 8 files changed, 248 insertions(+), 292 deletions(-)
