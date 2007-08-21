From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 21 Aug 2007 14:10:31 +0000
Subject: [RFC][PATCH 1/1]: Let dccp_epoch return
Message-Id: <200708211510.31147@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This is an idea-test, not a full patch. But I have found it to work.

The idea is to start the timer when DCCP is loaded. This gives
2^32-1 usecs = circa 49 days before the clock wraps around.

What I have tested is the RTT sampling for the initial SYN RTT and
that worked well with the hack below.

Here is a transcript (after the patch)
$ iperf -c 10.0.0.1 -d
------------------------------------------------------------
Client connecting to 10.0.0.1, DCCP port 5001
NOTE: running in bytestream-mode (maximum speed)
DCCP datagram buffer size:   104 KByte (default)
------------------------------------------------------------
[  3] local 10.0.0.176 port 53425 connected with 10.0.0.1 port 5001
Aug 21 15:04:04 gerrit kernel: delta = 171               <Aug 21 15:04:04 gerrit kernel: SYN RTT = 171us           <= 
[  3]  0.0-10.0 sec    112 MBytes  93.9 Mbits/se

Will try to clean this up for the other cases - but is the idea ok?
---
 net/dccp/dccp.h    |    1 +
 net/dccp/input.c   |    4 ++--
 net/dccp/options.c |    2 +-
 net/dccp/proto.c   |    7 +++++++
 4 files changed, 11 insertions(+), 3 deletions(-)

--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -413,6 +413,7 @@ extern int dccp_insert_options(struct so
 extern int dccp_insert_option_elapsed_time(struct sock *sk,
 					    struct sk_buff *skb,
 					    u32 elapsed_time);
+extern u32 dccp_timestamp(void);
 extern int dccp_insert_option_timestamp(struct sock *sk,
 					 struct sk_buff *skb);
 extern int dccp_insert_option(struct sock *sk, struct sk_buff *skb,
--- a/net/dccp/options.c
+++ b/net/dccp/options.c
@@ -365,7 +365,7 @@ EXPORT_SYMBOL_GPL(dccp_insert_option_ela
 
 int dccp_insert_option_timestamp(struct sock *sk, struct sk_buff *skb)
 {
-	__be32 now = htonl(((suseconds_t)ktime_to_us(ktime_get_real())) / 10);
+	__be32 now = htonl(dccp_timestamp() / 10);
 	/* yes this will overflow but that is the point as we want a
 	 * 10 usec 32 bit timer which mean it wraps every 11.9 hours */
 
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -52,6 +52,12 @@ struct inet_hashinfo __cacheline_aligned
 
 EXPORT_SYMBOL_GPL(dccp_hashinfo);
 
+static ktime_t dccp_timestamp_seed;
+u32 dccp_timestamp(void)
+{
+	return ktime_us_delta(ktime_get_real(), dccp_timestamp_seed);
+}
+
 /* Forward Declarations. */
 static void dccp_handle_passive_close(struct sock *sk);
 
@@ -1134,6 +1140,7 @@ static int __init dccp_init(void)
 	rc = dccp_sysctl_init();
 	if (rc)
 		goto out_ackvec_exit;
+	dccp_timestamp_seed = ktime_get_real();
 out:
 	return rc;
 out_ackvec_exit:
--- a/net/dccp/input.c
+++ b/net/dccp/input.c
@@ -648,8 +648,8 @@ u32 dccp_sample_rtt(struct sock *sk, kti
 			DCCP_WARN("packet without timestamp echo\n");
 			return DCCP_SANE_RTT_MAX;
 		}
-		ktime_sub_us(t_recv, or->dccpor_timestamp_echo * 10);
-		delta = ktime_to_us(t_recv);
+		delta = dccp_timestamp() - or->dccpor_timestamp_echo * 10;
+		printk("delta = %lld\n", (long long)delta);
 	} else
 		delta = ktime_us_delta(t_recv, *t_hist);
 
