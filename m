From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 12 Oct 2007 09:52:00 +0000
Subject: [PATCH 5/5]: Reorder statements with regard to option length
Message-Id: <200710121052.00451@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[ACKVEC]: Reorder statements with regard to option length

This re-orders two statements which both rely on dccpd_opt_len: the problem
was that the test for `enough size for Ack Vector' comes before the insertion
of the Elapsed Time time option, which itself reduces dccpd_opt_len by 6 bytes.

Further added a FIXME for piggybacking of Ack Vectors and a warning message 
which is triggered when running out of option space - to monitor this condition.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ackvec.c |   13 ++++++++++---
 1 file changed, 10 insertions(+), 3 deletions(-)

--- a/net/dccp/ackvec.c
+++ b/net/dccp/ackvec.c
@@ -78,9 +78,6 @@ int dccp_insert_option_ackvec(struct soc
 	struct dccp_ackvec_record *avr;
 	suseconds_t delta;
 
-	if (DCCP_SKB_CB(skb)->dccpd_opt_len + len > DCCP_MAX_OPT_LEN)
-		return -1;
-
 	delta = ktime_us_delta(ktime_get_real(), av->dccpav_time);
 	elapsed_time = delta / 10;
 
@@ -88,6 +85,16 @@ int dccp_insert_option_ackvec(struct soc
 	    dccp_insert_option_elapsed_time(sk, skb, elapsed_time))
 		return -1;
 
+	if (DCCP_SKB_CB(skb)->dccpd_opt_len + len > DCCP_MAX_OPT_LEN) {
+		/*
+		 * FIXME: when running out of option space while piggybacking on
+		 * DataAck, return 0 here and schedule a separate Ack instead.
+		 */
+		DCCP_WARN("Lacking space for %u bytes on %s packet\n", len,
+			  dccp_packet_name(DCCP_SKB_CB(skb)->dccpd_type));
+		return -1;
+	}
+
 	avr = dccp_ackvec_record_new();
 	if (avr = NULL)
 		return -1;
