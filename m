From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 12 Oct 2010 05:15:50 +0000
Subject: [PATCH 5/6] dccp: schedule an Ack when receiving timestamps
Message-Id: <1286860551-6809-6-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This schedules an Ack when receiving a timestamp, exploiting the
existing inet_csk_schedule_ack() function, saving one case in the
`dccp_ack_pending()' function.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/dccp.h    |    3 +--
 net/dccp/options.c |    2 ++
 2 files changed, 3 insertions(+), 2 deletions(-)

--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -459,8 +459,7 @@ static inline void dccp_update_gss(struct sock *sk, u64 seq)
 static inline int dccp_ack_pending(const struct sock *sk)
 {
 	const struct dccp_sock *dp = dccp_sk(sk);
-	return dp->dccps_timestamp_echo != 0 ||
-	       (dp->dccps_hc_rx_ackvec != NULL &&
+	return (dp->dccps_hc_rx_ackvec != NULL &&
 		dccp_ackvec_pending(dp->dccps_hc_rx_ackvec)) ||
 	       inet_csk_ack_scheduled(sk);
 }
--- a/net/dccp/options.c
+++ b/net/dccp/options.c
@@ -163,6 +163,8 @@ int dccp_parse_options(struct sock *sk, struct dccp_request_sock *dreq,
 				      dccp_role(sk), ntohl(opt_val),
 				      (unsigned long long)
 				      DCCP_SKB_CB(skb)->dccpd_ack_seq);
+			/* schedule an Ack in case this sender is quiescent */
+			inet_csk_schedule_ack(sk);
 			break;
 		case DCCPO_TIMESTAMP_ECHO:
 			if (len != 4 && len != 6 && len != 8)
