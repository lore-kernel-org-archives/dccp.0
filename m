From: Masami Hiramatsu <mhiramat@kernel.org>
Date: Fri, 29 Dec 2017 02:46:51 +0000
Subject: [PATCH net-next v7 3/6] net: sctp: Add SCTP ACK tracking trace event
Message-Id: <151451561086.17912.3469350051981038078.stgit@devbox>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Add SCTP ACK tracking trace event to trace the changes of SCTP
association state in response to incoming packets.
It is used for debugging SCTP congestion control algorithms,
and will replace sctp_probe module.

Note that this event a bit tricky. Since this consists of 2
events (sctp_probe and sctp_probe_path) so you have to enable
both events as below.

  # cd /sys/kernel/debug/tracing
  # echo 1 > events/sctp/sctp_probe/enable
  # echo 1 > events/sctp/sctp_probe_path/enable

Or, you can enable all the events under sctp.

  # echo 1 > events/sctp/enable

Since sctp_probe_path event is always invoked from sctp_probe
event, you can not see any output if you only enable
sctp_probe_path.

Signed-off-by: Masami Hiramatsu <mhiramat@kernel.org>
---
  Changes in v3:
   - Add checking whether sctp_probe_path event is enabled
     before iterating sctp paths to record. Thanks Steven.
  Changes in v4:
   - Move a temporal variable definition in the block.
   - Fix to cast pointer to unsigned long instead of __u64
     for 32bit environment.
---
 include/trace/events/sctp.h |   99 +++++++++++++++++++++++++++++++++++++++++++
 net/sctp/sm_statefuns.c     |    5 ++
 2 files changed, 104 insertions(+)
 create mode 100644 include/trace/events/sctp.h

diff --git a/include/trace/events/sctp.h b/include/trace/events/sctp.h
new file mode 100644
index 000000000000..7475c7be165a
--- /dev/null
+++ b/include/trace/events/sctp.h
@@ -0,0 +1,99 @@
+/* SPDX-License-Identifier: GPL-2.0 */
+#undef TRACE_SYSTEM
+#define TRACE_SYSTEM sctp
+
+#if !defined(_TRACE_SCTP_H) || defined(TRACE_HEADER_MULTI_READ)
+#define _TRACE_SCTP_H
+
+#include <net/sctp/structs.h>
+#include <linux/tracepoint.h>
+
+TRACE_EVENT(sctp_probe_path,
+
+	TP_PROTO(struct sctp_transport *sp,
+		 const struct sctp_association *asoc),
+
+	TP_ARGS(sp, asoc),
+
+	TP_STRUCT__entry(
+		__field(__u64, asoc)
+		__field(__u32, primary)
+		__array(__u8, ipaddr, sizeof(union sctp_addr))
+		__field(__u32, state)
+		__field(__u32, cwnd)
+		__field(__u32, ssthresh)
+		__field(__u32, flight_size)
+		__field(__u32, partial_bytes_acked)
+		__field(__u32, pathmtu)
+	),
+
+	TP_fast_assign(
+		__entry->asoc = (unsigned long)asoc;
+		__entry->primary = (sp = asoc->peer.primary_path);
+		memcpy(__entry->ipaddr, &sp->ipaddr, sizeof(union sctp_addr));
+		__entry->state = sp->state;
+		__entry->cwnd = sp->cwnd;
+		__entry->ssthresh = sp->ssthresh;
+		__entry->flight_size = sp->flight_size;
+		__entry->partial_bytes_acked = sp->partial_bytes_acked;
+		__entry->pathmtu = sp->pathmtu;
+	),
+
+	TP_printk("asoc=%#llx%s ipaddr=%pISpc state=%u cwnd=%u ssthresh=%u "
+		  "flight_size=%u partial_bytes_acked=%u pathmtu=%u",
+		  __entry->asoc, __entry->primary ? "(*)" : "",
+		  __entry->ipaddr, __entry->state, __entry->cwnd,
+		  __entry->ssthresh, __entry->flight_size,
+		  __entry->partial_bytes_acked, __entry->pathmtu)
+);
+
+TRACE_EVENT(sctp_probe,
+
+	TP_PROTO(const struct sctp_endpoint *ep,
+		 const struct sctp_association *asoc,
+		 struct sctp_chunk *chunk),
+
+	TP_ARGS(ep, asoc, chunk),
+
+	TP_STRUCT__entry(
+		__field(__u64, asoc)
+		__field(__u32, mark)
+		__field(__u16, bind_port)
+		__field(__u16, peer_port)
+		__field(__u32, pathmtu)
+		__field(__u32, rwnd)
+		__field(__u16, unack_data)
+	),
+
+	TP_fast_assign(
+		struct sk_buff *skb = chunk->skb;
+
+		__entry->asoc = (unsigned long)asoc;
+		__entry->mark = skb->mark;
+		__entry->bind_port = ep->base.bind_addr.port;
+		__entry->peer_port = asoc->peer.port;
+		__entry->pathmtu = asoc->pathmtu;
+		__entry->rwnd = asoc->peer.rwnd;
+		__entry->unack_data = asoc->unack_data;
+
+		if (trace_sctp_probe_path_enabled()) {
+			struct sctp_transport *sp;
+
+			list_for_each_entry(sp, &asoc->peer.transport_addr_list,
+					    transports) {
+				trace_sctp_probe_path(sp, asoc);
+			}
+		}
+	),
+
+	TP_printk("asoc=%#llx mark=%#x bind_port=%d peer_port=%d pathmtu=%d "
+		  "rwnd=%u unack_data=%d",
+		  __entry->asoc, __entry->mark, __entry->bind_port,
+		  __entry->peer_port, __entry->pathmtu, __entry->rwnd,
+		  __entry->unack_data)
+);
+
+#endif /* _TRACE_SCTP_H */
+
+/* This part must be outside protection */
+#include <trace/define_trace.h>
diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
index 541f34735346..eb7905ffe5f2 100644
--- a/net/sctp/sm_statefuns.c
+++ b/net/sctp/sm_statefuns.c
@@ -59,6 +59,9 @@
 #include <net/sctp/sm.h>
 #include <net/sctp/structs.h>
 
+#define CREATE_TRACE_POINTS
+#include <trace/events/sctp.h>
+
 static struct sctp_packet *sctp_abort_pkt_new(
 					struct net *net,
 					const struct sctp_endpoint *ep,
@@ -3219,6 +3222,8 @@ enum sctp_disposition sctp_sf_eat_sack_6_2(struct net *net,
 	struct sctp_sackhdr *sackh;
 	__u32 ctsn;
 
+	trace_sctp_probe(ep, asoc, chunk);
+
 	if (!sctp_vtag_verify(chunk, asoc))
 		return sctp_sf_pdiscard(net, ep, asoc, type, arg, commands);
 

