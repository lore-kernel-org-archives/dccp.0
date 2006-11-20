From: Arnaldo Carvalho de Melo <acme@mandriva.com>
Date: Mon, 20 Nov 2006 20:55:06 +0000
Subject: [PATCH 4/9] [DCCP]: Set TX Queue Length Bounds via Sysctl
Message-Id: <20061120205506.GE5246@mandriva.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Previously the transmit queue was unbounded.

This patch:
	* puts a limit on transmit queue length
	  and sends back EAGAIN if the buffer is full
	* sets the TX queue length to a sensible default
	* implements tx buffer sysctls for DCCP

Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>
---
 net/dccp/dccp.h  |    1 +
 net/dccp/proto.c |   10 ++++++++++
 2 files changed, 11 insertions(+), 0 deletions(-)

diff --git a/net/dccp/dccp.h b/net/dccp/dccp.h
index 33d86f5..3a94625 100644
--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -87,6 +87,7 @@ extern int  sysctl_dccp_feat_tx_ccid;
 extern int  sysctl_dccp_feat_ack_ratio;
 extern int  sysctl_dccp_feat_send_ack_vector;
 extern int  sysctl_dccp_feat_send_ndp_count;
+extern int  sysctl_dccp_tx_qlen;
 
 /* is seq1 < seq2 ? */
 static inline int before48(const u64 seq1, const u64 seq2)
diff --git a/net/dccp/proto.c b/net/dccp/proto.c
index 0225bda..a7f345c 100644
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -52,6 +52,9 @@ struct inet_hashinfo __cacheline_aligned
 
 EXPORT_SYMBOL_GPL(dccp_hashinfo);
 
+/* the maximum queue length for tx in packets. 0 is no limit */
+int sysctl_dccp_tx_qlen __read_mostly = 5;
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
-- 
1.4.2.1.g3d5c

