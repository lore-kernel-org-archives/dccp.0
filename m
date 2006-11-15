From: Ian McDonald <ian.mcdonald@jandi.co.nz>
Date: Wed, 15 Nov 2006 21:39:08 +0000
Subject: [RFC PATCH 2/2]: DCCP Introduce tx queue limits
Message-Id: <200611161039.10804.ian.mcdonald@jandi.co.nz>
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
index b9d6e7e..4056308 100644
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -634,6 +634,14 @@ int dccp_sendmsg(struct kiocb *iocb, str
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
