From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 24 Oct 2006 14:01:29 +0000
Subject: [PATCH 17/17] [TCP/DCCP]: Introduce net_xmit_eval
Message-Id: <200610241501.30050@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[TCP/DCCP]: Introduce net_xmit_eval

Throughout the TCP/DCCP (and tunnelling) code, it often happens
that the return code of a transmit function needs to be tested
against NET_XMIT_CN which is a value that does not indicate a 
strict error condition. 

This patch uses a macro for these recurring situations which is
consistent with the already existing macro net_xmit_errno, saving
on duplicated code.


Signed-off-by: Gerrit Renker  <gerrit@erg.abdn.ac.uk>
------------------------------------------------------------------------------

 include/linux/netdevice.h |    4 ++++
 include/net/ipip.h        |    2 +-
 net/dccp/ipv4.c           |    5 ++---
 net/dccp/ipv6.c           |    3 +--
 net/dccp/output.c         |   14 ++------------
 net/ipv4/tcp_ipv4.c       |    3 +--
 net/ipv4/tcp_output.c     |    8 +-------
 net/ipv6/ip6_tunnel.c     |    2 +-
 net/ipv6/tcp_ipv6.c       |    3 +--
 9 files changed, 14 insertions(+), 30 deletions(-)

------------------------------------------------------------------------------

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 9264139..4b6febb 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -67,6 +67,10 @@ #define NET_RX_CN_MOD		3   /* Storm on i
 #define NET_RX_CN_HIGH		4   /* The storm is here */
 #define NET_RX_BAD		5  /* packet dropped due to kernel error */
 
+/* NET_XMIT_CN is special. It does not guarantee that this packet is lost. It
+ * indicates that the device will soon be dropping packets, or already drops
+ * some packets of the same priority; prompting us to send less aggressively. */
+#define net_xmit_eval(e)	((e) = NET_XMIT_CN? 0 : (e))
 #define net_xmit_errno(e)	((e) != NET_XMIT_CN ? -ENOBUFS : 0)
 
 #endif
diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index 32d03e4..86eef26 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -532,8 +532,7 @@ static int dccp_v4_send_response(struct 
 		err = ip_build_and_send_pkt(skb, sk, ireq->loc_addr,
 					    ireq->rmt_addr,
 					    ireq->opt);
-		if (err = NET_XMIT_CN)
-			err = 0;
+		err = net_xmit_eval(err);
 	}
 
 out:
@@ -606,7 +605,7 @@ static void dccp_v4_ctl_send_reset(struc
 				    rxskb->nh.iph->saddr, NULL);
 	bh_unlock_sock(dccp_v4_ctl_socket->sk);
 
-	if (err = NET_XMIT_CN || err = 0) {
+	if (net_xmit_eval(err) = 0) {
 		DCCP_INC_STATS_BH(DCCP_MIB_OUTSEGS);
 		DCCP_INC_STATS_BH(DCCP_MIB_OUTRSTS);
 	}
diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index 17ddd8b..33dbd65 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -284,8 +284,7 @@ static int dccp_v6_send_response(struct 
 								skb->csum));
 		ipv6_addr_copy(&fl.fl6_dst, &ireq6->rmt_addr);
 		err = ip6_xmit(sk, skb, &fl, opt, 0);
-		if (err = NET_XMIT_CN)
-			err = 0;
+		err = net_xmit_eval(err);
 	}
 
 done:
diff --git a/net/dccp/output.c b/net/dccp/output.c
index 1478ace..1d8590b 100644
--- a/net/dccp/output.c
+++ b/net/dccp/output.c
@@ -124,16 +124,7 @@ static int dccp_transmit_skb(struct sock
 
 		memset(&(IPCB(skb)->opt), 0, sizeof(IPCB(skb)->opt));
 		err = icsk->icsk_af_ops->queue_xmit(skb, 0);
-		if (err <= 0)
-			return err;
-
-		/* NET_XMIT_CN is special. It does not guarantee,
-		 * that this packet is lost. It tells that device
-		 * is about to start to drop packets or already
-		 * drops some packets of the same priority and
-		 * invokes us to send less aggressively.
-		 */
-		return err = NET_XMIT_CN ? 0 : err;
+		return net_xmit_eval(err);
 	}
 	return -ENOBUFS;
 }
@@ -421,8 +412,7 @@ int dccp_send_reset(struct sock *sk, enu
 		if (skb != NULL) {
 			memset(&(IPCB(skb)->opt), 0, sizeof(IPCB(skb)->opt));
 			err = inet_csk(sk)->icsk_af_ops->queue_xmit(skb, 0);
-			if (err = NET_XMIT_CN)
-				err = 0;
+			return net_xmit_eval(err);
 		}
 	}
 
diff --git a/include/net/ipip.h b/include/net/ipip.h
index f490c3c..8405885 100644
--- a/include/net/ipip.h
+++ b/include/net/ipip.h
@@ -35,7 +35,7 @@ #define IPTUNNEL_XMIT() do {						\
 	ip_send_check(iph);						\
 									\
 	err = NF_HOOK(PF_INET, NF_IP_LOCAL_OUT, skb, NULL, rt->u.dst.dev, dst_output);\
-	if (err = NET_XMIT_SUCCESS || err = NET_XMIT_CN) {		\
+	if (net_xmit_eval(err) = 0) {					\
 		stats->tx_bytes += pkt_len;				\
 		stats->tx_packets++;					\
 	} else {							\
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 22ef8bd..b5adb56 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -662,8 +662,7 @@ static int tcp_v4_send_synack(struct soc
 		err = ip_build_and_send_pkt(skb, sk, ireq->loc_addr,
 					    ireq->rmt_addr,
 					    ireq->opt);
-		if (err = NET_XMIT_CN)
-			err = 0;
+		err = net_xmit_eval(err);
 	}
 
 out:
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index b8872f0..92729f1 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -485,13 +485,7 @@ #define SYSCTL_FLAG_SACK	0x4
 
 	tcp_enter_cwr(sk);
 
-	/* NET_XMIT_CN is special. It does not guarantee,
-	 * that this packet is lost. It tells that device
-	 * is about to start to drop packets or already
-	 * drops some packets of the same priority and
-	 * invokes us to send less aggressively.
-	 */
-	return err = NET_XMIT_CN ? 0 : err;
+	return net_xmit_eval(err);
 
 #undef SYSCTL_FLAG_TSTAMPS
 #undef SYSCTL_FLAG_WSCALE
diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index 84d7ebd..1e54139 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -747,7 +747,7 @@ ip6ip6_tnl_xmit(struct sk_buff *skb, str
 	err = NF_HOOK(PF_INET6, NF_IP6_LOCAL_OUT, skb, NULL, 
 		      skb->dst->dev, dst_output);
 
-	if (err = NET_XMIT_SUCCESS || err = NET_XMIT_CN) {
+	if (net_xmit_eval(err) = 0) {
 		stats->tx_bytes += pkt_len;
 		stats->tx_packets++;
 	} else {
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 4c2a7c0..12c501b 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -509,8 +509,7 @@ static int tcp_v6_send_synack(struct soc
 
 		ipv6_addr_copy(&fl.fl6_dst, &treq->rmt_addr);
 		err = ip6_xmit(sk, skb, &fl, opt, 0);
-		if (err = NET_XMIT_CN)
-			err = 0;
+		err = net_xmit_eval(err);
 	}
 
 done:
