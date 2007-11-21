From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Wed, 21 Nov 2007 15:28:22 +0000
Subject: [PATCHES 0/11]: DCCP patches for 2.6.25
Message-Id: <1195658913-24840-1-git-send-email-acme@redhat.com>
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

 Documentation/networking/dccp.txt |   33 ++++++++++++++++------
 Documentation/networking/dccp.txt |    2 +
 include/linux/dccp.h              |   15 ++--------
 net/dccp/Kconfig                  |    1
 net/dccp/ccids/Kconfig            |   14 +--------
 net/dccp/ccids/ccid3.c            |   22 ++++++++------
 net/dccp/ccids/ccid3.h            |    3 --
 net/dccp/ccids/lib/tfrc.h         |   10 ++++++
 net/dccp/input.c                  |   27 +++++++++++++-----
 net/dccp/options.c                |   14 ++++-----
 net/dccp/proto.c                  |    3 --
 net/dccp/ccids/Kconfig            |    5 ---
 net/dccp/ccids/ccid3.c            |   53 ++++++++++--------------------------
 net/dccp/ccids/ccid3.h            |    3 --
 14 files changed, 97 insertions(+), 108 deletions(-)
