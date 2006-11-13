From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 13 Nov 2006 13:27:45 +0000
Subject: [PATCH 3/7]: Add sysctls to control retransmission behaviour
Message-Id: <200611131327.46115@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[DCCP]: Add sysctls to control retransmission behaviour

This adds 3 sysctls which govern the retransmission behaviour of DCCP control
packets (3way handshake, feature negotiation). 

It removes 4 FIXMEs from the code. 

The close resemblance of sysctl variables to their TCP analogues is emphasised 
not only by their name, but also by giving them the same initial values. 
This is useful since there is not much practical experience with DCCP yet.

Furthermore, with regard to the previous patch, it is now possible to limit
the number of keepalive-Resonses by setting net.dccp.default.request_retries
(also a bit like in TCP).

Lastly, added documentation of all existing DCCP sysctls.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 Documentation/networking/dccp.txt |   41 ++++++++++++++++++++++++++++++++++++++
 include/linux/sysctl.h            |    3 ++
 net/dccp/dccp.h                   |   11 ++++++++++
 net/dccp/feat.h                   |    7 ------
 net/dccp/proto.c                  |    1 
 net/dccp/sysctl.c                 |   24 ++++++++++++++++++++++
 net/dccp/timer.c                  |   16 +++++++++-----
 7 files changed, 90 insertions(+), 13 deletions(-)

--- a/include/linux/sysctl.h
+++ b/include/linux/sysctl.h
@@ -614,6 +614,9 @@ enum {
 	NET_DCCP_DEFAULT_ACK_RATIO   = 4,
 	NET_DCCP_DEFAULT_SEND_ACKVEC = 5,
 	NET_DCCP_DEFAULT_SEND_NDP    = 6,
+	NET_DCCP_DEFAULT_REQ_RETRIES = 7,
+	NET_DCCP_DEFAULT_RETRIES1    = 8,
+	NET_DCCP_DEFAULT_RETRIES2    = 9,
 };
 
 /* /proc/sys/net/ipx */
--- a/net/dccp/sysctl.c
+++ b/net/dccp/sysctl.c
@@ -66,6 +66,30 @@ static struct ctl_table dccp_default_tab
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec,
 	},
+	{
+		.ctl_name	= NET_DCCP_DEFAULT_REQ_RETRIES,
+		.procname	= "request_retries",
+		.data		= &sysctl_dccp_request_retries,
+		.maxlen		= sizeof(sysctl_dccp_request_retries),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec,
+	},
+	{
+		.ctl_name	= NET_DCCP_DEFAULT_RETRIES1,
+		.procname	= "retries1",
+		.data		= &sysctl_dccp_retries1,
+		.maxlen		= sizeof(sysctl_dccp_retries1),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec,
+	},
+	{
+		.ctl_name	= NET_DCCP_DEFAULT_RETRIES2,
+		.procname	= "retries2",
+		.data		= &sysctl_dccp_retries2,
+		.maxlen		= sizeof(sysctl_dccp_retries2),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec,
+	},
 	{ .ctl_name = 0, }
 };
 
--- a/net/dccp/timer.c
+++ b/net/dccp/timer.c
@@ -15,6 +15,11 @@
 
 #include "dccp.h"
 
+/* sysctl variables governing numbers of retransmission attempts */
+int  sysctl_dccp_request_retries	__read_mostly = TCP_SYN_RETRIES;
+int  sysctl_dccp_retries1		__read_mostly = TCP_RETR1;
+int  sysctl_dccp_retries2		__read_mostly = TCP_RETR2;
+
 static void dccp_write_timer(unsigned long data);
 static void dccp_keepalive_timer(unsigned long data);
 static void dccp_delack_timer(unsigned long data);
