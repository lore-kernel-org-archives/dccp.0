From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 24 Oct 2007 13:35:42 +0000
Subject: Re: systemtap networking tapsets was: Re: [RFC]: field name identifier conventions
Message-Id: <200710241435.42810@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <20071022163144.GA15773@ghostprotocols.net>
In-Reply-To: <20071022163144.GA15773@ghostprotocols.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Quoting Arnaldo Carvalho de Melo:
|  > I think that dccpprobe.c is the wrong name ... it should really be called ccid3_probe.c ...
|  > I have been working on printing entries for CCID2, since in ccid2.c there is no probe support,
|  > and instead ccid2_pr_debug is used for the same purpose all over the place.
|  
|  Indeed, lemme try converting it right now...
|  
This is how far I came (only for info, applies only on test tree):

--- a/net/dccp/probe.c
+++ b/net/dccp/probe.c
@@ -34,6 +34,7 @@
XXX enough for this week, remove to re-enable 
 #include "dccp.h"
 #include "ccid.h"
+#include "ccids/ccid2.h"
 #include "ccids/ccid3.h"
 
 static int port;
@@ -80,22 +81,37 @@ static int jdccp_sendmsg(struct kiocb *i
 			 struct msghdr *msg, size_t size)
 {
 	const struct inet_sock *inet = inet_sk(sk);
-	struct ccid3_hc_tx_sock *hctx = NULL;
+	struct ccid2_hc_tx_sock *tx2 = NULL;
+	struct ccid3_hc_tx_sock *tx3 = NULL;
 
-	if (ccid_get_current_id(dccp_sk(sk), false) = DCCPC_CCID3)
-		hctx = ccid3_hc_tx_sk(sk);
+	switch (ccid_get_current_id(dccp_sk(sk), false)) {
+	case DCCPC_CCID2:
+		tx2 = ccid2_hc_tx_sk(sk);
+		break;
+	case DCCPC_CCID3:
+		tx3 = ccid3_hc_tx_sk(sk);
+	}
 
 	if (port = 0 || ntohs(inet->dport) = port ||
 	    ntohs(inet->sport) = port) {
-		if (hctx)
+		if (tx3)
 			printl("%d.%d.%d.%d:%u %d.%d.%d.%d:%u %d %d %d %d %u "
 			       "%llu %llu %d\n",
 			       NIPQUAD(inet->saddr), ntohs(inet->sport),
 			       NIPQUAD(inet->daddr), ntohs(inet->dport), size,
-			       hctx->ccid3hctx_s, hctx->ccid3hctx_rtt,
-			       hctx->ccid3hctx_p, hctx->ccid3hctx_x_calc,
-			       hctx->ccid3hctx_x_recv >> 6,
-			       hctx->ccid3hctx_x >> 6, hctx->ccid3hctx_t_ipi);
+			       tx3->ccid3hctx_s, tx3->ccid3hctx_rtt,
+			       tx3->ccid3hctx_p, tx3->ccid3hctx_x_calc,
+			       tx3->ccid3hctx_x_recv >> 6,
+			       tx3->ccid3hctx_x >> 6, tx3->ccid3hctx_t_ipi);
+		else if (tx2)
+			printl("%d.%d.%d.%d:%u %d.%d.%d.%d:%u %d %d %d %u %u %u\n",
+			       NIPQUAD(inet->saddr), ntohs(inet->sport),
+			       NIPQUAD(inet->daddr), ntohs(inet->dport), size,
+			       tx2->ccid2hctx_srtt>>3,
+			       tx2->ccid2hctx_rttvar>>2,
+			       tx2->ccid2hctx_pipe,
+			       tx2->ccid2hctx_cwnd,
+			       tx2->ccid2hctx_ssthresh);
 		else
 			printl("%d.%d.%d.%d:%u %d.%d.%d.%d:%u %d\n",
 			       NIPQUAD(inet->saddr), ntohs(inet->sport),
--- a/net/dccp/ccids/ccid2.c
+++ b/net/dccp/ccids/ccid2.c
@@ -129,9 +129,6 @@ static int ccid2_hc_tx_send_packet(struc
 {
 	struct ccid2_hc_tx_sock *hctx = ccid2_hc_tx_sk(sk);
 
-	ccid2_pr_debug("pipe=%d cwnd=%d\n", hctx->ccid2hctx_pipe,
-		       hctx->ccid2hctx_cwnd);
-
 	if (hctx->ccid2hctx_pipe < hctx->ccid2hctx_cwnd)
 		return 0;
 
@@ -259,9 +256,6 @@ static void ccid2_hc_tx_packet_sent(stru
 	}
 	hctx->ccid2hctx_seqh = next;
 
-	ccid2_pr_debug("cwnd=%d pipe=%d\n", hctx->ccid2hctx_cwnd,
-		       hctx->ccid2hctx_pipe);
-
 	/*
 	 * FIXME: The code below is broken and the variables have been removed
 	 * from the socket struct. The `ackloss' variable was always set to 0,
@@ -316,7 +310,6 @@ static void ccid2_hc_tx_packet_sent(stru
 		ccid2_start_rto_timer(sk);
 
 #ifdef CONFIG_IP_DCCP_CCID2_DEBUG
-	ccid2_pr_debug("pipe=%d\n", hctx->ccid2hctx_pipe);
 	ccid2_pr_debug("Sent: seq=%llu\n", (unsigned long long)dp->dccps_gss);
 	do {
 		struct ccid2_seq *seqp = hctx->ccid2hctx_seqt;
