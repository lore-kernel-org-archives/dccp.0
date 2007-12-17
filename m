From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Mon, 17 Dec 2007 15:00:14 +0000
Subject: [PATCHES 0/5]: DCCP patches for 2.6.25
Message-Id: <1197903619-12301-1-git-send-email-acme@redhat.com>
List-Id: <dccp.vger.kernel.org>
References: <1196263432-17390-1-git-send-email-acme@redhat.com>
In-Reply-To: <1196263432-17390-1-git-send-email-acme@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hi David,

	Please consider pulling from:

master.kernel.org:/pub/scm/linux/kernel/git/acme/net-2.6.25

Best Regards,

- Arnaldo

net/dccp/ccids/ccid3.c |  252 +++++++++++++++++++++++++++++-----------------------------
net/dccp/ccids/ccid3.h |    8 -
net/dccp/dccp.h        |    6 -
3 files changed, 130 insertions(+), 136 deletions(-)
