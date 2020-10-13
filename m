From: Kleber Sacilotto de Souza <kleber.souza@canonical.com>
Date: Tue, 13 Oct 2020 17:18:47 +0000
Subject: [PATCH 0/2] net: dccp: fix structure use-after-free
Message-Id: <20201013171849.236025-1-kleber.souza@canonical.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This patchset addresses the following CVE:

CVE-2020-16119 - DCCP CCID structure use-after-free

Hadar Manor reported that by reusing a socket with an attached
dccps_hc_tx_ccid as a listener, it will be used after being released,
leading to DoS and potentially code execution.

The first patch moves the ccid timers to struct dccp_sock to avoid its
use-after-free, the second patch reverts 2677d2067731 "dccp: don't free
ccid2_hc_tx_sock struct in dccp_disconnect()" that's not needed anymore
and would cause another use-after-free.

Thadeu Lima de Souza Cascardo (2):
  dccp: ccid: move timers to struct dccp_sock
  Revert "dccp: don't free ccid2_hc_tx_sock struct in dccp_disconnect()"

 include/linux/dccp.h   |  2 ++
 net/dccp/ccids/ccid2.c | 32 +++++++++++++++++++-------------
 net/dccp/ccids/ccid3.c | 30 ++++++++++++++++++++----------
 net/dccp/proto.c       |  2 ++
 4 files changed, 43 insertions(+), 23 deletions(-)

-- 
2.25.1
