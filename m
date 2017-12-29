From: Masami Hiramatsu <mhiramat@kernel.org>
Date: Fri, 29 Dec 2017 02:45:51 +0000
Subject: [PATCH net-next v7 1/6] net: tcp: Add trace events for TCP congestion window tracing
Message-Id: <151451555122.17912.17721577806856943458.stgit@devbox>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This adds an event to trace TCP stat variables with
slightly intrusive trace-event. This uses ftrace/perf
event log buffer to trace those state, no needs to
prepare own ring-buffer, nor custom user apps.

User can use ftrace to trace this event as below;

  # cd /sys/kernel/debug/tracing
  # echo 1 > events/tcp/tcp_probe/enable
  (run workloads)
  # cat trace

Signed-off-by: Masami Hiramatsu <mhiramat@kernel.org>
---
 Changes in v6:
  - Avoid preprocessor directives in tracepoint macro args as
    Mat did on net tree.
---
 include/trace/events/tcp.h |   97 ++++++++++++++++++++++++++++++++++++++++++++
 net/ipv4/tcp_input.c       |    3 +
 2 files changed, 100 insertions(+)

diff --git a/include/trace/events/tcp.h b/include/trace/events/tcp.h
index 8e88a1671538..4dea6342f7d4 100644
--- a/include/trace/events/tcp.h
+++ b/include/trace/events/tcp.h
@@ -1,3 +1,4 @@
+/* SPDX-License-Identifier: GPL-2.0 */
 #undef TRACE_SYSTEM
 #define TRACE_SYSTEM tcp
 
@@ -8,6 +9,7 @@
 #include <linux/tcp.h>
 #include <linux/tracepoint.h>
 #include <net/ipv6.h>
+#include <net/tcp.h>
 
 /*
  * tcp event with arguments sk and skb
@@ -277,6 +279,101 @@ TRACE_EVENT(tcp_retransmit_synack,
 		  __entry->saddr_v6, __entry->daddr_v6)
 );
 
+
+#define TP_STORE_ADDR_PORTS_V4(__entry, inet, sk)			\
+	do {								\
+		struct sockaddr_in *v4 = (void *)__entry->saddr;	\
+									\
+		v4->sin_family = AF_INET;				\
+		v4->sin_port = inet->inet_sport;			\
+		v4->sin_addr.s_addr = inet->inet_saddr;			\
+		v4 = (void *)__entry->daddr;				\
+		v4->sin_family = AF_INET;				\
+		v4->sin_port = inet->inet_dport;			\
+		v4->sin_addr.s_addr = inet->inet_daddr;			\
+	} while (0)
+
+#if IS_ENABLED(CONFIG_IPV6)
+
+#define TP_STORE_ADDR_PORTS(__entry, inet, sk)				\
+	do {								\
+		if (sk->sk_family = AF_INET6) {			\
+			struct sockaddr_in6 *v6 = (void *)__entry->saddr; \
+									\
+			v6->sin6_family = AF_INET6;			\
+			v6->sin6_port = inet->inet_sport;		\
+			v6->sin6_addr = inet6_sk(sk)->saddr;		\
+			v6 = (void *)__entry->daddr;			\
+			v6->sin6_family = AF_INET6;			\
+			v6->sin6_port = inet->inet_dport;		\
+			v6->sin6_addr = sk->sk_v6_daddr;		\
+		} else							\
+			TP_STORE_ADDR_PORTS_V4(__entry, inet, sk);	\
+	} while (0)
+
+#else
+
+#define TP_STORE_ADDR_PORTS(__entry, inet, sk)		\
+	TP_STORE_ADDR_PORTS_V4(__entry, inet, sk);
+
+#endif
+
+TRACE_EVENT(tcp_probe,
+
+	TP_PROTO(struct sock *sk, struct sk_buff *skb),
+
+	TP_ARGS(sk, skb),
+
+	TP_STRUCT__entry(
+		/* sockaddr_in6 is always bigger than sockaddr_in */
+		__array(__u8, saddr, sizeof(struct sockaddr_in6))
+		__array(__u8, daddr, sizeof(struct sockaddr_in6))
+		__field(__u16, sport)
+		__field(__u16, dport)
+		__field(__u32, mark)
+		__field(__u16, length)
+		__field(__u32, snd_nxt)
+		__field(__u32, snd_una)
+		__field(__u32, snd_cwnd)
+		__field(__u32, ssthresh)
+		__field(__u32, snd_wnd)
+		__field(__u32, srtt)
+		__field(__u32, rcv_wnd)
+	),
+
+	TP_fast_assign(
+		const struct tcp_sock *tp = tcp_sk(sk);
+		const struct inet_sock *inet = inet_sk(sk);
+
+		memset(__entry->saddr, 0, sizeof(struct sockaddr_in6));
+		memset(__entry->daddr, 0, sizeof(struct sockaddr_in6));
+
+		TP_STORE_ADDR_PORTS(__entry, inet, sk);
+
+		/* For filtering use */
+		__entry->sport = ntohs(inet->inet_sport);
+		__entry->dport = ntohs(inet->inet_dport);
+		__entry->mark = skb->mark;
+
+		__entry->length = skb->len;
+		__entry->snd_nxt = tp->snd_nxt;
+		__entry->snd_una = tp->snd_una;
+		__entry->snd_cwnd = tp->snd_cwnd;
+		__entry->snd_wnd = tp->snd_wnd;
+		__entry->rcv_wnd = tp->rcv_wnd;
+		__entry->ssthresh = tcp_current_ssthresh(sk);
+		__entry->srtt = tp->srtt_us >> 3;
+	),
+
+	TP_printk("src=%pISpc dest=%pISpc mark=%#x length=%d snd_nxt=%#x "
+		  "snd_una=%#x snd_cwnd=%u ssthresh=%u snd_wnd=%u srtt=%u "
+		  "rcv_wnd=%u",
+		  __entry->saddr, __entry->daddr, __entry->mark,
+		  __entry->length, __entry->snd_nxt, __entry->snd_una,
+		  __entry->snd_cwnd, __entry->ssthresh, __entry->snd_wnd,
+		  __entry->srtt, __entry->rcv_wnd)
+);
+
 #endif /* _TRACE_TCP_H */
 
 /* This part must be outside protection */
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 4d55c4b338ee..ff71b18d9682 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -5299,6 +5299,9 @@ void tcp_rcv_established(struct sock *sk, struct sk_buff *skb,
 	unsigned int len = skb->len;
 	struct tcp_sock *tp = tcp_sk(sk);
 
+	/* TCP congestion window tracking */
+	trace_tcp_probe(sk, skb);
+
 	tcp_mstamp_refresh(tp);
 	if (unlikely(!sk->sk_rx_dst))
 		inet_csk(sk)->icsk_af_ops->sk_rx_dst_set(sk, skb);

