From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 25 Sep 2007 09:58:41 +0000
Subject: [PATCH v2  4/5]: Rate-limit DCCP-Syncs
Message-Id: <200709251058.41805@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Arnaldo -

|  Algorithm is fine, just use time_after when comparing jiffies based
|  timestamps, here:
Many thanks for pointing this out - it was a stupid oversight. The interdiff
to the previous patch is:

 		 *   These Syncs are rate-limited as per RFC 4340, 7.5.4:
 		 *   at most 1 / (dccp_sync_rate_limit * HZ) Syncs per second.
 		 */
-		if (now - dp->dccps_rate_last >= sysctl_dccp_sync_ratelimit) {
+		if (time_after(now, dp->dccps_rate_last 
+				  + sysctl_dccp_sync_ratelimit)) {
 			dp->dccps_rate_last = now;
 			/* ... */

I have only compile-tested this, but verified twice on paper, and it looks correct
(the `>=' has been replaced with `>', using `time_after_eq' does not seem necessary).
Please find update below.

--------------------------------< Patch v2 >-------------------------------------------
[DCCP]: Rate-limit DCCP-Syncs

This implements a SHOULD from RFC 4340, 7.5.4: 
 "To protect against denial-of-service attacks, DCCP implementations SHOULD 
  impose a rate limit on DCCP-Syncs sent in response to sequence-invalid packets, 
  such as not more than eight DCCP-Syncs per second."

The rate-limit is maintained on a per-socket basis. This is a more stringent
policy than enforcing the rate-limit on a per-source-address basis and
protects against attacks with forged source addresses.

Moreover, the mechanism is deliberately kept simple. In contrast to
xrlim_allow(), bursts of Sync packets in reply to sequence-invalid packets
are not supported.  This foils such attacks where the receipt of a Sync
triggers further sequence-invalid packets. (I have tested this mechanism against
xrlim_allow algorithm for Syncs, permitting bursts just increases the problems.)

In order to keep flexibility, the timeout parameter can be set via sysctl; and
the whole mechanism can even be disabled (which is however not recommended).

The algorithm in this patch has been improved with regard to wrapping issues
thanks to a suggestion by Arnaldo.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
---
 Documentation/networking/dccp.txt |    5 +++++
 include/linux/dccp.h              |    2 ++
 net/dccp/dccp.h                   |    1 +
 net/dccp/input.c                  |   16 +++++++++++++---
 net/dccp/proto.c                  |    1 +
 net/dccp/sysctl.c                 |   10 ++++++++++
 6 files changed, 32 insertions(+), 3 deletions(-)

--- a/Documentation/networking/dccp.txt
+++ b/Documentation/networking/dccp.txt
@@ -112,6 +112,11 @@ tx_qlen = 5
 	The size of the transmit buffer in packets. A value of 0 corresponds
 	to an unbounded transmit buffer.
 
+sync_ratelimit = 125 ms
+	The timeout between subsequent DCCP-Sync packets sent in response to
+	sequence-invalid packets on the same socket (RFC 4340, 7.5.4). The unit
+	of this parameter is milliseconds; a value of 0 disables rate-limiting.
+
 Notes
 == 
--- a/net/dccp/sysctl.c
+++ b/net/dccp/sysctl.c
@@ -18,6 +18,9 @@
 #error This file should not be compiled without CONFIG_SYSCTL defined
 #endif
 
+/* rate-limit for syncs in reply to sequence-invalid packets; RFC 4340, 7.5.4 */
+int sysctl_dccp_sync_ratelimit	__read_mostly = HZ / 8;
+
 static struct ctl_table dccp_default_table[] = {
 	{
 		.procname	= "seq_window",
@@ -89,6 +92,13 @@ static struct ctl_table dccp_default_tab
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec,
 	},
+	{
+		.procname	= "sync_ratelimit",
+		.data		= &sysctl_dccp_sync_ratelimit,
+		.maxlen		= sizeof(sysctl_dccp_sync_ratelimit),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec_ms_jiffies,
+	},
 
 	{ .ctl_name = 0, }
 };
--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -92,6 +92,7 @@ extern int  sysctl_dccp_feat_ack_ratio;
 extern int  sysctl_dccp_feat_send_ack_vector;
 extern int  sysctl_dccp_feat_send_ndp_count;
 extern int  sysctl_dccp_tx_qlen;
+extern int  sysctl_dccp_sync_ratelimit;
 
 /*
  *	48-bit sequence number arithmetic (signed and unsigned)
--- a/include/linux/dccp.h
+++ b/include/linux/dccp.h
@@ -472,6 +472,7 @@ struct dccp_ackvec;
  * @dccps_pcrlen - receiver partial checksum coverage (via sockopt)
  * @dccps_ndp_count - number of Non Data Packets since last data packet
  * @dccps_mss_cache - current value of MSS (path MTU minus header sizes)
+ * @dccps_rate_last - timestamp for rate-limiting DCCP-Sync (RFC 4340, 7.5.4)
  * @dccps_minisock - associated minisock (accessed via dccp_msk)
  * @dccps_hc_rx_ackvec - rx half connection ack vector
  * @dccps_hc_rx_ccid - CCID used for the receiver (or receiving half-connection)
@@ -507,6 +508,7 @@ struct dccp_sock {
 	__u16				dccps_pcrlen;
 	unsigned long			dccps_ndp_count;
 	__u32				dccps_mss_cache;
+	unsigned long			dccps_rate_last;
 	struct dccp_minisock		dccps_minisock;
 	struct dccp_ackvec		*dccps_hc_rx_ackvec;
 	struct ccid			*dccps_hc_rx_ccid;
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -219,6 +219,7 @@ int dccp_init_sock(struct sock *sk, cons
 	sk->sk_write_space	= dccp_write_space;
 	icsk->icsk_sync_mss	= dccp_sync_mss;
 	dp->dccps_mss_cache	= 536;
+	dp->dccps_rate_last	= jiffies;
 	dp->dccps_role		= DCCP_ROLE_UNDEFINED;
 	dp->dccps_service	= DCCP_SERVICE_CODE_IS_ABSENT;
 	dp->dccps_l_ack_ratio	= dp->dccps_r_ack_ratio = 1;
--- a/net/dccp/input.c
+++ b/net/dccp/input.c
@@ -122,6 +122,8 @@ static int dccp_check_seqno(struct sock 
 		    (ackno != DCCP_PKT_WITHOUT_ACK_SEQ))
 			dp->dccps_gar = ackno;
 	} else {
+		unsigned long now = jiffies;
+
 		DCCP_WARN("DCCP: Step 6 failed for %s packet, "
 			  "(LSWL(%llu) <= P.seqno(%llu) <= S.SWH(%llu)) and "
 			  "(P.ackno %s or LAWL(%llu) <= P.ackno(%llu) <= S.AWH(%llu), "
@@ -140,10 +142,18 @@ static int dccp_check_seqno(struct sock 
 		 *         Otherwise,
 		 *            Send Sync packet acknowledging P.seqno
 		 *      Drop packet and return
+		 *
+		 *   These Syncs are rate-limited as per RFC 4340, 7.5.4:
+		 *   at most 1 / (dccp_sync_rate_limit * HZ) Syncs per second.
 		 */
-		if (dh->dccph_type = DCCP_PKT_RESET)
-			seqno = dp->dccps_gsr;
-		dccp_send_sync(sk, seqno, DCCP_PKT_SYNC);
+		if (time_after(now, dp->dccps_rate_last
+				  + sysctl_dccp_sync_ratelimit)) {
+			dp->dccps_rate_last = now;
+
+			if (dh->dccph_type = DCCP_PKT_RESET)
+				seqno = dp->dccps_gsr;
+			dccp_send_sync(sk, seqno, DCCP_PKT_SYNC);
+		}
 		return -1;
 	}
 


			
