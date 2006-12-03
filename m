From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sun, 03 Dec 2006 15:38:27 +0000
Subject: [PATCH] DCCP: handle EAGAIN case
Message-Id: <200612031538.27300@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This might be something to help with the poor throughput.
By using this patch, I have observed an increase of tx rates
from  600..800kbits/sec (without this modification) up to 94.8 Mbits/sec
(which is as good as TCP gets).
Please test - I'd be curious what your experiences are with this one. 

--------------------------> Patch <----------------------------------------

[DCCP]: Handle EAGAIN in dccp_write_xmit

If dccp_wait_for_ccid returns -EAGAIN, the packet is silently 
deqeued and not sent. At the receiver this counts as loss, increases
the loss rate and reduces throughput. 
This patch handles the EAGAIN case by restarting afresh to peek into
the write queue and send the packet.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/output.c |    5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

--- a/net/dccp/output.c
+++ b/net/dccp/output.c
@@ -255,8 +255,11 @@ void dccp_write_xmit(struct sock *sk, in
 				err = dccp_wait_for_ccid(sk, skb, &timeo);
 				timeo = DCCP_XMIT_TIMEO;
 			}
-			if (err)
+			if (err) {
+				if (err = -EAGAIN)
+					continue;
 				DCCP_BUG("err=%d after dccp_wait_for_ccid", err);
+			}
 		}
 
 		skb_dequeue(&sk->sk_write_queue);
