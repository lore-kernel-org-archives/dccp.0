From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 03 Jan 2007 13:58:02 +0000
Subject: [PATCH 4/4][NEW]:  More to see in dccp_probe
Message-Id: <200701031358.02629@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[CCID 3]: More to see in dccp_probe

This removes the `size' field from output (which would report the constant buffer size),
and adds a few more fields of interest to /proc/net/dccpprobe, the following output ensues:

sec.usec   src:sport   dst:dport   s   rtt   p   X_calc  X_recv   X   t_ipi
1           2          3           4   5     6   7       8        9   10

Scripts that go with this can be downloaded from http://139.133.210.30/users/gerrit/dccp/dccp_probe/

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/probe.c |    8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

--- a/net/dccp/probe.c
+++ b/net/dccp/probe.c
@@ -90,11 +90,13 @@ static int jdccp_sendmsg(struct kiocb *i
 	if (port = 0 || ntohs(inet->dport) = port ||
 	    ntohs(inet->sport) = port) {
 		if (hctx)
-			printl("%d.%d.%d.%d:%u %d.%d.%d.%d:%u %d %d %d %d %d\n",
+			printl("%d.%d.%d.%d:%u %d.%d.%d.%d:%u %d %d %d %u %llu %llu %d\n",
 			   NIPQUAD(inet->saddr), ntohs(inet->sport),
-			   NIPQUAD(inet->daddr), ntohs(inet->dport), size,
+			   NIPQUAD(inet->daddr), ntohs(inet->dport),
 			   hctx->ccid3hctx_s, hctx->ccid3hctx_rtt,
-			   hctx->ccid3hctx_p, hctx->ccid3hctx_t_ipi);
+			   hctx->ccid3hctx_p,
+			   hctx->ccid3hctx_x_calc, hctx->ccid3hctx_x_recv >> 6,
+			   hctx->ccid3hctx_x >> 6, hctx->ccid3hctx_t_ipi);
 		else
 			printl("%d.%d.%d.%d:%u %d.%d.%d.%d:%u %d\n",
 			   NIPQUAD(inet->saddr), ntohs(inet->sport),
