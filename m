From: Patrick McHardy <kaber@trash.net>
Date: Fri, 04 Apr 2008 15:41:01 +0000
Subject: DCCP conntrack/NAT
Message-Id: <47F64C0D.5080700@trash.net>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------030907030702040000010408"
List-Id: <dccp.vger.kernel.org>
To: dccp@vger.kernel.org

This is a multi-part message in MIME format.
--------------030907030702040000010408
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit

These two patches contain my old conntrack/NAT helper for DCCP,
updated to net-2.6.26.git and the missing parts (almost entirely)
added.

They both depend on some other netfilter patches, I've attached
them only hoping for some review :) A git tree which contains
the full set of patches is (once upload finishes) located at:

git://git.kernel.org/pub/scm/linux/kernel/git/kaber/nf-2.6.26.git

A few words on the patches:

The NAT part is pretty uninteresting, it simply rewrites the
ports and updates the checksum. The connection tracking module
performs tracking of the connection, its states (mainly for
appropriate timeout selection) and sequence number validation
for Response/Ack packets during connection establishment.
Window tracking and full sequence number validation is not
implemented yet, connection pickup (creating valid states for
connections not tracked from the beginning) is also not working
yet. The connection tracker is comparable to the 2.4 TCP
connection tracking helper.

The part that could really use some review by someone more familiar
with DCCP than me is the state transistion table. The transistions
should be mostly similar to those of a DCCP endpoint, the acceptable
packets in each state differ slightly since the firewall sits in the
middle and packets might get lost after passing though it. If someone
spots incorrect transistions, please let me know since chances are
good that its a bug.

For testing simply load the nf_conntrack_proto_dccp and
nf_nat_proto_dccp modules and set up NAT rules as usual.

Comments welcome.


--------------030907030702040000010408
Content-Type: text/x-diff;
 name="dccp-ct.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="dccp-ct.diff"

