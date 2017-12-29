From: Masami Hiramatsu <mhiramat@kernel.org>
Date: Fri, 29 Dec 2017 02:47:55 +0000
Subject: [PATCH net-next v7 5/6] net: dccp: Add DCCP sendmsg trace event
Message-Id: <151451567536.17912.11150525484345559452.stgit@devbox>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Add DCCP sendmsg trace event (dccp/dccp_probe) for
replacing dccpprobe. User can trace this event via
ftrace or perftools.

Signed-off-by: Masami Hiramatsu <mhiramat@kernel.org>
---
  Changes in v5:
   - Fix to add local directory to include for trace.h.
     Thanks Steven!
  Changes in v7:
   - Avoid preprocessor directives in tracepoint macro args
     by sharing TP_STORE_ADDR_PORTS() macro with tcp.h.
---
 include/trace/events/net_probe_common.h |   44 ++++++++++++++++
 include/trace/events/tcp.h              |   39 --------------
 net/dccp/Makefile                       |    3 +
 net/dccp/proto.c                        |    5 ++
 net/dccp/trace.h                        |   84 +++++++++++++++++++++++++++++++
 5 files changed, 137 insertions(+), 38 deletions(-)
 create mode 100644 include/trace/events/net_probe_common.h
 create mode 100644 net/dccp/trace.h

diff --git a/include/trace/events/net_probe_common.h b/include/trace/events/net_probe_common.h
new file mode 100644
index 000000000000..3930119cab08
--- /dev/null
+++ b/include/trace/events/net_probe_common.h
@@ -0,0 +1,44 @@
+/* SPDX-License-Identifier: GPL-2.0 */
+
+#if !defined(_TRACE_NET_PROBE_COMMON_H) || defined(TRACE_HEADER_MULTI_READ)
+#define _TRACE_NET_PROBE_COMMON_H
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
+#endif
diff --git a/include/trace/events/tcp.h b/include/trace/events/tcp.h
index 4dea6342f7d4..1501ca91814f 100644
--- a/include/trace/events/tcp.h
+++ b/include/trace/events/tcp.h
@@ -279,44 +279,7 @@ TRACE_EVENT(tcp_retransmit_synack,
 		  __entry->saddr_v6, __entry->daddr_v6)
 );
 