@@ -44,11 +49,10 @@ static int dccp_write_timeout(struct soc
 	if (sk->sk_state = DCCP_REQUESTING || sk->sk_state = DCCP_PARTOPEN) {
 		if (icsk->icsk_retransmits != 0)
 			dst_negative_advice(&sk->sk_dst_cache);
-		retry_until = icsk->icsk_syn_retries ? :
-			    /* FIXME! */ 3 /* FIXME! sysctl_tcp_syn_retries */;
+		retry_until = icsk->icsk_syn_retries ?
+			    : sysctl_dccp_request_retries;
 	} else {
-		if (icsk->icsk_retransmits >-		     /* FIXME! sysctl_tcp_retries1 */ 5 /* FIXME! */) {
+		if (icsk->icsk_retransmits >= sysctl_dccp_retries1) {
 			/* NOTE. draft-ietf-tcpimpl-pmtud-01.txt requires pmtu
 			   black hole detection. :-(
 
@@ -72,7 +76,7 @@ static int dccp_write_timeout(struct soc
 			dst_negative_advice(&sk->sk_dst_cache);
 		}
 
-		retry_until = /* FIXME! */ 15 /* FIXME! sysctl_tcp_retries2 */;
+		retry_until = sysctl_dccp_retries2;
 		/*
 		 * FIXME: see tcp_write_timout and tcp_out_of_resources
 		 */
@@ -196,7 +200,7 @@ backoff:
 	icsk->icsk_rto = min(icsk->icsk_rto << 1, DCCP_RTO_MAX);
 	inet_csk_reset_xmit_timer(sk, ICSK_TIME_RETRANS, icsk->icsk_rto,
 				  DCCP_RTO_MAX);
-	if (icsk->icsk_retransmits > 3 /* FIXME: sysctl_dccp_retries1 */)
+	if (icsk->icsk_retransmits > sysctl_dccp_retries1)
 		__sk_dst_reset(sk);
 out:;
 }
--- a/Documentation/networking/dccp.txt
+++ b/Documentation/networking/dccp.txt
@@ -63,6 +63,47 @@ DCCP_SOCKOPT_SEND_CSCOV is for the recei
 	coverage value are also acceptable. The higher the number, the more
 	restrictive this setting (see [RFC 4340, sec. 9.2.1]).
 
+Sysctl variables
+========
+Several DCCP default parameters can be managed by the following sysctls
+(sysctl net.dccp.default or /proc/sys/net/dccp/default):
+
+request_retries
+	The number of active connection initiation retries (the number of
+	Requests minus one) before timing out. In addition, it also governs
+	the behaviour of the other, passive side: this variable also sets
+	the number of times DCCP repeats sending a Response when the initial
+	handshake does not progress from RESPOND to OPEN (i.e. when no Ack
+	is received after the initial Request).  This value should be greater
+	than 0, suggested is less than 10. Analogue of tcp_syn_retries.
+
+retries1
+	How often a DCCP Response is retransmitted until the listening DCCP
+	side considers its connecting peer dead. Analogue of tcp_retries1.
+
+retries2
+	The number of times a general DCCP packet is retransmitted. This has
+	importance for retransmitted acknowledgments and feature negotiation,
+	data packets are never retransmitted. Analogue of tcp_retries2.
+
+send_ndp = 1
+	Whether or not to send NDP count options (sec. 7.7.2).
+
+send_ackvec = 1
+	Whether or not to send Ack Vector options (sec. 11.5).
+
+ack_ratio = 2
+	The default Ack Ratio (sec. 11.3) to use.
+
+tx_ccid = 2
+	Default CCID for the sender-receiver half-connection.
+
+rx_ccid = 2
+	Default CCID for the receiver-sender half-connection.
+
+seq_window = 100
+	The initial sequence window (sec. 7.5.2).
+
 Notes
 == 
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -212,6 +212,7 @@ int dccp_init_sock(struct sock *sk, cons
 
 	dccp_init_xmit_timers(sk);
 	icsk->icsk_rto		= DCCP_TIMEOUT_INIT;
+	icsk->icsk_syn_retries	= sysctl_dccp_request_retries;
 	sk->sk_state		= DCCP_CLOSED;
 	sk->sk_write_space	= dccp_write_space;
 	icsk->icsk_sync_mss	= dccp_sync_mss;
--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -69,6 +69,17 @@ extern void dccp_time_wait(struct sock *
 
 #define DCCP_XMIT_TIMEO 30000 /* Time/msecs for blocking transmit per packet */
 
+/* sysctl variables for DCCP */
+extern int  sysctl_dccp_request_retries;
+extern int  sysctl_dccp_retries1;
+extern int  sysctl_dccp_retries2;
+extern int  dccp_feat_default_sequence_window;
+extern int  dccp_feat_default_rx_ccid;
+extern int  dccp_feat_default_tx_ccid;
+extern int  dccp_feat_default_ack_ratio;
+extern int  dccp_feat_default_send_ack_vector;
+extern int  dccp_feat_default_send_ndp_count;
+
 /* is seq1 < seq2 ? */
 static inline int before48(const u64 seq1, const u64 seq2)
 {
--- a/net/dccp/feat.h
+++ b/net/dccp/feat.h
@@ -91,11 +91,4 @@ extern void dccp_feat_clean(struct dccp_
 extern int  dccp_feat_clone(struct sock *oldsk, struct sock *newsk);
 extern int  dccp_feat_init(struct dccp_minisock *dmsk);
 
-extern int  dccp_feat_default_sequence_window;
-extern int  dccp_feat_default_rx_ccid;
-extern int  dccp_feat_default_tx_ccid;
-extern int  dccp_feat_default_ack_ratio;
-extern int  dccp_feat_default_send_ack_vector;
-extern int  dccp_feat_default_send_ndp_count;
-
 #endif /* _DCCP_FEAT_H */
