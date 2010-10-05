From: Stephen Hemminger <shemminger@vyatta.com>
Date: Tue, 05 Oct 2010 14:24:09 +0000
Subject: [PATCH net-next] dccp:
Message-Id: <20101005232409.61cb9412@s6510>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Remove dead code and make some functions static.
Compile tested only.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
 net/dccp/dccp.h    |    2 --
 net/dccp/feat.c    |   10 ----------
 net/dccp/feat.h    |    1 -
 net/dccp/options.c |    4 +---
 net/dccp/proto.c   |   48 ++++++++++++++++++++++++------------------------
 5 files changed, 25 insertions(+), 40 deletions(-)

--- a/net/dccp/dccp.h	2010-10-05 23:09:10.000117419 +0900
+++ b/net/dccp/dccp.h	2010-10-05 23:22:37.879120065 +0900
@@ -246,7 +246,6 @@ static inline void dccp_clear_xmit_timer
 extern unsigned int dccp_sync_mss(struct sock *sk, u32 pmtu);
 
 extern const char *dccp_packet_name(const int type);
-extern const char *dccp_state_name(const int state);
 
 extern void dccp_set_state(struct sock *sk, const int state);
 extern void dccp_done(struct sock *sk);
@@ -449,7 +448,6 @@ extern int dccp_insert_options_rsk(struc
 extern int dccp_insert_option_elapsed_time(struct sk_buff *skb, u32 elapsed);
 extern u32 dccp_timestamp(void);
 extern void dccp_timestamping_init(void);
-extern int dccp_insert_option_timestamp(struct sk_buff *skb);
 extern int dccp_insert_option(struct sk_buff *skb, unsigned char option,
 			      const void *value, unsigned char len);
 
--- a/net/dccp/feat.c	2010-10-05 23:09:09.828117827 +0900
+++ b/net/dccp/feat.c	2010-10-05 23:14:58.315118201 +0900
@@ -730,16 +730,6 @@ int dccp_feat_register_sp(struct sock *s
 				  0, list, len);
 }
 
-/* Analogous to dccp_feat_register_sp(), but for non-negotiable values */
-int dccp_feat_register_nn(struct sock *sk, u8 feat, u64 val)
-{
-	/* any changes must be registered before establishing the connection */
-	if (sk->sk_state != DCCP_CLOSED)
-		return -EISCONN;
-	if (dccp_feat_type(feat) != FEAT_NN)
-		return -EINVAL;
-	return __feat_register_nn(&dccp_sk(sk)->dccps_featneg, feat, 0, val);
-}
 
 /*
  *	Tracking features whose value depend on the choice of CCID
--- a/net/dccp/options.c	2010-10-05 23:09:09.884117478 +0900
+++ b/net/dccp/options.c	2010-10-05 23:14:27.375117940 +0900
@@ -369,7 +369,7 @@ int dccp_insert_option_elapsed_time(stru
 
 EXPORT_SYMBOL_GPL(dccp_insert_option_elapsed_time);
 
-int dccp_insert_option_timestamp(struct sk_buff *skb)
+static int dccp_insert_option_timestamp(struct sk_buff *skb)
 {
 	__be32 now = htonl(dccp_timestamp());
 	/* yes this will overflow but that is the point as we want a
@@ -378,8 +378,6 @@ int dccp_insert_option_timestamp(struct 
 	return dccp_insert_option(skb, DCCPO_TIMESTAMP, &now, sizeof(now));
 }
 
-EXPORT_SYMBOL_GPL(dccp_insert_option_timestamp);
-
 static int dccp_insert_option_timestamp_echo(struct dccp_sock *dp,
 					     struct dccp_request_sock *dreq,
 					     struct sk_buff *skb)
--- a/net/dccp/proto.c	2010-10-05 23:09:09.956117344 +0900
+++ b/net/dccp/proto.c	2010-10-05 23:22:09.171119892 +0900
@@ -50,6 +50,30 @@ EXPORT_SYMBOL_GPL(dccp_hashinfo);
 /* the maximum queue length for tx in packets. 0 is no limit */
 int sysctl_dccp_tx_qlen __read_mostly = 5;
 
+#ifdef CONFIG_IP_DCCP_DEBUG
+static const char *dccp_state_name(const int state)
+{
+	static const char *const dccp_state_names[] = {
+	[DCCP_OPEN]		= "OPEN",
+	[DCCP_REQUESTING]	= "REQUESTING",
+	[DCCP_PARTOPEN]		= "PARTOPEN",
+	[DCCP_LISTEN]		= "LISTEN",
+	[DCCP_RESPOND]		= "RESPOND",
+	[DCCP_CLOSING]		= "CLOSING",
+	[DCCP_ACTIVE_CLOSEREQ]	= "CLOSEREQ",
+	[DCCP_PASSIVE_CLOSE]	= "PASSIVE_CLOSE",
+	[DCCP_PASSIVE_CLOSEREQ]	= "PASSIVE_CLOSEREQ",
+	[DCCP_TIME_WAIT]	= "TIME_WAIT",
+	[DCCP_CLOSED]		= "CLOSED",
+	};
+
+	if (state >= DCCP_MAX_STATES)
+		return "INVALID STATE!";
+	else
+		return dccp_state_names[state];
+}
+#endif
+
 void dccp_set_state(struct sock *sk, const int state)
 {
 	const int oldstate = sk->sk_state;
@@ -146,30 +170,6 @@ const char *dccp_packet_name(const int t
 
 EXPORT_SYMBOL_GPL(dccp_packet_name);
 
-const char *dccp_state_name(const int state)
-{
-	static const char *const dccp_state_names[] = {
-	[DCCP_OPEN]		= "OPEN",
-	[DCCP_REQUESTING]	= "REQUESTING",
-	[DCCP_PARTOPEN]		= "PARTOPEN",
-	[DCCP_LISTEN]		= "LISTEN",
-	[DCCP_RESPOND]		= "RESPOND",
-	[DCCP_CLOSING]		= "CLOSING",
-	[DCCP_ACTIVE_CLOSEREQ]	= "CLOSEREQ",
-	[DCCP_PASSIVE_CLOSE]	= "PASSIVE_CLOSE",
-	[DCCP_PASSIVE_CLOSEREQ]	= "PASSIVE_CLOSEREQ",
-	[DCCP_TIME_WAIT]	= "TIME_WAIT",
-	[DCCP_CLOSED]		= "CLOSED",
-	};
-
-	if (state >= DCCP_MAX_STATES)
-		return "INVALID STATE!";
-	else
-		return dccp_state_names[state];
-}
-
-EXPORT_SYMBOL_GPL(dccp_state_name);
-
 int dccp_init_sock(struct sock *sk, const __u8 ctl_sock_initialized)
 {
 	struct dccp_sock *dp = dccp_sk(sk);
--- a/net/dccp/feat.h	2010-10-05 23:12:45.999118130 +0900
+++ b/net/dccp/feat.h	2010-10-05 23:13:10.347118219 +0900
@@ -111,7 +111,6 @@ extern int  dccp_feat_init(struct sock *
 extern void dccp_feat_initialise_sysctls(void);
 extern int  dccp_feat_register_sp(struct sock *sk, u8 feat, u8 is_local,
 				  u8 const *list, u8 len);
-extern int  dccp_feat_register_nn(struct sock *sk, u8 feat, u64 val);
 extern int  dccp_feat_parse_options(struct sock *, struct dccp_request_sock *,
 				    u8 mand, u8 opt, u8 feat, u8 *val, u8 len);
 extern int  dccp_feat_clone_list(struct list_head const *, struct list_head *);
