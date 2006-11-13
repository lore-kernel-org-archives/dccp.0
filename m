From: Arnaldo Carvalho de Melo <acme@mandriva.com>
Date: Mon, 13 Nov 2006 15:43:49 +0000
Subject: [PATCH 7/7][DCCPv6]: Choose a genuine initial sequence number
Message-Id: <20061113154349.GL6947@mandriva.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This
	* resolves a FIXME - DCCPv6 connections started all with
	  an initial sequence number of 1;
	* provides a redirection `secure_dccpv6_sequence_number'
	  in case the init_sequence_v6 code should be updated later;
	* concentrates the update of S.GAR into dccp_connect_init();
	* removes a duplicate dccp_update_gss() in ipv4.c;
	* uses inet->dport instead of usin->sin_port, due to the
	  following assignment in dccp_v4_connect():
 		inet->dport = usin->sin_port;

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>

------------------------------------------------------------------------------

 ipv4.c   |    9 ++-------
 ipv6.c   |   28 ++++++++++++++++------------
 output.c |    6 +++++-
 3 files changed, 23 insertions(+), 20 deletions(-)

------------------------------------------------------------------------------

diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index b56a2fa..bc400b2 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -113,13 +113,8 @@ int dccp_v4_connect(struct sock *sk, str
 	/* OK, now commit destination to socket.  */
 	sk_setup_caps(sk, &rt->u.dst);
 
-	dp->dccps_gar -		dp->dccps_iss = secure_dccp_sequence_number(inet->saddr,
-							    inet->daddr,
-							    inet->sport,
-							    usin->sin_port);
-	dccp_update_gss(sk, dp->dccps_iss);
-
+	dp->dccps_iss = secure_dccp_sequence_number(inet->saddr, inet->daddr,
+						    inet->sport, inet->dport);
 	inet->id = dp->dccps_iss ^ jiffies;
 
 	err = dccp_connect(sk);
diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index ec9ed9a..dbcf55c 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -76,12 +76,19 @@ static inline void dccp_v6_send_check(st
 	dh->dccph_checksum = dccp_v6_csum_finish(skb, &np->saddr, &np->daddr);
 }
 
-static inline __u32 dccp_v6_init_sequence(const struct sk_buff *skb)
+static inline __u32 secure_dccpv6_sequence_number(__u32 *saddr, __u32 *daddr,
+				   		  __u16 sport, __u16 dport   )
 {
-	return secure_tcpv6_sequence_number(skb->nh.ipv6h->daddr.s6_addr32,
-					    skb->nh.ipv6h->saddr.s6_addr32,
-					    dccp_hdr(skb)->dccph_dport,
-					    dccp_hdr(skb)->dccph_sport     );
+	return secure_tcpv6_sequence_number(saddr, daddr, sport, dport);
+}
+
+static inline __u32 dccp_v6_init_sequence(struct sk_buff *skb)
+{
+	return secure_dccpv6_sequence_number(skb->nh.ipv6h->daddr.s6_addr32,
+					     skb->nh.ipv6h->saddr.s6_addr32,
+					     dccp_hdr(skb)->dccph_dport,
+					     dccp_hdr(skb)->dccph_sport     );
+
 }
 
 static void dccp_v6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
@@ -1065,13 +1072,10 @@ static int dccp_v6_connect(struct sock *
 	err = inet6_hash_connect(&dccp_death_row, sk);
 	if (err)
 		goto late_failure;
-	/* FIXME */
-#if 0
-	dp->dccps_gar = secure_dccp_v6_sequence_number(np->saddr.s6_addr32,
-						       np->daddr.s6_addr32,
-						       inet->sport,
-						       inet->dport);
-#endif
+
+	dp->dccps_iss = secure_dccpv6_sequence_number(np->saddr.s6_addr32,
+						      np->daddr.s6_addr32,
+						      inet->sport, inet->dport);
 	err = dccp_connect(sk);
 	if (err)
 		goto late_failure;
diff --git a/net/dccp/output.c b/net/dccp/output.c
index 08ee554..0994b13 100644
--- a/net/dccp/output.c
+++ b/net/dccp/output.c
@@ -448,7 +448,6 @@ static inline void dccp_connect_init(str
 	
 	dccp_sync_mss(sk, dst_mtu(dst));
 
-	dccp_update_gss(sk, dp->dccps_iss);
  	/*
 	 * SWL and AWL are initially adjusted so that they are not less than
 	 * the initial Sequence Numbers received and sent, respectively:
@@ -457,8 +456,13 @@ static inline void dccp_connect_init(str
 	 * These adjustments MUST be applied only at the beginning of the
 	 * connection.
  	 */
+	dccp_update_gss(sk, dp->dccps_iss);
 	dccp_set_seqno(&dp->dccps_awl, max48(dp->dccps_awl, dp->dccps_iss));
 
+	/* S.GAR - greatest valid acknowledgement number received on a non-Sync;
+	 *         initialized to S.ISS (sec. 8.5)                            */
+	dp->dccps_gar = dp->dccps_iss;
+
 	icsk->icsk_retransmits = 0;
 	init_timer(&dp->dccps_xmit_timer);
 	dp->dccps_xmit_timer.data = (unsigned long)sk;
