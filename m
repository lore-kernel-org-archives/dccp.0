From: Masami Hiramatsu <mhiramat@kernel.org>
Date: Wed, 08 Nov 2017 10:00:33 +0000
Subject: [RFC PATCH -tip 1/6] net: tcp: Add trace events for TCP congestion window tracing
Message-Id: <151013523339.7294.16732700508720389690.stgit@devbox>
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
 include/trace/events/tcp.h |   96 ++++++++++++++++++++++++++++++++++++++++++++
 net/core/net-traces.c      |    1 
 net/ipv4/tcp_input.c       |    4 ++
 3 files changed, 101 insertions(+)
 create mode 100644 include/trace/events/tcp.h

diff --git a/include/trace/events/tcp.h b/include/trace/events/tcp.h
new file mode 100644
index 000000000000..b8969bbceb38
--- /dev/null
+++ b/include/trace/events/tcp.h
@@ -0,0 +1,96 @@
+/* SPDX-License-Identifier: GPL-2.0 */
+#undef TRACE_SYSTEM
+#define TRACE_SYSTEM tcp
+
+#if !defined(_TRACE_TCP_H) || defined(TRACE_HEADER_MULTI_READ)
+#define _TRACE_TCP_H
+
+#include <net/tcp.h>
+#include <linux/tcp.h>
+#include <linux/ipv6.h>
+#include <uapi/linux/in.h>
+#include <uapi/linux/in6.h>
+#include <linux/tracepoint.h>
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
+		if (sk->sk_family = AF_INET) {
+			struct sockaddr_in *v4 = (void *)__entry->saddr;
+
+			v4->sin_family = AF_INET;
+			v4->sin_port = inet->inet_sport;
+			v4->sin_addr.s_addr = inet->inet_saddr;
+			v4 = (void *)__entry->daddr;
+			v4->sin_family = AF_INET;
+			v4->sin_port = inet->inet_dport;
+			v4->sin_addr.s_addr = inet->inet_daddr;
+#if IS_ENABLED(CONFIG_IPV6)
+		} else if (sk->sk_family = AF_INET6) {
+			struct sockaddr_in6 *v6 = (void *)__entry->saddr;
+
+			v6->sin6_family = AF_INET6;
+			v6->sin6_port = inet->inet_sport;
+			v6->sin6_addr = inet6_sk(sk)->saddr;
+			v6 = (void *)__entry->daddr;
+			v6->sin6_family = AF_INET6;
+			v6->sin6_port = inet->inet_dport;
+			v6->sin6_addr = sk->sk_v6_daddr;
+#endif
+		}
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
+#endif /* _TRACE_TCP_H */
+
+/* This part must be outside protection */
+#include <trace/define_trace.h>
diff --git a/net/core/net-traces.c b/net/core/net-traces.c
index 71f209542364..2e84d642c03f 100644
--- a/net/core/net-traces.c
+++ b/net/core/net-traces.c
@@ -31,6 +31,7 @@
 #include <trace/events/net.h>
 #include <trace/events/napi.h>
 #include <trace/events/sock.h>
+#include <trace/events/tcp.h>
 #include <trace/events/udp.h>
 #include <trace/events/fib.h>
 #include <trace/events/qdisc.h>
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 9a0b3c5ffa46..da8b342b95ce 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -76,6 +76,7 @@
 #include <linux/ipsec.h>
 #include <asm/unaligned.h>
 #include <linux/errqueue.h>
+#include <trace/events/tcp.h>
 
 int sysctl_tcp_fack __read_mostly;
 int sysctl_tcp_max_reordering __read_mostly = 300;
@@ -5356,6 +5357,9 @@ void tcp_rcv_established(struct sock *sk, struct sk_buff *skb,
 	unsigned int len = skb->len;
 	struct tcp_sock *tp = tcp_sk(sk);
 
+	/* TCP congestion window tracking */
+	trace_tcp_probe(sk, skb);
+
 	tcp_mstamp_refresh(tp);
 	if (unlikely(!sk->sk_rx_dst))
 		inet_csk(sk)->icsk_af_ops->sk_rx_dst_set(sk, skb);

