From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 12 Oct 2010 05:15:47 +0000
Subject: [PATCH 2/6] dccp: merge now-reduced connect_init() function
Message-Id: <1286860551-6809-3-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

After moving the assignment of GAR/ISS from dccp_connect_init() to
dccp_transmit_skb(), the former function becomes very small, so that
a merger with dccp_connect() suggests itself.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/output.c |   18 +++++-------------
 1 files changed, 5 insertions(+), 13 deletions(-)

--- a/net/dccp/output.c
+++ b/net/dccp/output.c
@@ -474,8 +474,9 @@ int dccp_send_reset(struct sock *sk, enum dccp_reset_codes code)
 /*
  * Do all connect socket setups that can be done AF independent.
  */
-static inline void dccp_connect_init(struct sock *sk)
+int dccp_connect(struct sock *sk)
 {
+	struct sk_buff *skb;
 	struct dccp_sock *dp = dccp_sk(sk);
 	struct dst_entry *dst = __sk_dst_get(sk);
 	struct inet_connection_sock *icsk = inet_csk(sk);
@@ -485,22 +486,12 @@ static inline void dccp_connect_init(struct sock *sk)
 
 	dccp_sync_mss(sk, dst_mtu(dst));
 
-	/* Initialise GAR as per 8.5; AWL/AWH are set in dccp_transmit_skb() */
-	dp->dccps_gar = dp->dccps_iss;
-
-	icsk->icsk_retransmits = 0;
-}
-
-int dccp_connect(struct sock *sk)
-{
-	struct sk_buff *skb;
-	struct inet_connection_sock *icsk = inet_csk(sk);
-
 	/* do not connect if feature negotiation setup fails */
 	if (dccp_feat_finalise_settings(dccp_sk(sk)))
 		return -EPROTO;
 
-	dccp_connect_init(sk);
+	/* Initialise GAR as per 8.5; AWL/AWH are set in dccp_transmit_skb() */
+	dp->dccps_gar = dp->dccps_iss;
 
 	skb = alloc_skb(sk->sk_prot->max_header, sk->sk_allocation);
 	if (unlikely(skb = NULL))
@@ -516,6 +507,7 @@ int dccp_connect(struct sock *sk)
 	DCCP_INC_STATS(DCCP_MIB_ACTIVEOPENS);
 
 	/* Timer for repeating the REQUEST until an answer. */
+	icsk->icsk_retransmits = 0;
 	inet_csk_reset_xmit_timer(sk, ICSK_TIME_RETRANS,
 				  icsk->icsk_rto, DCCP_RTO_MAX);
 	return 0;
