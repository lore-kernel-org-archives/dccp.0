From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 04 Jan 2007 14:28:59 +0000
Subject: Re: [PATCHv2 4/4]: More to see in dccp_probe
Message-Id: <200701041428.59777@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Thanks for your feedback. 
This adds back the `size' field into the output. Yoshifuji, I have taken on board
almost 100% of your suggestion -- only the last field, t_ipi, is now placed
next to X (which makes sense since it is inversely proportional).
Also updated & uploaded the scripts with regard to this change.

--------------------------> Patchv2 <----------------------------------------
[CCID 3]: More to see in dccp_probe

This adds a few more fields of interest to /proc/net/dccpprobe, the following output ensues:

1           2          3           4     5  6     7   8        9        10   11
sec.usec   src:sport   dst:dport   size  s  rtt   p   X_calc   X_recv   X    t_ipi

Also made the formatting consistent.

Scripts that go with this can be downloaded from http://139.133.210.30/users/gerrit/dccp/dccp_probe/

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/probe.c |   17 ++++++++++-------
 1 file changed, 10 insertions(+), 7 deletions(-)

--- a/net/dccp/probe.c
+++ b/net/dccp/probe.c
@@ -90,15 +90,18 @@ static int jdccp_sendmsg(struct kiocb *i
 	if (port = 0 || ntohs(inet->dport) = port ||
 	    ntohs(inet->sport) = port) {
 		if (hctx)
-			printl("%d.%d.%d.%d:%u %d.%d.%d.%d:%u %d %d %d %d %d\n",
-			   NIPQUAD(inet->saddr), ntohs(inet->sport),
-			   NIPQUAD(inet->daddr), ntohs(inet->dport), size,
-			   hctx->ccid3hctx_s, hctx->ccid3hctx_rtt,
-			   hctx->ccid3hctx_p, hctx->ccid3hctx_t_ipi);
+			printl("%d.%d.%d.%d:%u %d.%d.%d.%d:%u %d %d %d %d %u "
+			       "%llu %llu %d\n",
+			       NIPQUAD(inet->saddr), ntohs(inet->sport),
+			       NIPQUAD(inet->daddr), ntohs(inet->dport), size,
+			       hctx->ccid3hctx_s, hctx->ccid3hctx_rtt,
+			       hctx->ccid3hctx_p, hctx->ccid3hctx_x_calc,
+			       hctx->ccid3hctx_x_recv >> 6,
+			       hctx->ccid3hctx_x >> 6, hctx->ccid3hctx_t_ipi);
 		else
 			printl("%d.%d.%d.%d:%u %d.%d.%d.%d:%u %d\n",
-			   NIPQUAD(inet->saddr), ntohs(inet->sport),
-			   NIPQUAD(inet->daddr), ntohs(inet->dport), size);
+			       NIPQUAD(inet->saddr), ntohs(inet->sport),
+			       NIPQUAD(inet->daddr), ntohs(inet->dport), size);
 	}
 
 	jprobe_return();
