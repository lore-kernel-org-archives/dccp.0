From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Wed, 17 Dec 2008 20:03:32 +0000
Subject: [PATCH] dccp_diag: LISTEN sockets don't have CCIDs
Message-Id: <20081217200332.GY14518@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

And thus when we try to use 'ss -danemi' on these sockets that have no
ccid blocks (data collected using systemtap after I fixed the problem):

dccp_diag_get_info sk=0xffff8801220a3100, dp->dccps_hc_rx_ccid=0x0000000000000000, dp->dccps_hc_tx_ccid=0x0000000000000000

We get an OOPS:

mica.ghostprotocols.net login: BUG: unable to handle kernel NULL pointer
dereferenc0
IP: [<ffffffffa0136082>] dccp_diag_get_info+0x82/0xc0 [dccp_diag]
PGD 12106f067 PUD 122488067 PMD 0
Oops: 0000 [#1] PREEMPT

Fix is trivial, and 'ss -d' is working again:

[root@mica ~]# ss -danemi
State   Recv-Q Send-Q   Local Address:Port   Peer Address:Port 
LISTEN  0      0                    *:5001              *:*
ino:7288 sk:220a3100ffff8801
	 mem:(r0,w0,f0,t0) cwnd:0 ssthresh:0
[root@mica ~]# 

Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>

diff --git a/net/dccp/diag.c b/net/dccp/diag.c
index 652a1b6..b21f261 100644
--- a/net/dccp/diag.c
+++ b/net/dccp/diag.c
@@ -32,8 +32,11 @@ static void dccp_get_info(struct sock *sk, struct tcp_info *info)
 	if (dp->dccps_hc_rx_ackvec != NULL)
 		info->tcpi_options |= TCPI_OPT_SACK;
 
-	ccid_hc_rx_get_info(dp->dccps_hc_rx_ccid, sk, info);
-	ccid_hc_tx_get_info(dp->dccps_hc_tx_ccid, sk, info);
+	if (dp->dccps_hc_rx_ccid != NULL)
+		ccid_hc_rx_get_info(dp->dccps_hc_rx_ccid, sk, info);
+
+	if (dp->dccps_hc_tx_ccid != NULL)
+		ccid_hc_tx_get_info(dp->dccps_hc_tx_ccid, sk, info);
 }
 
 static void dccp_diag_get_info(struct sock *sk, struct inet_diag_msg *r,
