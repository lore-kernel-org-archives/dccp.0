From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 01 Nov 2007 10:39:04 +0000
Subject: Re: [PATCH 0/25] Towards CCID3/CCID4 code integration
Message-Id: <200711011039.04714@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <1193810064.7357.249.camel@embedded-ephone1.embedded.ufcg.edu.br>
In-Reply-To: <1193810064.7357.249.camel@embedded-ephone1.embedded.ufcg.edu.br>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

The new ccid4 branch is now online. With regard to merging between ccid3/4, this will
take some time. I have a day job to do and there may be a few changes in the ccid3 code
(will be announced on the list), but I'll let you know.

root@turnip> git pull git://eden-feed.erg.abdn.ac.uk/dccp_exp ccid4

Updating de1f427..b1a9b84
Fast forward
 include/linux/dccp.h            |    1 +
 net/dccp/ccid.c                 |    3 +
 net/dccp/ccids/Kconfig          |   77 ++++-
 net/dccp/ccids/Makefile         |    4 +
 net/dccp/ccids/ccid3.c          |  480 +++++++++------------
 net/dccp/ccids/ccid3.h          |  135 +------
 net/dccp/ccids/ccid4.c          |  917 +++++++++++++++++++++++++++++++++++++++
 net/dccp/ccids/ccid4.h          |   64 +++
 net/dccp/ccids/lib/Makefile     |    3 +-
 net/dccp/ccids/lib/tfrc_ccids.c |   68 +++
 net/dccp/ccids/lib/tfrc_ccids.h |  198 +++++++++
 net/dccp/feat.c                 |   59 +++-
 net/dccp/probe.c                |   21 +-
 13 files changed, 1604 insertions(+), 426 deletions(-)
