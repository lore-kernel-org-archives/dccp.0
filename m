From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Wed, 24 Oct 2007 13:10:25 +0000
Subject: [PATCHES 0/5]: DCCP bug fixes
Message-Id: <20071024131025.GC6371@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hi David,

	Please consider pulling from:

master.kernel.org:/pub/scm/linux/kernel/git/acme/net-2.6

Gerrit Renker (5):
      [DCCP]: Retrieve packet sequence number for error reporting
      [DCCP]: One more exemption from full sequence number checks
      [DCCP]: Convert Reset code into socket error number
      [DCCP]: Unaligned pointer access
      [CCID2/3]: Initialisation assignments of 0 are redundant

 include/linux/dccp.h   |   12 ++++++------
 net/dccp/ccids/ccid2.c |    4 ----
 net/dccp/ccids/ccid3.c |   15 +++++++--------
 net/dccp/input.c       |   48 +++++++++++++++++++++++++++++++++++++++---------
 net/dccp/ipv4.c        |    6 +++---
 net/dccp/ipv6.c        |    4 ++--
 net/dccp/options.c     |   33 ++++++++++++++++++++++-----------
 7 files changed, 79 insertions(+), 43 deletions(-)

Best Regards,

- Arnaldo
