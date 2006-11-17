From: Ian McDonald <ian.mcdonald@jandi.co.nz>
Date: Fri, 17 Nov 2006 01:51:19 +0000
Subject: [PATCH 2/2] [DCCP]: Put limits on tx queue length
Message-Id: <200611171451.20486.ian.mcdonald@jandi.co.nz>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This puts a limit on transmit queue length and sends back EAGAIN if the
buffer is full.

Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
---
diff --git a/net/dccp/proto.c b/net/dccp/proto.c
index 2729fdc..6e3c311 100644
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -633,6 +633,14 @@ int dccp_sendmsg(struct kiocb *iocb, str
 		return -EMSGSIZE;
 
 	lock_sock(sk);
+
+	if (sysctl_dccp_tx_qlen &&
+	   (sk->sk_write_queue.qlen >= sysctl_dccp_tx_qlen)) {
+		/* if sysctl_dccp_tx_qlen = 0 then unlimited tx queue */
+		rc = -EAGAIN;
+		goto out_release;
+	}
+
 	timeo = sock_sndtimeo(sk, noblock);
 
 	/*
