From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 21 Mar 2007 18:44:28 +0000
Subject: [PATCH 5/25]: Complete documentation of dccp_sock
Message-Id: <200703211844.28347@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[DCCP]: Complete documentation of dccp_sock

This fills in missing documentation for dccp_sock fields.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>      
---
 include/linux/dccp.h |   20 ++++++++++----------
 1 file changed, 10 insertions(+), 10 deletions(-)

--- a/include/linux/dccp.h
+++ b/include/linux/dccp.h
@@ -465,20 +465,20 @@ struct dccp_ackvec;
  * @dccps_service_list - second .. last service code on passive socket
  * @dccps_timestamp_time - time of latest TIMESTAMP option
  * @dccps_timestamp_echo - latest timestamp received on a TIMESTAMP option
- * @dccps_l_ack_ratio -
- * @dccps_r_ack_ratio -
+ * @dccps_l_ack_ratio - feature-local Ack Ratio
+ * @dccps_r_ack_ratio - feature-remote Ack Ratio
  * @dccps_pcslen - sender   partial checksum coverage (via sockopt)
  * @dccps_pcrlen - receiver partial checksum coverage (via sockopt)
  * @dccps_ndp_count - number of Non Data Packets since last data packet
- * @dccps_mss_cache -
- * @dccps_minisock -
+ * @dccps_mss_cache - current value of MSS (path MTU minus header sizes)
+ * @dccps_minisock - associated minisock (accessed via dccp_msk)
  * @dccps_hc_rx_ackvec - rx half connection ack vector
- * @dccps_hc_rx_ccid -
- * @dccps_hc_tx_ccid -
- * @dccps_options_received -
- * @dccps_role - Role of this sock, one of %dccp_role
- * @dccps_hc_rx_insert_options -
- * @dccps_hc_tx_insert_options -
+ * @dccps_hc_rx_ccid - CCID used for the receiver (or receiving half-connection)
+ * @dccps_hc_tx_ccid - CCID used for the sender (or sending half-connection)
+ * @dccps_options_received - parsed set of retrieved options
+ * @dccps_role - role of this sock, one of %dccp_role
+ * @dccps_hc_rx_insert_options - receiver wants to add options when acking
+ * @dccps_hc_tx_insert_options - sender wants to add options when sending
  * @dccps_xmit_timer - timer for when CCID is not ready to send
  * @dccps_syn_rtt - RTT sample from Request/Response exchange (in usecs)
  */
