From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 24 Oct 2006 13:59:11 +0000
Subject: [PATCH 2/17] [Trivial] net/dccp: update references to standards
Message-Id: <200610241459.11594@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This is a re-send from 
http://www.mail-archive.com/dccp@vger.kernel.org/msg00481.html

[DCCP]: Update documentation references.

Updates the references to spec documents throughout the code,
taking into account that

* the DCCP, CCID 2, and CCID 3 drafts all became RFCs in March this year 

* RFC 1063 was obsoleted by RFC 1191

* draft-ietf-tcpimpl-pmtud-0x.txt was published as an Informational
   RFC, RFC 2923 on 2000-09-22.

All references verified; patches against stable and Torvald's tree


Signed-off-by: Gerrit Renker  <gerrit@erg.abdn.ac.uk>
------------------------------------------------------------------------------

 net/dccp/Kconfig       |    4 ++--
 net/dccp/ackvec.c      |   12 ++++++------
 net/dccp/ackvec.h      |    3 +--
 net/dccp/ccids/Kconfig |   19 +++++++++----------
 net/dccp/ccids/ccid2.c |    2 +-
 net/dccp/ccids/ccid3.c |    3 +--
 net/dccp/dccp.h        |    2 +-
 net/dccp/input.c       |    4 ++--
 net/dccp/ipv4.c        |    4 ++--
 net/dccp/ipv6.c        |    2 +-
 net/dccp/options.c     |    2 +-
 net/dccp/proto.c       |    2 +-
 net/dccp/timer.c       |    5 ++---
 net/ipv4/tcp_output.c  |    2 +-
 14 files changed, 31 insertions(+), 35 deletions(-)

------------------------------------------------------------------------------

diff --git a/net/dccp/Kconfig b/net/dccp/Kconfig
index e2a095d..313795a 100644
--- a/net/dccp/Kconfig
+++ b/net/dccp/Kconfig
@@ -4,9 +4,9 @@ menu "DCCP Configuration (EXPERIMENTAL)"
 config IP_DCCP
 	tristate "The DCCP Protocol (EXPERIMENTAL)"
 	---help---
-	  Datagram Congestion Control Protocol
+	  Datagram Congestion Control Protocol (RFC 4340)
 
-	  From draft-ietf-dccp-spec-11 <http://www.icir.org/kohler/dcp/draft-ietf-dccp-spec-11.txt>.
+	  From http://www.ietf.org/rfc/rfc4340.txt
 
 	  The Datagram Congestion Control Protocol (DCCP) is a transport
 	  protocol that implements bidirectional, unicast connections of
diff --git a/net/dccp/dccp.h b/net/dccp/dccp.h
index 0d34358..9f00dd8 100644
--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -56,7 +56,7 @@ #define MAX_DCCP_HEADER (MAX_DCCP_SPECIF
 #define DCCP_TIMEWAIT_LEN (60 * HZ) /* how long to wait to destroy TIME-WAIT
 				     * state, about 60 seconds */
 
-/* draft-ietf-dccp-spec-11.txt initial RTO value */
+/* RFC 1122, 4.2.3.1 initial RTO value */
 #define DCCP_TIMEOUT_INIT ((unsigned)(3 * HZ))
 
 /* Maximal interval between probes for local resources.  */
diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index bf692c1..a31ddd9 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -183,7 +183,7 @@ static inline void dccp_do_pmtu_discover
 		dccp_sync_mss(sk, mtu);
 
 		/*
-		 * From: draft-ietf-dccp-spec-11.txt
+		 * From RFC 4340, sec. 14.1:
 		 *
 		 *	DCCP-Sync packets are the best choice for upward
 		 *	probing, since DCCP-Sync probes do not risk application
@@ -731,7 +731,7 @@ static void dccp_v4_ctl_send_reset(struc
 	dccp_hdr_reset(skb)->dccph_reset_code  				DCCP_SKB_CB(rxskb)->dccpd_reset_code;
 
-	/* See "8.3.1. Abnormal Termination" in draft-ietf-dccp-spec-11 */
+	/* See "8.3.1. Abnormal Termination" in RFC 4340 */
 	seqno = 0;
 	if (DCCP_SKB_CB(rxskb)->dccpd_ack_seq != DCCP_PKT_WITHOUT_ACK_SEQ)
 		dccp_set_seqno(&seqno, DCCP_SKB_CB(rxskb)->dccpd_ack_seq + 1);
diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index 7a47399..0ecd8a1 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -550,7 +550,7 @@ static void dccp_v6_ctl_send_reset(struc
 	dccp_hdr_reset(skb)->dccph_reset_code  				DCCP_SKB_CB(rxskb)->dccpd_reset_code;
 
-	/* See "8.3.1. Abnormal Termination" in draft-ietf-dccp-spec-11 */
+	/* See "8.3.1. Abnormal Termination" in RFC 4340 */
 	seqno = 0;
 	if (DCCP_SKB_CB(rxskb)->dccpd_ack_seq != DCCP_PKT_WITHOUT_ACK_SEQ)
 		dccp_set_seqno(&seqno, DCCP_SKB_CB(rxskb)->dccpd_ack_seq + 1);
diff --git a/net/dccp/input.c b/net/dccp/input.c
index 7f9dc6a..1d24881 100644
--- a/net/dccp/input.c
+++ b/net/dccp/input.c
@@ -216,11 +216,11 @@ send_sync:
 		dccp_send_sync(sk, DCCP_SKB_CB(skb)->dccpd_seq,
 			       DCCP_PKT_SYNCACK);
 		/*
-		 * From the draft:
+		 * From RFC 4340, sec. 5.7
 		 *
 		 * As with DCCP-Ack packets, DCCP-Sync and DCCP-SyncAck packets
 		 * MAY have non-zero-length application data areas, whose
-		 * contents * receivers MUST ignore.
+		 * contents receivers MUST ignore.
 		 */
 		goto discard;
 	}
