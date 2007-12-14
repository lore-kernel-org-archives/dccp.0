From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Fri, 14 Dec 2007 01:41:59 +0000
Subject: [PATCHES 0/3]: DCCP patches for 2.6.25
Message-Id: <1197596522-14600-1-git-send-email-acme@redhat.com>
List-Id: <dccp.vger.kernel.org>
References: <1197139933-11609-1-git-send-email-acme@redhat.com>
In-Reply-To: <1197139933-11609-1-git-send-email-acme@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hi David,

	Please consider pulling from:

master.kernel.org:/pub/scm/linux/kernel/git/acme/net-2.6.25

Best Regards,

- Arnaldo

 net/dccp/ccid.c        |    8 ++++----
 net/dccp/ccid.h        |   37 ++++++++++++++++++++++++++++++-------
 net/dccp/ccids/ccid2.c |    2 +-
 net/dccp/ccids/ccid3.c |    2 +-
 net/dccp/output.c      |   30 +++++++++++++++++++++++-------
 5 files changed, 59 insertions(+), 20 deletions(-)
