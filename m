From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 17 Nov 2006 15:56:59 +0000
Subject: [PATCH 1/7]: Set TX Queue Length Bounds via Sysctl
Message-Id: <200611171557.00062@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[DCCP]: Set TX Queue Length Bounds via Sysctl

Previously the transmit queue was unbounded. 

This patch by Ian McDonald
	* puts a limit on transmit queue length 
	  and sends back EAGAIN if the buffer is full
	* sets the TX queue length to a sensible default
	* implements tx buffer sysctls for DCCP


Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 Documentation/networking/dccp.txt |    4 ++++
 include/linux/sysctl.h            |    1 +
 net/dccp/dccp.h                   |    1 +
 net/dccp/proto.c                  |   10 ++++++++++
 net/dccp/sysctl.c                 |    9 +++++++++
 5 files changed, 25 insertions(+)

--- a/Documentation/networking/dccp.txt
+++ b/Documentation/networking/dccp.txt
@@ -104,6 +104,10 @@ rx_ccid = 2
 seq_window = 100
 	The initial sequence window (sec. 7.5.2).
 
+tx_qlen = 5
+	The size of the transmit buffer in packets. A value of 0 corresponds
+	to an unbounded transmit buffer.
+
 Notes
 == 
--- a/include/linux/sysctl.h
+++ b/include/linux/sysctl.h
@@ -617,6 +617,7 @@ enum {
 	NET_DCCP_DEFAULT_REQ_RETRIES = 7,
 	NET_DCCP_DEFAULT_RETRIES1    = 8,
 	NET_DCCP_DEFAULT_RETRIES2    = 9,
+	NET_DCCP_DEFAULT_TX_QLEN     = 10,
 };
 
 /* /proc/sys/net/ipx */
--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -87,6 +87,7 @@ extern int  sysctl_dccp_feat_tx_ccid;
 extern int  sysctl_dccp_feat_ack_ratio;
 extern int  sysctl_dccp_feat_send_ack_vector;
 extern int  sysctl_dccp_feat_send_ndp_count;
+extern int  sysctl_dccp_tx_qlen;
 
 /* is seq1 < seq2 ? */
 static inline int before48(const u64 seq1, const u64 seq2)
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -52,6 +52,9 @@ struct inet_hashinfo __cacheline_aligned
 
 EXPORT_SYMBOL_GPL(dccp_hashinfo);
 
+/* the maximum queue length for tx in packets. 0 is no limit */
+int sysctl_dccp_tx_qlen 	__read_mostly = 5;
+
 void dccp_set_state(struct sock *sk, const int state)
 {
 	const int oldstate = sk->sk_state;
@@ -645,6 +648,13 @@ int dccp_sendmsg(struct kiocb *iocb, str
 		return -EMSGSIZE;
 
 	lock_sock(sk);
+
+	if (sysctl_dccp_tx_qlen &&
+	    (sk->sk_write_queue.qlen >= sysctl_dccp_tx_qlen)) {
+		rc = -EAGAIN;
+		goto out_release;
+	}
+
 	timeo = sock_sndtimeo(sk, noblock);
 
 	/*
--- a/net/dccp/sysctl.c
+++ b/net/dccp/sysctl.c
@@ -91,6 +91,15 @@ static struct ctl_table dccp_default_tab
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec,
 	},
+	{
+		.ctl_name	= NET_DCCP_DEFAULT_TX_QLEN,
+		.procname	= "tx_qlen",
+		.data		= &sysctl_dccp_tx_qlen,
+		.maxlen		= sizeof(sysctl_dccp_tx_qlen),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec,
+	},
+
 	{ .ctl_name = 0, }
 };
 