diff --git a/net/dccp/options.c b/net/dccp/options.c
index 07a3469..fb0db1f 100644
--- a/net/dccp/options.c
+++ b/net/dccp/options.c
@@ -215,7 +215,7 @@ #endif
 				      elapsed_time);
 			break;
 			/*
-			 * From draft-ietf-dccp-spec-11.txt:
+			 * From RFC 4340, sec. 10.3:
 			 *
 			 *	Option numbers 128 through 191 are for
 			 *	options sent from the HC-Sender to the
diff --git a/net/dccp/proto.c b/net/dccp/proto.c
index 72cbdcf..d3e6e81 100644
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -892,7 +892,7 @@ adjudge_to_death:
 	 * The last release_sock may have processed the CLOSE or RESET
 	 * packet moving sock to CLOSED state, if not we have to fire
 	 * the CLOSE/CLOSEREQ retransmission timer, see "8.3. Termination"
-	 * in draft-ietf-dccp-spec-11. -acme
+	 * in RFC 4340 -acme
 	 */
 	if (sk->sk_state = DCCP_CLOSING) {
 		/* FIXME: should start at 2 * RTT */
diff --git a/net/dccp/timer.c b/net/dccp/timer.c
index 8447742..391c921 100644
--- a/net/dccp/timer.c
+++ b/net/dccp/timer.c
@@ -49,12 +49,11 @@ static int dccp_write_timeout(struct soc
 	} else {
 		if (icsk->icsk_retransmits > 		     /* FIXME! sysctl_tcp_retries1 */ 5 /* FIXME! */) {
-			/* NOTE. draft-ietf-tcpimpl-pmtud-01.txt requires pmtu
-			   black hole detection. :-(
+			/* NOTE. RFC 2923 requires pmtu black hole detection. :-(
 
 			   It is place to make it. It is not made. I do not want
 			   to make it. It is disguisting. It does not work in any
-			   case. Let me to cite the same draft, which requires for
+			   case. Let me cite the same RFC, which requires for
 			   us to implement this:
 
    "The one security concern raised by this memo is that ICMP black holes
diff --git a/net/dccp/ackvec.c b/net/dccp/ackvec.c
index 4d176d3..c0cb709 100644
--- a/net/dccp/ackvec.c
+++ b/net/dccp/ackvec.c
@@ -113,7 +113,7 @@ #endif
 
 	memcpy(to, from, len);
 	/*
-	 *	From draft-ietf-dccp-spec-11.txt:
+	 *	From RFC 4340, A.2:
 	 *
 	 *	For each acknowledgement it sends, the HC-Receiver will add an
 	 *	acknowledgement record.  ack_seqno will equal the HC-Receiver
@@ -224,7 +224,7 @@ static inline int dccp_ackvec_set_buf_he
 }
 
 /*
- * Implements the draft-ietf-dccp-spec-11.txt Appendix A
+ * Implements RFC 4340, Appendix A
  */
 int dccp_ackvec_add(struct dccp_ackvec *av, const struct sock *sk,
 		    const u64 ackno, const u8 state)
@@ -237,7 +237,7 @@ int dccp_ackvec_add(struct dccp_ackvec *
 	 * We may well decide to do buffer compression, etc, but for now lets
 	 * just drop.
 	 *
-	 * From Appendix A:
+	 * From Appendix A.1.1 (`New Packets'):
 	 *
 	 *	Of course, the circular buffer may overflow, either when the
 	 *	HC-Sender is sending data at a very high rate, when the
@@ -274,9 +274,9 @@ int dccp_ackvec_add(struct dccp_ackvec *
 		/*
 		 * A.1.2.  Old Packets
 		 *
-		 *	When a packet with Sequence Number S arrives, and
-		 *	S <= buf_ackno, the HC-Receiver will scan the table
-		 *	for the byte corresponding to S. (Indexing structures
+		 *	When a packet with Sequence Number S <= buf_ackno
+		 *	arrives, the HC-Receiver will scan the table for
+		 *	the byte corresponding to S. (Indexing structures
 		 *	could reduce the complexity of this scan.)
 		 */
 		u64 delta = dccp_delta_seqno(ackno, av->dccpav_buf_ackno);
diff --git a/net/dccp/ackvec.h b/net/dccp/ackvec.h
index 2424eff..cf8f20c 100644
--- a/net/dccp/ackvec.h
+++ b/net/dccp/ackvec.h
@@ -28,8 +28,7 @@ #define DCCP_ACKVEC_LEN_MASK		0x3F /* 00
 
 /** struct dccp_ackvec - ack vector
  *
- * This data structure is the one defined in the DCCP draft
- * Appendix A.
+ * This data structure is the one defined in RFC 4340, Appendix A.
  *
  * @dccpav_buf_head - circular buffer head
  * @dccpav_buf_tail - circular buffer tail
diff --git a/net/dccp/ccids/Kconfig b/net/dccp/ccids/Kconfig
index 32752f7..3d358ab 100644
--- a/net/dccp/ccids/Kconfig
+++ b/net/dccp/ccids/Kconfig
@@ -22,11 +22,11 @@ config IP_DCCP_CCID2
 	  for lost packets, would prefer CCID 2 to CCID 3.  On-line games may
 	  also prefer CCID 2.
 
-	  CCID 2 is further described in:
-	  http://www.icir.org/kohler/dccp/draft-ietf-dccp-ccid2-10.txt
+	  CCID 2 is further described in RFC 4341,
+	  http://www.ietf.org/rfc/rfc4341.txt
 
-	  This text was extracted from:
-	  http://www.icir.org/kohler/dccp/draft-ietf-dccp-spec-13.txt
+	  This text was extracted from RFC 4340 (sec. 10.1),
+	  http://www.ietf.org/rfc/rfc4340.txt
 
 	  If in doubt, say M.
 
@@ -53,15 +53,14 @@ config IP_DCCP_CCID3
 	  suitable than CCID 2 for applications such streaming media where a
 	  relatively smooth sending rate is of importance.
 
-	  CCID 3 is further described in:
-
-	  http://www.icir.org/kohler/dccp/draft-ietf-dccp-ccid3-11.txt.
+	  CCID 3 is further described in RFC 4342,
+	  http://www.ietf.org/rfc/rfc4342.txt
 
 	  The TFRC congestion control algorithms were initially described in
-	  RFC 3448.
+	  RFC 3448 (http://www.ietf.org/rfc/rfc3448.txt).
 
-	  This text was extracted from:
-	  http://www.icir.org/kohler/dccp/draft-ietf-dccp-spec-13.txt
+	  This text was extracted from RFC 4340 (sec. 10.2),
+	  http://www.ietf.org/rfc/rfc4340.txt
 	  
 	  If in doubt, say M.
 
diff --git a/net/dccp/ccids/ccid2.c b/net/dccp/ccids/ccid2.c
index 2efb505..2fbb84b 100644
--- a/net/dccp/ccids/ccid2.c
+++ b/net/dccp/ccids/ccid2.c
@@ -23,7 +23,7 @@
  */
 
 /*
- * This implementation should follow: draft-ietf-dccp-ccid2-10.txt
+ * This implementation should follow RFC 4341
  *
  * BUGS:
  * - sequence number wrapping
diff --git a/net/dccp/ccids/ccid3.c b/net/dccp/ccids/ccid3.c
index 67d2dc0..cec23ad 100644
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -379,8 +379,7 @@ static void ccid3_hc_tx_packet_sent(stru
 		packet->dccphtx_seqno  = dp->dccps_gss;
 		/*
 		 * Check if win_count have changed
-		 * Algorithm in "8.1. Window Counter Valuer" in
-		 * draft-ietf-dccp-ccid3-11.txt
+		 * Algorithm in "8.1. Window Counter Value" in RFC 4342.
 		 */
 		quarter_rtt = timeval_delta(&now, &hctx->ccid3hctx_t_last_win_count);
 		if (likely(hctx->ccid3hctx_rtt > 8))
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 9a253fa..0fa07fc 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -87,7 +87,7 @@ static inline __u32 tcp_acceptable_seq(s
 }
 
 /* Calculate mss to advertise in SYN segment.
- * RFC1122, RFC1063, draft-ietf-tcpimpl-pmtud-01 state that:
+ * RFC1122, RFC1191, RFC2923 state that:
  *
  * 1. It is independent of path mtu.
  * 2. Ideally, it is maximal possible segment size i.e. 65535-40.
