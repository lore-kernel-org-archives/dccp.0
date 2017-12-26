From: David Miller <davem@davemloft.net>
Date: Tue, 26 Dec 2017 23:51:55 +0000
Subject: Re: [PATCH net-next v5 1/6] net: tcp: Add trace events for TCP congestion window tracing
Message-Id: <20171226.185155.2132957966134649827.davem@davemloft.net>
List-Id: <dccp.vger.kernel.org>
References: <151390833345.13277.9194686808843116185.stgit@devbox>
In-Reply-To: <151390833345.13277.9194686808843116185.stgit@devbox>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Masami Hiramatsu <mhiramat@kernel.org>
Date: Fri, 22 Dec 2017 11:05:33 +0900

> This adds an event to trace TCP stat variables with
> slightly intrusive trace-event. This uses ftrace/perf
> event log buffer to trace those state, no needs to
> prepare own ring-buffer, nor custom user apps.
> 
> User can use ftrace to trace this event as below;
> 
>   # cd /sys/kernel/debug/tracing
>   # echo 1 > events/tcp/tcp_probe/enable
>   (run workloads)
>   # cat trace
> 
> Signed-off-by: Masami Hiramatsu <mhiramat@kernel.org>
 ...
> +	TP_fast_assign(
> +		const struct tcp_sock *tp = tcp_sk(sk);
> +		const struct inet_sock *inet = inet_sk(sk);
> +
> +		memset(__entry->saddr, 0, sizeof(struct sockaddr_in6));
> +		memset(__entry->daddr, 0, sizeof(struct sockaddr_in6));
> +
> +		if (sk->sk_family = AF_INET) {
> +			struct sockaddr_in *v4 = (void *)__entry->saddr;
> +
> +			v4->sin_family = AF_INET;
> +			v4->sin_port = inet->inet_sport;
> +			v4->sin_addr.s_addr = inet->inet_saddr;
> +			v4 = (void *)__entry->daddr;
> +			v4->sin_family = AF_INET;
> +			v4->sin_port = inet->inet_dport;
> +			v4->sin_addr.s_addr = inet->inet_daddr;
> +#if IS_ENABLED(CONFIG_IPV6)
> +		} else if (sk->sk_family = AF_INET6) {

It looks like doing this ifdef test inside of a trace macro is very
undesirable because it upsets sparse.

Please see the following commit which just went into 'net'.

==========
commit 6a6b0b9914e73a8a54253dd5f6f5e5dd5e4a756c
Author: Mat Martineau <mathew.j.martineau@linux.intel.com>
Date:   Thu Dec 21 10:29:09 2017 -0800

    tcp: Avoid preprocessor directives in tracepoint macro args
    
    Using a preprocessor directive to check for CONFIG_IPV6 in the middle of
    a DECLARE_EVENT_CLASS macro's arg list causes sparse to report a series
    of errors:
    
    ./include/trace/events/tcp.h:68:1: error: directive in argument list
    ./include/trace/events/tcp.h:75:1: error: directive in argument list
    ./include/trace/events/tcp.h:144:1: error: directive in argument list
    ./include/trace/events/tcp.h:151:1: error: directive in argument list
    ./include/trace/events/tcp.h:216:1: error: directive in argument list
    ./include/trace/events/tcp.h:223:1: error: directive in argument list
    ./include/trace/events/tcp.h:274:1: error: directive in argument list
    ./include/trace/events/tcp.h:281:1: error: directive in argument list
    
    Once sparse finds an error, it stops printing warnings for the file it
    is checking. This masks any sparse warnings that would normally be
    reported for the core TCP code.
    
    Instead, handle the preprocessor conditionals in a couple of auxiliary
    macros. This also has the benefit of reducing duplicate code.
    
    Cc: David Ahern <dsahern@gmail.com>
    Signed-off-by: Mat Martineau <mathew.j.martineau@linux.intel.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/include/trace/events/tcp.h b/include/trace/events/tcp.h
index 07cccca..ab34c56 100644
--- a/include/trace/events/tcp.h
+++ b/include/trace/events/tcp.h
@@ -25,6 +25,35 @@
 		tcp_state_name(TCP_CLOSING),		\
 		tcp_state_name(TCP_NEW_SYN_RECV))
 
+#define TP_STORE_V4MAPPED(__entry, saddr, daddr)		\
+	do {							\
+		struct in6_addr *pin6;				\
+								\
+		pin6 = (struct in6_addr *)__entry->saddr_v6;	\
+		ipv6_addr_set_v4mapped(saddr, pin6);		\
+		pin6 = (struct in6_addr *)__entry->daddr_v6;	\
+		ipv6_addr_set_v4mapped(daddr, pin6);		\
+	} while (0)
+
+#if IS_ENABLED(CONFIG_IPV6)
+#define TP_STORE_ADDRS(__entry, saddr, daddr, saddr6, daddr6)		\
+	do {								\
+		if (sk->sk_family = AF_INET6) {			\
+			struct in6_addr *pin6;				\
+									\
+			pin6 = (struct in6_addr *)__entry->saddr_v6;	\
+			*pin6 = saddr6;					\
+			pin6 = (struct in6_addr *)__entry->daddr_v6;	\
+			*pin6 = daddr6;					\
+		} else {						\
+			TP_STORE_V4MAPPED(__entry, saddr, daddr);	\
+		}							\
+	} while (0)
+#else
+#define TP_STORE_ADDRS(__entry, saddr, daddr, saddr6, daddr6)	\
+	TP_STORE_V4MAPPED(__entry, saddr, daddr)
+#endif
+
 /*
  * tcp event with arguments sk and skb
  *
@@ -50,7 +79,6 @@ DECLARE_EVENT_CLASS(tcp_event_sk_skb,
 
 	TP_fast_assign(
 		struct inet_sock *inet = inet_sk(sk);
-		struct in6_addr *pin6;
 		__be32 *p32;
 
 		__entry->skbaddr = skb;
@@ -65,20 +93,8 @@ DECLARE_EVENT_CLASS(tcp_event_sk_skb,
 		p32 = (__be32 *) __entry->daddr;
 		*p32 =  inet->inet_daddr;
 
-#if IS_ENABLED(CONFIG_IPV6)
-		if (sk->sk_family = AF_INET6) {
-			pin6 = (struct in6_addr *)__entry->saddr_v6;
-			*pin6 = sk->sk_v6_rcv_saddr;
-			pin6 = (struct in6_addr *)__entry->daddr_v6;
-			*pin6 = sk->sk_v6_daddr;
-		} else
-#endif
-		{
-			pin6 = (struct in6_addr *)__entry->saddr_v6;
-			ipv6_addr_set_v4mapped(inet->inet_saddr, pin6);
-			pin6 = (struct in6_addr *)__entry->daddr_v6;
-			ipv6_addr_set_v4mapped(inet->inet_daddr, pin6);
-		}
+		TP_STORE_ADDRS(__entry, inet->inet_saddr, inet->inet_daddr,
+			      sk->sk_v6_rcv_saddr, sk->sk_v6_daddr);
 	),
 
 	TP_printk("sport=%hu dport=%hu saddr=%pI4 daddr=%pI4 saddrv6=%pI6c daddrv6=%pI6c",
@@ -127,7 +143,6 @@ DECLARE_EVENT_CLASS(tcp_event_sk,
 
 	TP_fast_assign(
 		struct inet_sock *inet = inet_sk(sk);
-		struct in6_addr *pin6;
 		__be32 *p32;
 
 		__entry->skaddr = sk;
@@ -141,20 +156,8 @@ DECLARE_EVENT_CLASS(tcp_event_sk,
 		p32 = (__be32 *) __entry->daddr;
 		*p32 =  inet->inet_daddr;
 
-#if IS_ENABLED(CONFIG_IPV6)
-		if (sk->sk_family = AF_INET6) {
-			pin6 = (struct in6_addr *)__entry->saddr_v6;
-			*pin6 = sk->sk_v6_rcv_saddr;
-			pin6 = (struct in6_addr *)__entry->daddr_v6;
-			*pin6 = sk->sk_v6_daddr;
-		} else
-#endif
-		{
-			pin6 = (struct in6_addr *)__entry->saddr_v6;
-			ipv6_addr_set_v4mapped(inet->inet_saddr, pin6);
-			pin6 = (struct in6_addr *)__entry->daddr_v6;
-			ipv6_addr_set_v4mapped(inet->inet_daddr, pin6);
-		}
+		TP_STORE_ADDRS(__entry, inet->inet_saddr, inet->inet_daddr,
+			       sk->sk_v6_rcv_saddr, sk->sk_v6_daddr);
 	),
 
 	TP_printk("sport=%hu dport=%hu saddr=%pI4 daddr=%pI4 saddrv6=%pI6c daddrv6=%pI6c",
@@ -197,7 +200,6 @@ TRACE_EVENT(tcp_set_state,
 
 	TP_fast_assign(
 		struct inet_sock *inet = inet_sk(sk);
-		struct in6_addr *pin6;
 		__be32 *p32;
 
 		__entry->skaddr = sk;
@@ -213,20 +215,8 @@ TRACE_EVENT(tcp_set_state,
 		p32 = (__be32 *) __entry->daddr;
 		*p32 =  inet->inet_daddr;
 
-#if IS_ENABLED(CONFIG_IPV6)
-		if (sk->sk_family = AF_INET6) {
-			pin6 = (struct in6_addr *)__entry->saddr_v6;
-			*pin6 = sk->sk_v6_rcv_saddr;
-			pin6 = (struct in6_addr *)__entry->daddr_v6;
-			*pin6 = sk->sk_v6_daddr;
-		} else
-#endif
-		{
-			pin6 = (struct in6_addr *)__entry->saddr_v6;
-			ipv6_addr_set_v4mapped(inet->inet_saddr, pin6);
-			pin6 = (struct in6_addr *)__entry->daddr_v6;
-			ipv6_addr_set_v4mapped(inet->inet_daddr, pin6);
-		}
+		TP_STORE_ADDRS(__entry, inet->inet_saddr, inet->inet_daddr,
+			       sk->sk_v6_rcv_saddr, sk->sk_v6_daddr);
 	),
 
 	TP_printk("sport=%hu dport=%hu saddr=%pI4 daddr=%pI4 saddrv6=%pI6c daddrv6=%pI6c oldstate=%s newstate=%s",
@@ -256,7 +246,6 @@ TRACE_EVENT(tcp_retransmit_synack,
 
 	TP_fast_assign(
 		struct inet_request_sock *ireq = inet_rsk(req);
-		struct in6_addr *pin6;
 		__be32 *p32;
 
 		__entry->skaddr = sk;
@@ -271,20 +260,8 @@ TRACE_EVENT(tcp_retransmit_synack,
 		p32 = (__be32 *) __entry->daddr;
 		*p32 = ireq->ir_rmt_addr;
 
-#if IS_ENABLED(CONFIG_IPV6)
-		if (sk->sk_family = AF_INET6) {
-			pin6 = (struct in6_addr *)__entry->saddr_v6;
-			*pin6 = ireq->ir_v6_loc_addr;
-			pin6 = (struct in6_addr *)__entry->daddr_v6;
-			*pin6 = ireq->ir_v6_rmt_addr;
-		} else
-#endif
-		{
-			pin6 = (struct in6_addr *)__entry->saddr_v6;
-			ipv6_addr_set_v4mapped(ireq->ir_loc_addr, pin6);
-			pin6 = (struct in6_addr *)__entry->daddr_v6;
-			ipv6_addr_set_v4mapped(ireq->ir_rmt_addr, pin6);
-		}
+		TP_STORE_ADDRS(__entry, ireq->ir_loc_addr, ireq->ir_rmt_addr,
+			      ireq->ir_v6_loc_addr, ireq->ir_v6_rmt_addr);
 	),
 
 	TP_printk("sport=%hu dport=%hu saddr=%pI4 daddr=%pI4 saddrv6=%pI6c daddrv6=%pI6c",