commit f448af3823a8de4260b0f45d7acc19db513a70fd
Author: Patrick McHardy <kaber@trash.net>
Date:   Thu Mar 20 15:15:55 2008 +0100

    [NETFILTER]: nf_conntrack: add DCCP protocol support
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/include/linux/netfilter/nf_conntrack_dccp.h b/include/linux/netfilter/nf_conntrack_dccp.h
new file mode 100644
index 0000000..73c4b68
--- /dev/null
+++ b/include/linux/netfilter/nf_conntrack_dccp.h
@@ -0,0 +1,27 @@
+#ifndef _NF_CONNTRACK_DCCP_H
+#define _NF_CONNTRACK_DCCP_H
+
+/* Exposed to userspace over nfnetlink */
+enum ct_dccp_states {
+	CT_DCCP_NONE,
+	CT_DCCP_REQUEST,
+	CT_DCCP_RESPOND,
+	CT_DCCP_PARTOPEN,
+	CT_DCCP_OPEN,
+	CT_DCCP_CLOSEREQ,
+	CT_DCCP_CLOSING,
+	CT_DCCP_TIMEWAIT,
+	CT_DCCP_IGNORE,
+	CT_DCCP_MAX,
+};
+
+#ifdef __KERNEL__
+
+struct nf_ct_dccp {
+	u_int8_t	state;
+	u_int64_t	handshake_seq;
+};
+
+#endif /* __KERNEL__ */
+
+#endif /* _NF_CONNTRACK_DCCP_H */
diff --git a/include/linux/netfilter/nfnetlink_conntrack.h b/include/linux/netfilter/nfnetlink_conntrack.h
index e3e1533..0a383ac 100644
--- a/include/linux/netfilter/nfnetlink_conntrack.h
+++ b/include/linux/netfilter/nfnetlink_conntrack.h
@@ -80,6 +80,7 @@ enum ctattr_l4proto {
 enum ctattr_protoinfo {
 	CTA_PROTOINFO_UNSPEC,
 	CTA_PROTOINFO_TCP,
+	CTA_PROTOINFO_DCCP,
 	__CTA_PROTOINFO_MAX
 };
 #define CTA_PROTOINFO_MAX (__CTA_PROTOINFO_MAX - 1)
@@ -95,6 +96,13 @@ enum ctattr_protoinfo_tcp {
 };
 #define CTA_PROTOINFO_TCP_MAX (__CTA_PROTOINFO_TCP_MAX - 1)
 
+enum ctattr_protoinfo_dccp {
+	CTA_PROTOINFO_DCCP_UNSPEC,
+	CTA_PROTOINFO_DCCP_STATE,
+	__CTA_PROTOINFO_DCCP_MAX,
+};
+#define CTA_PROTOINFO_DCCP_MAX (__CTA_PROTOINFO_DCCP_MAX - 1)
+
 enum ctattr_counters {
 	CTA_COUNTERS_UNSPEC,
 	CTA_COUNTERS_PACKETS,		/* old 64bit counters */
diff --git a/include/net/netfilter/nf_conntrack.h b/include/net/netfilter/nf_conntrack.h
index a3567a7..bb9fc85 100644
--- a/include/net/netfilter/nf_conntrack.h
+++ b/include/net/netfilter/nf_conntrack.h
@@ -20,6 +20,7 @@
 #include <asm/atomic.h>
 
 #include <linux/netfilter/nf_conntrack_tcp.h>
+#include <linux/netfilter/nf_conntrack_dccp.h>
 #include <linux/netfilter/nf_conntrack_sctp.h>
 #include <linux/netfilter/nf_conntrack_proto_gre.h>
 #include <net/netfilter/ipv4/nf_conntrack_icmp.h>
@@ -30,6 +31,7 @@
 /* per conntrack: protocol private data */
 union nf_conntrack_proto {
 	/* insert conntrack proto private data here */
+	struct nf_ct_dccp dccp;
 	struct ip_ct_sctp sctp;
 	struct ip_ct_tcp tcp;
 	struct ip_ct_icmp icmp;
diff --git a/include/net/netfilter/nf_conntrack_tuple.h b/include/net/netfilter/nf_conntrack_tuple.h
index 168c917..bdeec34 100644
--- a/include/net/netfilter/nf_conntrack_tuple.h
+++ b/include/net/netfilter/nf_conntrack_tuple.h
@@ -41,6 +41,9 @@ union nf_conntrack_man_proto
 	} icmp;
 	struct {
 		__be16 port;
+	} dccp;
+	struct {
+		__be16 port;
 	} sctp;
 	struct {
 		__be16 key;	/* GRE key is 32bit, PPtP only uses 16bit */
@@ -79,6 +82,9 @@ struct nf_conntrack_tuple
 			} icmp;
 			struct {
 				__be16 port;
+			} dccp;
+			struct {
+				__be16 port;
 			} sctp;
 			struct {
 				__be16 key;
diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index daf5b88..c1fc0f1 100644
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -86,6 +86,16 @@ config NF_CONNTRACK_EVENTS
 
 	  If unsure, say `N'.
 
+config NF_CT_PROTO_DCCP
+	tristate 'DCCP protocol connection tracking support (EXPERIMENTAL)'
+	depends on EXPERIMENTAL && NF_CONNTRACK
+	depends on NETFILTER_ADVANCED
+	help
+	  With this option enabled, the layer 3 independent connection
+	  tracking code will be able to do state tracking on DCCP connections.
+
+	  If unsure, say 'N'.
+
 config NF_CT_PROTO_GRE
 	tristate
 	depends on NF_CONNTRACK
diff --git a/net/netfilter/Makefile b/net/netfilter/Makefile
index ea75083..5c4b183 100644
--- a/net/netfilter/Makefile
+++ b/net/netfilter/Makefile
@@ -13,6 +13,7 @@ obj-$(CONFIG_NETFILTER_NETLINK_LOG) += nfnetlink_log.o
 obj-$(CONFIG_NF_CONNTRACK) += nf_conntrack.o
 
 # SCTP protocol connection tracking
+obj-$(CONFIG_NF_CT_PROTO_DCCP) += nf_conntrack_proto_dccp.o
 obj-$(CONFIG_NF_CT_PROTO_GRE) += nf_conntrack_proto_gre.o
 obj-$(CONFIG_NF_CT_PROTO_SCTP) += nf_conntrack_proto_sctp.o
 obj-$(CONFIG_NF_CT_PROTO_UDPLITE) += nf_conntrack_proto_udplite.o
diff --git a/net/netfilter/nf_conntrack_proto_dccp.c b/net/netfilter/nf_conntrack_proto_dccp.c
new file mode 100644
index 0000000..57d62b4
--- /dev/null
+++ b/net/netfilter/nf_conntrack_proto_dccp.c
@@ -0,0 +1,761 @@
+/*
+ * DCCP connection tracking protocol helper
+ *
+ * Copyright (c) 2005, 2006, 2008 Patrick McHardy <kaber@trash.net>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ *
+ */
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/init.h>
+#include <linux/sysctl.h>
+#include <linux/spinlock.h>
+#include <linux/skbuff.h>
+#include <linux/ip.h>
+#include <linux/dccp.h>
+
+#include <linux/netfilter/nfnetlink_conntrack.h>
+#include <net/netfilter/nf_conntrack.h>
+#include <net/netfilter/nf_conntrack_l4proto.h>
+#include <net/netfilter/nf_log.h>
+
+static DEFINE_RWLOCK(dccp_lock);
+
+static int nf_ct_dccp_loose __read_mostly = 1;
+
+/* Timeouts are based on values from RFC4340:
+ *
+ * - REQUEST:
+ *
+ *   8.1.2. Client Request
+ *
+ *   A client MAY give up on its DCCP-Requests after some time
+ *   (3 minutes, for example).
+ *
+ * - RESPOND:
+ *
+ *   8.1.3. Server Response
+ *
+ *   It MAY also leave the RESPOND state for CLOSED after a timeout of
+ *   not less than 4MSL (8 minutes);
+ *
+ * - PARTOPEN:
+ *
+ *   8.1.5. Handshake Completion
+ *
+ *   If the client remains in PARTOPEN for more than 4MSL (8 minutes),
+ *   it SHOULD reset the connection with Reset Code 2, "Aborted".
+ *
+ * - CLOSEREQ/CLOSING:
+ *
+ *   8.3. Termination
+ *
+ *   The retransmission timer should initially be set to go off in two
+ *   round-trip times and should back off to not less than once every
+ *   64 seconds ...
+ *
+ * - TIMEWAIT:
+ *
+ *   4.3. States
+ *
+ *   A server or client socket remains in this state for 2MSL (4 minutes)
+ *   after the connection has been town down, ...
+ */
+
+#define DCCP_MSL (2 * 60 * HZ)
+
+static unsigned int dccp_timeout[CT_DCCP_MAX] __read_mostly = {
+	[CT_DCCP_REQUEST]	= 2 * DCCP_MSL,
+	[CT_DCCP_RESPOND]	= 4 * DCCP_MSL,
+	[CT_DCCP_PARTOPEN]	= 4 * DCCP_MSL,
+	[CT_DCCP_OPEN]		= 5 * 86400 * HZ,
+	[CT_DCCP_CLOSEREQ]	= 64 * HZ,
+	[CT_DCCP_CLOSING]	= 64 * HZ,
+	[CT_DCCP_TIMEWAIT]	= 2 * DCCP_MSL,
+};
+
+static const char *dccp_state_names[] = {
+	[CT_DCCP_NONE]		= "NONE",
+	[CT_DCCP_REQUEST]	= "REQUEST",
+	[CT_DCCP_RESPOND]	= "RESPOND",
+	[CT_DCCP_PARTOPEN]	= "PARTOPEN",
+	[CT_DCCP_OPEN]		= "OPEN",
+	[CT_DCCP_CLOSEREQ]	= "CLOSEREQ",
+	[CT_DCCP_CLOSING]	= "CLOSING",
+	[CT_DCCP_TIMEWAIT]	= "TIMEWAIT",
+	[CT_DCCP_IGNORE]	= "IGNORE",
+	[CT_DCCP_MAX]		= "INVALID",
+};
+
+#define sNO	CT_DCCP_NONE
+#define sRQ	CT_DCCP_REQUEST
+#define sRS	CT_DCCP_RESPOND
+#define sPO	CT_DCCP_PARTOPEN
+#define sOP	CT_DCCP_OPEN
+#define sCR	CT_DCCP_CLOSEREQ
+#define sCG	CT_DCCP_CLOSING
+#define sTW	CT_DCCP_TIMEWAIT
+#define sIG	CT_DCCP_IGNORE
+#define sIV	CT_DCCP_MAX
+
+/*
+ * DCCP state transistion table
+ *
+ * The assumption is the same as for TCP tracking:
+ *
+ * We are the man in the middle. All the packets go through us but might
+ * get lost in transit to the destination. It is assumed that the destination
+ * can't receive segments we haven't seen.
+ *
+ * The following states exist:
+ *
+ * NONE:	Initial state
+ * REQUEST:	Request seen, waiting for Response from server
+ * RESPOND:	Response from server seen, waiting for Ack from client
+ * PARTOPEN:	Ack after Response seen, waiting for packet other than Response,
+ * 		Reset or Sync from server
+ * OPEN:	RPcket other than Response, Reset or Sync seen
+ * CLOSEREQ:	CloseReq from server seen, expecting Close from client
+ * CLOSING:	Close seen, expecting Reset
+ * TIMEWAIT:	Reset seen
+ * IGNORE:	Not determinable whether packet is valid
+ *
+ * Some states exist only on one side of the connection: REQUEST, RESPOND,
+ * PARTOPEN, CLOSEREQ. For the other side these states are equivalent to
+ * the one it was in before.
+ *
+ * Packets are marked as ignored (sIG) if we don't know if they're valid
+ * (for example a reincarnation of a connection we didn't notice is dead
+ * already) and the server may send back a connection closing DCCP_RESET
+ * or a DCCP_RESPONSE.
+ */
+static u_int8_t dccp_state_table[IP_CT_DIR_MAX][DCCP_PKT_SYNCACK + 1][CT_DCCP_MAX] = {
+	[IP_CT_DIR_ORIGINAL] = {
+		[DCCP_PKT_REQUEST] = {
+		/*
+		 * sNO -> sRQ		Regular Request
+		 * sRQ -> sRQ		Retransmitted Request or reincarnation
+		 * sRS -> sRS		Retransmitted Request (apparently Response
+		 * 			got lost after we saw it) or reincarnation
+		 * sPO -> sIG		Request during PARTOPEN state, server will ignore it
+		 * sOP -> sIG		Request during OPEN state: server will ignore it
+		 * sCR -> sIG		MUST respond with Close to CloseReq (8.3.)
+		 * sCG -> sIG
+		 * sTW -> sIG		Time-wait
+		 *
+		 *	sNO, sRQ, sRS, sPO. sOP, sCR, sCG, sTW, */
+			sRQ, sRQ, sRS, sIG, sIG, sIG, sIG, sIG,
+		},
+		[DCCP_PKT_RESPONSE] = {
+		/*
+		 * A Response in the original direction is always invalid.
+		 *
+		 *	sNO, sRQ, sRS, sPO, sOP, sCR, sCG, sTW */
+			sIV, sIV, sIV, sIV, sIV, sIV, sIV, sIV,
+		},
+		[DCCP_PKT_ACK] = {
+		/*
+		 * sNO -> sIV		No connection
+		 * sRQ -> sIV		No connection
+		 * sRS -> sPO		Ack for Response, move to PARTOPEN (8.1.5.)
+		 * sPO -> sPO		Retransmitted Ack for Response, remain in PARTOPEN
+		 * sOP -> sOP		Regular ACK, remain in OPEN
+		 * sCR -> sCR		Ack in CLOSEREQ MAY be processed (8.3.)
+		 * sCG -> sCG		Ack in CLOSING MAY be processed (8.3.)
+		 * sTW -> sIV
+		 *
+		 *	sNO, sRQ, sRS, sPO, sOP, sCR, sCG, sTW */
+			sOP, sIV, sPO, sPO, sOP, sCR, sCG, sIV
+		},
+		[DCCP_PKT_DATA] = {
+		/*
+		 * sNO -> sIV		No connection
+		 * sRQ -> sIV		No connection
+		 * sRS -> sIV		No connection
+		 * sPO -> sIV		MUST use DataAck in PARTOPEN state (8.1.5.)
+		 * sOP -> sOP		Regular Data packet
+		 * sCR -> sCR		Data in CLOSEREQ MAY be processed (8.3.)
+		 * sCG -> sCG		Data in CLOSING MAY be processed (8.3.)
+		 * sTW -> sIV
+		 *
+		 *	sNO, sRQ, sRS, sPO, sOP, sCR, sCG, sTW */
+			sIV, sIV, sIV, sIV, sOP, sCR, sCG, sIV,
+		},
+		[DCCP_PKT_DATAACK] = {
+		/*
+		 * sNO -> sIV		No connection
+		 * sRQ -> sIV		No connection
+		 * sRS -> sIV		No connection
+		 * sPO -> sPO		Remain in PARTOPEN state
+		 * sOP -> sOP		Regular DataAck packet in OPEN state
+		 * sCR -> sCR		DataAck in CLOSEREQ MAY be processed (8.3.)
+		 * sCG -> sCG		DataAck in CLOSING MAY be processed (8.3.)
+		 * sTW -> sIV
+		 *
+		 *	sNO, sRQ, sRS, sPO, sOP, sCR, sCG, sTW */
+			sIV, sIV, sIV, sPO, sOP, sCR, sCG, sIV
+		},
+		[DCCP_PKT_CLOSEREQ] = {
+		/*
+		 * CLOSEREQ may only be sent by the server.
+		 *
+		 *	sNO, sRQ, sRS, sPO, sOP, sCR, sCG, sTW */
+			sIV, sIV, sIV, sIV, sIV, sIV, sIV, sIV
+		},
+		[DCCP_PKT_CLOSE] = {
+		/*
+		 * sNO -> sIV		No connection
+		 * sRQ -> sIV		No connection
+		 * sRS -> sIV		No connection
+		 * sPO -> sCG		Client-initiated close
+		 * sOP -> sCG		Client-initiated close
+		 * sCR -> sCG		Close in response to CloseReq (8.3.)
+		 * sCG -> sCG		Retransmit
+		 * sTW -> sIV		Late retransmit, already in TIME_WAIT
+		 *
+		 *	sNO, sRQ, sRS, sPO, sOP, sCR, sCG, sTW */
+			sIV, sIV, sIV, sCG, sCG, sCG, sIV, sIV
+		},
+		[DCCP_PKT_RESET] = {
+		/*
+		 * sNO -> sIV		No connection
+		 * sRQ -> sTW		Sync received or timeout, SHOULD send Reset (8.1.1.)
+		 * sRS -> sTW		Response received without Request
+		 * sPO -> sTW		Timeout, SHOULD send Reset (8.1.5.)
+		 * sOP -> sTW		Connection reset
+		 * sCR -> sTW		Connection reset
+		 * sCG -> sTW		Connection reset
+		 * sTW -> sIG		Ignore (don't refresh timer)
+		 *
+		 *	sNO, sRQ, sRS, sPO, sOP, sCR, sCG, sTW */
+			sIV, sTW, sTW, sTW, sTW, sTW, sTW, sIG
+		},
+		[DCCP_PKT_SYNC] = {
+		/*
+		 * We currently ignore Sync packets
+		 *
+		 *	sNO, sRQ, sRS, sPO, sOP, sCR, sCG, sTW */
+			sIG, sIG, sIG, sIG, sIG, sIG, sIG, sIG,
+		},
+		[DCCP_PKT_SYNCACK] = {
+		/*
+		 * We currently ignore SyncAck packets
+		 *
+		 *	sNO, sRQ, sRS, sPO, sOP, sCR, sCG, sTW */
+			sIG, sIG, sIG, sIG, sIG, sIG, sIG, sIG,
+		},
+	},
+	[IP_CT_DIR_REPLY] = {
+		[DCCP_PKT_REQUEST] = {
+		/*
+		 * A Request in the reply direction is always invalid.
+		 *
+		 *	sNO, sRQ, sRS, sPO, sOP, sCR, sCG, sTW */
+			sIV, sIV, sIV, sIV, sIV, sIV, sIV, sIV
+		},
+		[DCCP_PKT_RESPONSE] = {
+		/*
+		 * sNO -> sIV		Response without Request
+		 * sRQ -> sRS		Response to clients Request
+		 * sRS -> sRS		Retransmitted Response (8.1.3. SHOULD NOT)
+		 * sPO -> sIG		Response to an ignored Request or late retransmit
+		 * sOP -> sIG		Invalid
+		 * sCR -> sIG		Invalid
+		 * sCG -> sIG		Invalid
+		 * sTW -> sIG		Invalid
+		 *
+		 *	sNO, sRQ, sRS, sPO, sOP, sCR, sCG, sTW */
+			sIV, sRS, sRS, sIG, sIG, sIG, sIG, sIG
+		},
+		[DCCP_PKT_ACK] = {
+		/*
+		 * sNO -> sIV		No connection
+		 * sRQ -> sIV		No connection
+		 * sRS -> sIV		No connection
+		 * sPO -> sOP		Enter OPEN state (8.1.5.)
+		 * sOP -> sOP		Regular Ack in OPEN state
+		 * sCR -> sIV		Waiting for Close from client
+		 * sCG -> sCG		Ack in CLOSING MAY be processed (8.3.)
+		 * sTW -> sIV
+		 *
+		 *	sNO, sRQ, sRS, sPO, sOP, sCR, sCG, sTW */
+			sIV, sIV, sIV, sOP, sOP, sIV, sCG, sIV
+		},
+		[DCCP_PKT_DATA] = {
+		/*
+		 * sNO -> sIV		No connection
+		 * sRQ -> sIV		No connection
+		 * sRS -> sIV		No connection
+		 * sPO -> sOP		Enter OPEN state (8.1.5.)
+		 * sOP -> sOP		Regular Data packet in OPEN state
+		 * sCR -> sIV		Waiting for Close from client
+		 * sCG -> sCG		Data in CLOSING MAY be processed (8.3.)
+		 * sTW -> sIV
+		 *
+		 *	sNO, sRQ, sRS, sPO, sOP, sCR, sCG, sTW */
+			sIV, sIV, sIV, sOP, sOP, sIV, sCG, sIV
+		},
+		[DCCP_PKT_DATAACK] = {
+		/*
+		 * sNO -> sIV		No connection
+		 * sRQ -> sIV		No connection
+		 * sRS -> sIV		No connection
+		 * sPO -> sOP		Enter OPEN state (8.1.5.)
+		 * sOP -> sOP		Regular DataAck in OPEN state
+		 * sCR -> sIV		Waiting for Close from client
+		 * sCG -> sCG		Data in CLOSING MAY be processed (8.3.)
+		 * sTW -> sIV
+		 *
+		 *	sNO, sRQ, sRS, sPO, sOP, sCR, sCG, sTW */
+			sIV, sIV, sIV, sOP, sOP, sIV, sCG, sIV
+		},
+		[DCCP_PKT_CLOSEREQ] = {
+		/*
+		 * sNO -> sIV		No connection
+		 * sRQ -> sIV		No connection
+		 * sRS -> sIV		No connection
+		 * sPO -> sOP -> sCR	Move directly to CLOSE_REQ (8.1.5.)
+		 * sOP -> sCR		CloseReq in OPEN state
+		 * sCR -> sCR		Retransmit
+		 * sCG -> sIV		Already closing
+		 * sTW -> sIV		Already closed
+		 *
+		 *	sNO, sRQ, sRS, sPO, sOP, sCR, sCG, sTW */
+			sIV, sIV, sIV, sCR, sCR, sCR, sIV, sIV
+		},
+		[DCCP_PKT_CLOSE] = {
+		/*
+		 * sNO -> sIV		No connection
+		 * sRQ -> sIV		No connection
+		 * sRS -> sIV		No connection
+		 * sPO -> sOP -> sCG	Move direcly to CLOSING
+		 * sOP -> sCG		Move to CLOSING
+		 * sCR -> sCG		Waiting for close from client
+		 * sCG -> sCG		Retransmit
+		 * sTW -> sIV		Already closed
+		 *
+		 *	sNO, sRQ, sRS, sPO, sOP, sCR, sCG, sTW */
+			sIV, sIV, sIV, sCG, sCG, sCG, sCG, sIV
+		},
+		[DCCP_PKT_RESET] = {
+		/*
+		 * sNO -> sIV		No connection
+		 * sRQ -> sTW		Reset in response to Request
+		 * sRS -> sTW		Timeout, SHOULD send Reset (8.1.3.)
+		 * sPO -> sTW		Timeout, SHOULD send Reset (8.1.3.)
+		 * sOP -> sTW
+		 * sCR -> sTW
+		 * sCG -> sTW
+		 * sTW -> sIG		Ignore (don't refresh timer)
+		 *
+		 *	sNO, sRQ, sRS, sPO, sOP, sCR, sCG, sTW, sTW */
+			sIV, sTW, sTW, sTW, sTW, sTW, sTW, sTW, sIG
+		},
+		[DCCP_PKT_SYNC] = {
+		/*
+		 * We currently ignore Sync packets
+		 *
+		 *	sNO, sRQ, sRS, sPO, sOP, sCR, sCG, sTW */
+			sIG, sIG, sIG, sIG, sIG, sIG, sIG, sIG,
+		},
+		[DCCP_PKT_SYNCACK] = {
+		/*
+		 * We currently ignore SyncAck packets
+		 *
+		 *	sNO, sRQ, sRS, sPO, sOP, sCR, sCG, sTW */
+			sIG, sIG, sIG, sIG, sIG, sIG, sIG, sIG,
+		},
+	},
+};
+
+static int dccp_pkt_to_tuple(const struct sk_buff *skb, unsigned int dataoff,
+			     struct nf_conntrack_tuple *tuple)
+{
+	struct dccp_hdr _hdr, *dh;
+
+	dh = skb_header_pointer(skb, dataoff, sizeof(_hdr), &_hdr);
+	if (dh == NULL)
+		return 0;
+
+	tuple->src.u.dccp.port = dh->dccph_sport;
+	tuple->dst.u.dccp.port = dh->dccph_dport;
+	return 1;
+}
+
+static int dccp_invert_tuple(struct nf_conntrack_tuple *inv,
+			     const struct nf_conntrack_tuple *tuple)
+{
+	inv->src.u.dccp.port = tuple->dst.u.dccp.port;
+	inv->dst.u.dccp.port = tuple->src.u.dccp.port;
+	return 1;
+}
+
+static int dccp_new(struct nf_conn *ct, const struct sk_buff *skb,
+		    unsigned int dataoff)
+{
+	int pf = ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple.src.l3num;
+	struct dccp_hdr _dh, *dh;
+	char *msg;
+	u_int8_t state;
+
+	dh = skb_header_pointer(skb, dataoff, sizeof(_dh), &dh);
+	BUG_ON(dh == NULL);
+
+	state = dccp_state_table[IP_CT_DIR_ORIGINAL][dh->dccph_type][CT_DCCP_NONE];
+	switch (state) {
+	default:
+		if (nf_ct_dccp_loose == 0) {
+			msg = "nf_ct_dccp: not picking up existing connection ";
+			goto out_invalid;
+		}
+	case CT_DCCP_REQUEST:
+		break;
+	case CT_DCCP_MAX:
+		msg = "nf_ct_dccp: invalid state transition ";
+		goto out_invalid;
+	}
+
+	ct->proto.dccp.state = CT_DCCP_NONE;
+	return 1;
+
+out_invalid:
+	if (LOG_INVALID(IPPROTO_DCCP))
+		nf_log_packet(pf, 0, skb, NULL, NULL, NULL, msg);
+	return 0;
+}
+
+static u64 dccp_ack_seq(const struct dccp_hdr *dh)
+{
+	const struct dccp_hdr_ack_bits *dhack;
+
+	dhack = (void *)dh + __dccp_basic_hdr_len(dh);
+	return ((u64)ntohs(dhack->dccph_ack_nr_high) << 32) +
+		     ntohl(dhack->dccph_ack_nr_low);
+}
+
+static int dccp_packet(struct nf_conn *ct, const struct sk_buff *skb,
+		       unsigned int dataoff, enum ip_conntrack_info ctinfo,
+		       int pf, unsigned int hooknum)
+{
+	struct dccp_hdr _dh, *dh;
+	u_int8_t type, old_state, new_state;
+
+	dh = skb_header_pointer(skb, dataoff, sizeof(_dh), &dh);
+	BUG_ON(dh == NULL);
+	type = dh->dccph_type;
+
+	if (type == DCCP_PKT_RESET &&
+	    !test_bit(IPS_SEEN_REPLY_BIT, &ct->status)) {
+		/* Tear down connection immediately if only reply is a RESET */
+		if (del_timer(&ct->timeout))
+			ct->timeout.function((unsigned long)ct);
+		return NF_ACCEPT;
+	}
+
+	write_lock_bh(&dccp_lock);
+
+	old_state = ct->proto.dccp.state;
+	new_state = dccp_state_table[CTINFO2DIR(ctinfo)][type][old_state];
+
+	switch (new_state) {
+	case CT_DCCP_RESPOND:
+		if (old_state == CT_DCCP_REQUEST)
+			ct->proto.dccp.handshake_seq = dccp_hdr_seq(dh);
+		break;
+	case CT_DCCP_PARTOPEN:
+		if (old_state == CT_DCCP_RESPOND &&
+		    type == DCCP_PKT_ACK &&
+		    dccp_ack_seq(dh) == ct->proto.dccp.handshake_seq)
+			set_bit(IPS_ASSURED_BIT, &ct->status);
+		break;
+	case CT_DCCP_IGNORE:
+		write_unlock_bh(&dccp_lock);
+		if (LOG_INVALID(IPPROTO_DCCP))
+			nf_log_packet(pf, 0, skb, NULL, NULL, NULL,
+				      "nf_ct_dccp: invalid packet ignored ");
+		return NF_ACCEPT;
+	case CT_DCCP_MAX:
+		write_unlock_bh(&dccp_lock);
+		if (LOG_INVALID(IPPROTO_DCCP))
+			nf_log_packet(pf, 0, skb, NULL, NULL, NULL,
+				      "nf_ct_dccp: invalid state transition ");
+		return -NF_ACCEPT;
+	}
+
+	ct->proto.dccp.state = new_state;
+	write_unlock_bh(&dccp_lock);
+	nf_ct_refresh_acct(ct, ctinfo, skb, dccp_timeout[new_state]);
+
+	return NF_ACCEPT;
+}
+
+static int dccp_error(struct sk_buff *skb, unsigned int dataoff,
+		      enum ip_conntrack_info *ctinfo, int pf,
+		      unsigned int hooknum)
+{
+	struct dccp_hdr _dh, *dh;
+	unsigned int dccp_len = skb->len - dataoff;
+	unsigned int cscov;
+	const char *msg;
+
+	dh = skb_header_pointer(skb, dataoff, sizeof(_dh), &dh);
+	if (dh == NULL) {
+		msg = "nf_ct_dccp: short packet ";
+		goto out_invalid;
+	}
+
+	if (dh->dccph_doff * 4 < sizeof(struct dccp_hdr) ||
+	    dh->dccph_doff * 4 > dccp_len) {
+		msg = "nf_ct_dccp: truncated/malformed packet ";
+		goto out_invalid;
+	}
+
+	cscov = dccp_len;
+	if (dh->dccph_cscov) {
+		cscov = (dh->dccph_cscov - 1) * 4;
+		if (cscov > dccp_len) {
+			msg = "nf_ct_dccp: bad checksum coverage ";
+			goto out_invalid;
+		}
+	}
+
+	if (nf_conntrack_checksum && hooknum == NF_INET_PRE_ROUTING &&
+	    nf_checksum_partial(skb, hooknum, dataoff, cscov, IPPROTO_DCCP,
+				pf)) {
+		msg = "nf_ct_dccp: bad checksum ";
+		goto out_invalid;
+	}
+
+	if (dh->dccph_type >= DCCP_PKT_INVALID) {
+		msg = "nf_ct_dccp: reserved packet type ";
+		goto out_invalid;
+	}
+
+	return NF_ACCEPT;
+
+out_invalid:
+	if (LOG_INVALID(IPPROTO_DCCP))
+		nf_log_packet(pf, 0, skb, NULL, NULL, NULL, msg);
+	return -NF_ACCEPT;
+}
+
+static int dccp_print_tuple(struct seq_file *s,
+			    const struct nf_conntrack_tuple *tuple)
+{
+	return seq_printf(s, "sport=%hu dport=%hu ",
+			  ntohs(tuple->src.u.dccp.port),
+			  ntohs(tuple->dst.u.dccp.port));
+}
+
+static int dccp_print_conntrack(struct seq_file *s, const struct nf_conn *ct)
+{
+	return seq_printf(s, "%s ", dccp_state_names[ct->proto.dccp.state]);
+}
+
+#if defined(CONFIG_NF_CT_NETLINK) || defined(CONFIG_NF_CT_NETLINK_MODULE)
+static int dccp_to_nlattr(struct sk_buff *skb, struct nlattr *nla,
+			  const struct nf_conn *ct)
+{
+	struct nlattr *nest_parms;
+
+	read_lock_bh(&dccp_lock);
+	nest_parms = nla_nest_start(skb, CTA_PROTOINFO_DCCP | NLA_F_NESTED);
+	if (!nest_parms)
+		goto nla_put_failure;
+	NLA_PUT_U8(skb, CTA_PROTOINFO_DCCP_STATE, ct->proto.dccp.state);
+	nla_nest_end(skb, nest_parms);
+	read_unlock_bh(&dccp_lock);
+	return 0;
+
+nla_put_failure:
+	read_unlock_bh(&dccp_lock);
+	return -1;
+}
+
+static const struct nla_policy dccp_nla_policy[CTA_PROTOINFO_DCCP_MAX + 1] = {
+	[CTA_PROTOINFO_DCCP_STATE]	= { .type = NLA_U8 },
+};
+
+static int nlattr_to_dccp(struct nlattr *cda[], struct nf_conn *ct)
+{
+	struct nlattr *attr = cda[CTA_PROTOINFO_DCCP];
+	struct nlattr *tb[CTA_PROTOINFO_DCCP_MAX + 1];
+	int err;
+
+	if (!attr)
+		return 0;
+
+	err = nla_parse_nested(tb, CTA_PROTOINFO_DCCP_MAX, attr,
+			       dccp_nla_policy);
+	if (err < 0)
+		return err;
+
+	if (!tb[CTA_PROTOINFO_DCCP_STATE] ||
+	    nla_get_u8(tb[CTA_PROTOINFO_DCCP_STATE]) >= CT_DCCP_MAX)
+		return -EINVAL;
+
+	write_lock_bh(&dccp_lock);
+	ct->proto.dccp.state = nla_get_u8(tb[CTA_PROTOINFO_DCCP_STATE]);
+	write_unlock_bh(&dccp_lock);
+	return 0;
+}
+#endif
+
+#ifdef CONFIG_SYSCTL
+static unsigned int dccp_sysctl_table_users;
+static struct ctl_table_header *dccp_sysctl_header;
+static ctl_table dccp_sysctl_table[] = {
+	{
+		.ctl_name	= CTL_UNNUMBERED,
+		.procname	= "nf_conntrack_dccp_timeout_request",
+		.data		= &dccp_timeout[CT_DCCP_REQUEST],
+		.maxlen		= sizeof(unsigned int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec_jiffies,
+	},
+	{
+		.ctl_name	= CTL_UNNUMBERED,
+		.procname	= "nf_conntrack_dccp_timeout_respond",
+		.data		= &dccp_timeout[CT_DCCP_RESPOND],
+		.maxlen		= sizeof(unsigned int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec_jiffies,
+	},
+	{
+		.ctl_name	= CTL_UNNUMBERED,
+		.procname	= "nf_conntrack_dccp_timeout_partopen",
+		.data		= &dccp_timeout[CT_DCCP_PARTOPEN],
+		.maxlen		= sizeof(unsigned int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec_jiffies,
+	},
+	{
+		.ctl_name	= CTL_UNNUMBERED,
+		.procname	= "nf_conntrack_dccp_timeout_open",
+		.data		= &dccp_timeout[CT_DCCP_OPEN],
+		.maxlen		= sizeof(unsigned int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec_jiffies,
+	},
+	{
+		.ctl_name	= CTL_UNNUMBERED,
+		.procname	= "nf_conntrack_dccp_timeout_closereq",
+		.data		= &dccp_timeout[CT_DCCP_CLOSEREQ],
+		.maxlen		= sizeof(unsigned int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec_jiffies,
+	},
+	{
+		.ctl_name	= CTL_UNNUMBERED,
+		.procname	= "nf_conntrack_dccp_timeout_closing",
+		.data		= &dccp_timeout[CT_DCCP_CLOSING],
+		.maxlen		= sizeof(unsigned int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec_jiffies,
+	},
+	{
+		.ctl_name	= CTL_UNNUMBERED,
+		.procname	= "nf_conntrack_dccp_timeout_timewait",
+		.data		= &dccp_timeout[CT_DCCP_TIMEWAIT],
+		.maxlen		= sizeof(unsigned int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec_jiffies,
+	},
+	{
+		.ctl_name	= CTL_UNNUMBERED,
+		.procname	= "nf_conntrack_dccp_loose",
+		.data		= &nf_ct_dccp_loose,
+		.maxlen		= sizeof(nf_ct_dccp_loose),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec,
+	},
+	{
+		.ctl_name	= 0,
+	}
+};
+#endif /* CONFIG_SYSCTL */
+
+static struct nf_conntrack_l4proto dccp_proto4 __read_mostly = {
+	.l3proto		= AF_INET,
+	.l4proto		= IPPROTO_DCCP,
+	.name			= "dccp",
+	.pkt_to_tuple		= dccp_pkt_to_tuple,
+	.invert_tuple		= dccp_invert_tuple,
+	.new			= dccp_new,
+	.packet			= dccp_packet,
+	.error			= dccp_error,
+	.print_tuple		= dccp_print_tuple,
+	.print_conntrack	= dccp_print_conntrack,
+#if defined(CONFIG_NF_CT_NETLINK) || defined(CONFIG_NF_CT_NETLINK_MODULE)
+	.to_nlattr		= dccp_to_nlattr,
+	.from_nlattr		= nlattr_to_dccp,
+	.tuple_to_nlattr	= nf_ct_port_tuple_to_nlattr,
+	.nlattr_to_tuple	= nf_ct_port_nlattr_to_tuple,
+	.nla_policy		= nf_ct_port_nla_policy,
+#endif
+#ifdef CONFIG_SYSCTL
+	.ctl_table_users	= &dccp_sysctl_table_users,
+	.ctl_table_header	= &dccp_sysctl_header,
+	.ctl_table		= dccp_sysctl_table,
+#endif
+};
+
+static struct nf_conntrack_l4proto dccp_proto6 __read_mostly = {
+	.l3proto		= AF_INET6,
+	.l4proto		= IPPROTO_DCCP,
+	.name			= "dccp",
+	.pkt_to_tuple		= dccp_pkt_to_tuple,
+	.invert_tuple		= dccp_invert_tuple,
+	.new			= dccp_new,
+	.packet			= dccp_packet,
+	.error			= dccp_error,
+	.print_tuple		= dccp_print_tuple,
+	.print_conntrack	= dccp_print_conntrack,
+#if defined(CONFIG_NF_CT_NETLINK) || defined(CONFIG_NF_CT_NETLINK_MODULE)
+	.to_nlattr		= dccp_to_nlattr,
+	.from_nlattr		= nlattr_to_dccp,
+	.tuple_to_nlattr	= nf_ct_port_tuple_to_nlattr,
+	.nlattr_to_tuple	= nf_ct_port_nlattr_to_tuple,
+	.nla_policy		= nf_ct_port_nla_policy,
+#endif
+#ifdef CONFIG_SYSCTL
+	.ctl_table_users	= &dccp_sysctl_table_users,
+	.ctl_table_header	= &dccp_sysctl_header,
+	.ctl_table		= dccp_sysctl_table,
+#endif
+};
+
+static int __init nf_conntrack_proto_dccp_init(void)
+{
+	int err;
+
+	err = nf_conntrack_l4proto_register(&dccp_proto4);
+	if (err < 0)
+		goto err1;
+
+	err = nf_conntrack_l4proto_register(&dccp_proto6);
+	if (err < 0)
+		goto err2;
+	return 0;
+
+err2:
+	nf_conntrack_l4proto_unregister(&dccp_proto4);
+err1:
+	return err;
+}
+
+static void __exit nf_conntrack_proto_dccp_fini(void)
+{
+	nf_conntrack_l4proto_unregister(&dccp_proto6);
+	nf_conntrack_l4proto_unregister(&dccp_proto4);
+}
+
+module_init(nf_conntrack_proto_dccp_init);
+module_exit(nf_conntrack_proto_dccp_fini);
+
+MODULE_AUTHOR("Patrick McHardy <kaber@trash.net>");
+MODULE_DESCRIPTION("DCCP connection tracking protocol helper");
+MODULE_LICENSE("GPL");

--------------030907030702040000010408
Content-Type: text/x-diff;
 name="dccp-nat.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="dccp-nat.diff"

commit d014df2fba76bae3affb8a9c5a91de704306d4a1
Author: Patrick McHardy <kaber@trash.net>
Date:   Thu Mar 20 15:15:57 2008 +0100

    [NETFILTER]: nf_nat: add DCCP protocol support
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/ipv4/netfilter/Kconfig b/net/ipv4/netfilter/Kconfig
index c5bd284..fde3eac 100644
--- a/net/ipv4/netfilter/Kconfig
+++ b/net/ipv4/netfilter/Kconfig
@@ -241,6 +241,11 @@ config NF_NAT_SNMP_BASIC
 #           <expr> '&&' <expr>                   (6)
 #
 # (6) Returns the result of min(/expr/, /expr/).
+config NF_NAT_PROTO_DCCP
+	tristate
+	depends on NF_NAT && NF_CT_PROTO_DCCP
+	default NF_NAT && NF_CT_PROTO_DCCP
+
 config NF_NAT_PROTO_GRE
 	tristate
 	depends on NF_NAT && NF_CT_PROTO_GRE
diff --git a/net/ipv4/netfilter/Makefile b/net/ipv4/netfilter/Makefile
index 332f46f..74d8dbd 100644
--- a/net/ipv4/netfilter/Makefile
+++ b/net/ipv4/netfilter/Makefile
@@ -29,6 +29,7 @@ obj-$(CONFIG_NF_NAT_SNMP_BASIC) += nf_nat_snmp_basic.o
 obj-$(CONFIG_NF_NAT_TFTP) += nf_nat_tftp.o
 
 # NAT protocols (nf_nat)
+obj-$(CONFIG_NF_NAT_PROTO_DCCP) += nf_nat_proto_dccp.o
 obj-$(CONFIG_NF_NAT_PROTO_GRE) += nf_nat_proto_gre.o
 obj-$(CONFIG_NF_NAT_PROTO_UDPLITE) += nf_nat_proto_udplite.o
 
diff --git a/net/ipv4/netfilter/nf_nat_proto_dccp.c b/net/ipv4/netfilter/nf_nat_proto_dccp.c
new file mode 100644
index 0000000..caf4b19
--- /dev/null
+++ b/net/ipv4/netfilter/nf_nat_proto_dccp.c
@@ -0,0 +1,108 @@
+/*
+ * DCCP NAT protocol helper
+ *
+ * Copyright (c) 2005, 2006. 2008 Patrick McHardy <kaber@trash.net>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ *
+ */
+
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/init.h>
+#include <linux/skbuff.h>
+#include <linux/ip.h>
+#include <linux/dccp.h>
+
+#include <net/netfilter/nf_conntrack.h>
+#include <net/netfilter/nf_nat.h>
+#include <net/netfilter/nf_nat_protocol.h>
+
+static u_int16_t dccp_port_rover;
+
+static int
+dccp_unique_tuple(struct nf_conntrack_tuple *tuple,
+		  const struct nf_nat_range *range,
+		  enum nf_nat_manip_type maniptype,
+		  const struct nf_conn *ct)
+{
+	return nf_nat_proto_unique_tuple(tuple, range, maniptype, ct,
+					 &dccp_port_rover);
+}
+
+static int
+dccp_manip_pkt(struct sk_buff *skb,
+	       unsigned int iphdroff,
+	       const struct nf_conntrack_tuple *tuple,
+	       enum nf_nat_manip_type maniptype)
+{
+	struct iphdr *iph = (struct iphdr *)(skb->data + iphdroff);
+	struct dccp_hdr *hdr;
+	unsigned int hdroff = iphdroff + iph->ihl * 4;
+	__be32 oldip, newip;
+	__be16 *portptr, oldport, newport;
+	int hdrsize = 8; /* DCCP connection tracking guarantees this much */
+
+	if (skb->len >= hdroff + sizeof(struct dccp_hdr))
+		hdrsize = sizeof(struct dccp_hdr);
+
+	if (!skb_make_writable(skb, hdroff + hdrsize))
+		return 0;
+
+	iph = (struct iphdr *)(skb->data + iphdroff);
+	hdr = (struct dccp_hdr *)(skb->data + hdroff);
+
+	if (maniptype == IP_NAT_MANIP_SRC) {
+		oldip = iph->saddr;
+		newip = tuple->src.u3.ip;
+		newport = tuple->src.u.dccp.port;
+		portptr = &hdr->dccph_sport;
+	} else {
+		oldip = iph->daddr;
+		newip = tuple->dst.u3.ip;
+		newport = tuple->dst.u.dccp.port;
+		portptr = &hdr->dccph_dport;
+	}
+
+	oldport = *portptr;
+	*portptr = newport;
+
+	if (hdrsize < sizeof(*hdr))
+		return 1;
+
+	inet_proto_csum_replace4(&hdr->dccph_checksum, skb, oldip, newip, 1);
+	inet_proto_csum_replace2(&hdr->dccph_checksum, skb, oldport, newport,
+				 0);
+	return 1;
+}
+
+static const struct nf_nat_protocol nf_nat_protocol_dccp = {
+	.protonum		= IPPROTO_DCCP,
+	.me			= THIS_MODULE,
+	.manip_pkt		= dccp_manip_pkt,
+	.in_range		= nf_nat_proto_in_range,
+	.unique_tuple		= dccp_unique_tuple,
+#if defined(CONFIG_NF_CT_NETLINK) || defined(CONFIG_NF_CT_NETLINK_MODULE)
+	.range_to_nlattr	= nf_nat_port_range_to_nlattr,
+	.nlattr_to_range	= nf_nat_port_nlattr_to_range,
+#endif
+};
+
+static int __init nf_nat_proto_dccp_init(void)
+{
+	return nf_nat_protocol_register(&nf_nat_protocol_dccp);
+}
+
+static void __exit nf_nat_proto_dccp_fini(void)
+{
+	nf_nat_protocol_unregister(&nf_nat_protocol_dccp);
+}
+
+module_init(nf_nat_proto_dccp_init);
+module_exit(nf_nat_proto_dccp_fini);
+
+MODULE_AUTHOR("Patrick McHardy <kaber@trash.net>");
+MODULE_DESCRIPTION("DCCP NAT protocol helper");
+MODULE_LICENSE("GPL");
diff --git a/net/ipv4/netfilter/nf_nat_standalone.c b/net/ipv4/netfilter/nf_nat_standalone.c
index dc316b9..b759ffa 100644
--- a/net/ipv4/netfilter/nf_nat_standalone.c
+++ b/net/ipv4/netfilter/nf_nat_standalone.c
@@ -51,7 +51,8 @@ static void nat_decode_session(struct sk_buff *skb, struct flowi *fl)
 		fl->fl4_dst = t->dst.u3.ip;
 		if (t->dst.protonum == IPPROTO_TCP ||
 		    t->dst.protonum == IPPROTO_UDP ||
-		    t->dst.protonum == IPPROTO_UDPLITE)
+		    t->dst.protonum == IPPROTO_UDPLITE ||
+		    t->dst.protonum == IPPROTO_DCCP)
 			fl->fl_ip_dport = t->dst.u.tcp.port;
 	}
 
@@ -61,7 +62,8 @@ static void nat_decode_session(struct sk_buff *skb, struct flowi *fl)
 		fl->fl4_src = t->src.u3.ip;
 		if (t->dst.protonum == IPPROTO_TCP ||
 		    t->dst.protonum == IPPROTO_UDP ||
-		    t->dst.protonum == IPPROTO_UDPLITE)
+		    t->dst.protonum == IPPROTO_UDPLITE ||
+		    t->dst.protonum == IPPROTO_DCCP)
 			fl->fl_ip_sport = t->src.u.tcp.port;
 	}
 }

--------------030907030702040000010408--