-
-#define TP_STORE_ADDR_PORTS_V4(__entry, inet, sk)			\
-	do {								\
-		struct sockaddr_in *v4 = (void *)__entry->saddr;	\
-									\
-		v4->sin_family = AF_INET;				\
-		v4->sin_port = inet->inet_sport;			\
-		v4->sin_addr.s_addr = inet->inet_saddr;			\
-		v4 = (void *)__entry->daddr;				\
-		v4->sin_family = AF_INET;				\
-		v4->sin_port = inet->inet_dport;			\
-		v4->sin_addr.s_addr = inet->inet_daddr;			\
-	} while (0)
-
-#if IS_ENABLED(CONFIG_IPV6)
-
-#define TP_STORE_ADDR_PORTS(__entry, inet, sk)				\
-	do {								\
-		if (sk->sk_family = AF_INET6) {			\
-			struct sockaddr_in6 *v6 = (void *)__entry->saddr; \
-									\
-			v6->sin6_family = AF_INET6;			\
-			v6->sin6_port = inet->inet_sport;		\
-			v6->sin6_addr = inet6_sk(sk)->saddr;		\
-			v6 = (void *)__entry->daddr;			\
-			v6->sin6_family = AF_INET6;			\
-			v6->sin6_port = inet->inet_dport;		\
-			v6->sin6_addr = sk->sk_v6_daddr;		\
-		} else							\
-			TP_STORE_ADDR_PORTS_V4(__entry, inet, sk);	\
-	} while (0)
-
-#else
-
-#define TP_STORE_ADDR_PORTS(__entry, inet, sk)		\
-	TP_STORE_ADDR_PORTS_V4(__entry, inet, sk);
-
-#endif
+#include <trace/events/net_probe_common.h>
 
 TRACE_EVENT(tcp_probe,
 
diff --git a/net/dccp/Makefile b/net/dccp/Makefile
index 2e7b56097bc4..4215f13a63af 100644
--- a/net/dccp/Makefile
+++ b/net/dccp/Makefile
@@ -27,3 +27,6 @@ dccp-$(CONFIG_SYSCTL) += sysctl.o
 
 dccp_diag-y := diag.o
 dccp_probe-y := probe.o
+
+# build with local directory for trace.h
+CFLAGS_proto.o := -I$(src)
diff --git a/net/dccp/proto.c b/net/dccp/proto.c
index 7a75a1d3568b..fa7e92e08920 100644
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -38,6 +38,9 @@
 #include "dccp.h"
 #include "feat.h"
 
+#define CREATE_TRACE_POINTS
+#include "trace.h"
+
 DEFINE_SNMP_STAT(struct dccp_mib, dccp_statistics) __read_mostly;
 
 EXPORT_SYMBOL_GPL(dccp_statistics);
@@ -761,6 +764,8 @@ int dccp_sendmsg(struct sock *sk, struct msghdr *msg, size_t len)
 	int rc, size;
 	long timeo;
 
+	trace_dccp_probe(sk, len);
+
 	if (len > dp->dccps_mss_cache)
 		return -EMSGSIZE;
 
diff --git a/net/dccp/trace.h b/net/dccp/trace.h
new file mode 100644
index 000000000000..5062421beee9
--- /dev/null
+++ b/net/dccp/trace.h
@@ -0,0 +1,84 @@
+/* SPDX-License-Identifier: GPL-2.0 */
+#undef TRACE_SYSTEM
+#define TRACE_SYSTEM dccp
+
+#if !defined(_TRACE_DCCP_H) || defined(TRACE_HEADER_MULTI_READ)
+#define _TRACE_DCCP_H
+
+#include <net/sock.h>
+#include "dccp.h"
+#include "ccids/ccid3.h"
+#include <linux/tracepoint.h>
+#include <trace/events/net_probe_common.h>
+
+TRACE_EVENT(dccp_probe,
+
+	TP_PROTO(struct sock *sk, size_t size),
+
+	TP_ARGS(sk, size),
+
+	TP_STRUCT__entry(
+		/* sockaddr_in6 is always bigger than sockaddr_in */
+		__array(__u8, saddr, sizeof(struct sockaddr_in6))
+		__array(__u8, daddr, sizeof(struct sockaddr_in6))
+		__field(__u16, sport)
+		__field(__u16, dport)
+		__field(__u16, size)
+		__field(__u16, tx_s)
+		__field(__u32, tx_rtt)
+		__field(__u32, tx_p)
+		__field(__u32, tx_x_calc)
+		__field(__u64, tx_x_recv)
+		__field(__u64, tx_x)
+		__field(__u32, tx_t_ipi)
+	),
+
+	TP_fast_assign(
+		const struct inet_sock *inet = inet_sk(sk);
+		struct ccid3_hc_tx_sock *hc = NULL;
+
+		if (ccid_get_current_tx_ccid(dccp_sk(sk)) = DCCPC_CCID3)
+			hc = ccid3_hc_tx_sk(sk);
+
+		memset(__entry->saddr, 0, sizeof(struct sockaddr_in6));
+		memset(__entry->daddr, 0, sizeof(struct sockaddr_in6));
+
+		TP_STORE_ADDR_PORTS(__entry, inet, sk);
+
+		/* For filtering use */
+		__entry->sport = ntohs(inet->inet_sport);
+		__entry->dport = ntohs(inet->inet_dport);
+
+		__entry->size = size;
+		if (hc) {
+			__entry->tx_s = hc->tx_s;
+			__entry->tx_rtt = hc->tx_rtt;
+			__entry->tx_p = hc->tx_p;
+			__entry->tx_x_calc = hc->tx_x_calc;
+			__entry->tx_x_recv = hc->tx_x_recv >> 6;
+			__entry->tx_x = hc->tx_x >> 6;
+			__entry->tx_t_ipi = hc->tx_t_ipi;
+		} else {
+			__entry->tx_s = 0;
+			memset(&__entry->tx_rtt, 0, (void *)&__entry->tx_t_ipi -
+			       (void *)&__entry->tx_rtt +
+			       sizeof(__entry->tx_t_ipi));
+		}
+	),
+
+	TP_printk("src=%pISpc dest=%pISpc size=%d tx_s=%d tx_rtt=%d "
+		  "tx_p=%d tx_x_calc=%u tx_x_recv=%llu tx_x=%llu tx_t_ipi=%d",
+		  __entry->saddr, __entry->daddr, __entry->size,
+		  __entry->tx_s, __entry->tx_rtt, __entry->tx_p,
+		  __entry->tx_x_calc, __entry->tx_x_recv, __entry->tx_x,
+		  __entry->tx_t_ipi)
+);
+
+#endif /* _TRACE_TCP_H */
+
+/* This part must be outside protection */
+#undef TRACE_INCLUDE_PATH
+#define TRACE_INCLUDE_PATH .
+#undef TRACE_INCLUDE_FILE
+#define TRACE_INCLUDE_FILE trace
+#include <trace/define_trace.h>

