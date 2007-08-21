From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 21 Aug 2007 19:00:16 +0000
Subject: [PATCH 2/3]: Provide 10s of microsecond timesource
Message-Id: <200708212000.16659@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[DCCP]: Provide 10s of microsecond timesource

This provides a timesource, conveniently used for DCCP timestamps, which 
returns the elapsed time in 10s of microseconds since initialisation. 
This makes for a wrap-around time of about 11.9 hours, which should be
sufficient for most applications.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/dccp.h    |    2 ++
 net/dccp/options.c |    2 +-
 net/dccp/proto.c   |    2 ++
 net/dccp/timer.c   |   21 +++++++++++++++++++++
 4 files changed, 26 insertions(+), 1 deletion(-)

--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -396,6 +396,8 @@ extern int dccp_insert_options(struct so
 extern int dccp_insert_option_elapsed_time(struct sock *sk,
 					    struct sk_buff *skb,
 					    u32 elapsed_time);
+extern u32 dccp_timestamp(void);
+extern void dccp_timestamping_init(void);
 extern int dccp_insert_option_timestamp(struct sock *sk,
 					 struct sk_buff *skb);
 extern int dccp_insert_option(struct sock *sk, struct sk_buff *skb,
--- a/net/dccp/options.c
+++ b/net/dccp/options.c
@@ -372,7 +372,7 @@ EXPORT_SYMBOL_GPL(dccp_insert_option_ela
 
 int dccp_insert_option_timestamp(struct sock *sk, struct sk_buff *skb)
 {
-	__be32 now = htonl(((suseconds_t)ktime_to_us(ktime_get_real())) / 10);
+	__be32 now = htonl(dccp_timestamp());
 	/* yes this will overflow but that is the point as we want a
 	 * 10 usec 32 bit timer which mean it wraps every 11.9 hours */
 
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -1076,6 +1076,8 @@ static int __init dccp_init(void)
 	rc = dccp_sysctl_init();
 	if (rc)
 		goto out_ackvec_exit;
+
+	dccp_timestamping_init();
 out:
 	return rc;
 out_ackvec_exit:
--- a/net/dccp/timer.c
+++ b/net/dccp/timer.c
@@ -291,3 +291,24 @@ void dccp_init_xmit_timers(struct sock *
 	inet_csk_init_xmit_timers(sk, &dccp_write_timer, &dccp_delack_timer,
 				  &dccp_keepalive_timer);
 }
+
+static ktime_t dccp_timestamp_seed;
+/**
+ * dccp_timestamp  -  10s of microseconds time source
+ * Returns the number of hundredths of milliseconds since initialisation. This
+ * is the native DCCP time difference format (RFC 4340, sec. 13); the counter
+ * wraps around circa every 11.9 hours, so careful with marathon TV watching :)
+ */
+u32 dccp_timestamp(void)
+{
+	s64 delta = ktime_us_delta(ktime_get_real(), dccp_timestamp_seed);
+
+	do_div(delta, 10);
+	return delta;
+}
+EXPORT_SYMBOL_GPL(dccp_timestamp);
+
+void __init dccp_timestamping_init(void)
+{
+	dccp_timestamp_seed = ktime_get_real();
+}
