From: Fabian Frederick <fabf@skynet.be>
Date: Mon, 17 Nov 2014 20:54:58 +0000
Subject: [PATCH 1/1 net-next] dccp: remove blank lines between function/EXPORT_SYMBOL
Message-Id: <1416257698-5889-1-git-send-email-fabf@skynet.be>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

See Documentation/CodingStyle chapter 6.

Signed-off-by: Fabian Frederick <fabf@skynet.be>
---
 net/dccp/ipv4.c | 6 ------
 1 file changed, 6 deletions(-)

diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index 6ca645c..e45b968 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -140,7 +140,6 @@ failure:
 	inet->inet_dport = 0;
 	goto out;
 }
-
 EXPORT_SYMBOL_GPL(dccp_v4_connect);
 
 /*
@@ -376,7 +375,6 @@ void dccp_v4_send_check(struct sock *sk, struct sk_buff *skb)
 						 inet->inet_saddr,
 						 inet->inet_daddr);
 }
-
 EXPORT_SYMBOL_GPL(dccp_v4_send_check);
 
 static inline u64 dccp_v4_init_sequence(const struct sk_buff *skb)
@@ -444,7 +442,6 @@ put_and_exit:
 	dccp_done(newsk);
 	goto exit;
 }
-
 EXPORT_SYMBOL_GPL(dccp_v4_request_recv_sock);
 
 static struct sock *dccp_v4_hnd_req(struct sock *sk, struct sk_buff *skb)
@@ -670,7 +667,6 @@ drop:
 	DCCP_INC_STATS_BH(DCCP_MIB_ATTEMPTFAILS);
 	return -1;
 }
-
 EXPORT_SYMBOL_GPL(dccp_v4_conn_request);
 
 int dccp_v4_do_rcv(struct sock *sk, struct sk_buff *skb)
@@ -729,7 +725,6 @@ discard:
 	kfree_skb(skb);
 	return 0;
 }
-
 EXPORT_SYMBOL_GPL(dccp_v4_do_rcv);
 
 /**
@@ -802,7 +797,6 @@ int dccp_invalid_packet(struct sk_buff *skb)
 
 	return 0;
 }
-
 EXPORT_SYMBOL_GPL(dccp_invalid_packet);
 
 /* this is called when real data arrives */
-- 
1.9.3

