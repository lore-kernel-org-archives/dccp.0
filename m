From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 04 Oct 2007 14:01:48 +0000
Subject: [PATCH 1/5]: Exploit the `Ack Pending' flag
Message-Id: <200710041501.49058@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[DCCP]: Exploit the `Ack Pending' flag

This provides a wrapper around the function which sets the `Ack Pending' flag
on inet connection sockets. This is very useful for some DCCP cases, such as
the out-of-band feature negotiation of NN options for an established connection
(next patches).

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/dccp.h    |    7 ++++++-
 net/dccp/options.c |    1 +
 2 files changed, 7 insertions(+), 1 deletion(-)

--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -405,10 +405,15 @@ static inline void dccp_update_gss(struc
 	dp->dccps_awh = dp->dccps_gss;
 }
 
+static inline void dccp_schedule_ack(struct sock *sk)
+{
+	inet_csk_schedule_ack(sk);
+}
+
 static inline int dccp_ack_pending(const struct sock *sk)
 {
 	const struct dccp_sock *dp = dccp_sk(sk);
-	return dp->dccps_tstamp != NULL ||
+	return
 #ifdef CONFIG_IP_DCCP_ACKVEC
 	       (dp->dccps_hc_rx_ackvec != NULL &&
 		dccp_ackvec_pending(dp->dccps_hc_rx_ackvec)) ||
--- a/net/dccp/options.c
+++ b/net/dccp/options.c
@@ -166,6 +166,7 @@ int dccp_parse_options(struct sock *sk, 
 			opt_recv->dccpor_timestamp = ntohl(opt_val);
 			(*tse)->ts_echo = opt_recv->dccpor_timestamp;
 
+			dccp_schedule_ack(sk);
 			dccp_pr_debug("%s rx opt: TIMESTAMP=%u, ackno=%llu\n",
 				      dccp_role(sk), opt_recv->dccpor_timestamp,
 				      (unsigned long long)
