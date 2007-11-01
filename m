From: Leandro <leandroal@gmail.com>
Date: Thu, 01 Nov 2007 00:31:46 +0000
Subject: [PATCH 15/25] Share ccid3_hc_tx_sock struct and ccid3_hc_tx_sk function via tfrc_ccids
Message-Id: <200710312131.46673.leandroal@gmail.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[CCID-3/4] Share ccid3_hc_tx_sock struct and ccid3_hc_tx_sk function via tfrc_ccids

ccid3_hc_tx_sock is now tfrc_hc_tx_sock
ccid3_hc_tx_sk is now tfrc_hc_tx_sk

Since it is a big change, I adopted the strategy of change the ccid-3 and ccid-4 coding by phases, and for each phase have the ccid-3 and ccid-4 code still compilable. In order to archive this strategy I declared some define to not break the rest of the code and enable me to provide some tests before the final version of tfrc_ccids, which has all the common functions and structs between ccid-3/ccid-4 as the same time that ccid-3 and ccid-4 use this common resources.

Signed-off-by: Leandro Melo de Sales <leandro@embedded.ufcg.edu.br>

Index: leandro.new/net/dccp/ccids/ccid3.c
=================================--- leandro.new.orig/net/dccp/ccids/ccid3.c
+++ leandro.new/net/dccp/ccids/ccid3.c
@@ -65,6 +65,34 @@ static const char *ccid3_tx_state_name(e
 }
 #endif
 
+/**
+ * Each of the following #define aims at maintain the current
+ * dccp code nomenclature unchanged while still share
+ * tfrc_hc_tx_sock struct and until it is defined a final
+ * solution to share ccid3/ccid4 common code. This can also facilitate future
+ * changes, for instance, if we decide to have two hc_tx_sock
+ * struct, one for ccid3 and another for ccid4.
+ */
+#define ccid3_hc_tx_sock tfrc_hc_tx_sock
+#define ccid3hctx_s tfrchctx_s
+#define ccid3hctx_tfrc tfrchctx_tfrc
+#define ccid3hctx_delta tfrchctx_delta
+#define ccid3hctx_t_last_win_count tfrchctx_t_last_win_count
+#define ccid3hctx_t_ld tfrchctx_t_ld
+#define ccid3hctx_last_win_count tfrchctx_last_win_count
+#define ccid3hctx_no_feedback_timer tfrchctx_no_feedback_timer
+#define ccid3hctx_t_nom tfrchctx_t_nom
+#define ccid3hctx_hist tfrchctx_hist
+#define ccid3hctx_rtt tfrchctx_rtt
+#define ccid3hctx_t_ipi tfrchctx_t_ipi
+#define ccid3hctx_x tfrchctx_x
+#define ccid3hctx_p tfrchctx_p
+#define ccid3hctx_x_calc tfrchctx_x_calc
+#define ccid3hctx_t_rto tfrchctx_t_rto
+#define ccid3hctx_x_recv tfrchctx_x_recv
+
+#define ccid3_hc_tx_sk tfrc_hc_tx_sk
+
 static void ccid3_hc_tx_set_state(struct sock *sk,
 				  enum tfrc_hc_tx_states state)
 {
Index: leandro.new/net/dccp/ccids/ccid4.c
=================================--- leandro.new.orig/net/dccp/ccids/ccid4.c
+++ leandro.new/net/dccp/ccids/ccid4.c
@@ -75,6 +75,34 @@ static const char *ccid4_tx_state_name(e
 }
 #endif
 
+/**
+ * Each of the following #define aims at maintain the current
+ * dccp code nomenclature unchanged while still share
+ * tfrc_hc_tx_sock struct and until it is defined a final
+ * solution to share ccid3/ccid4 common code. This can also facilitate future
+ * changes, for instance, if we decide to have two hc_tx_sock
+ * struct, one for ccid3 and another for ccid4.
+ */
+#define ccid4_hc_tx_sock tfrc_hc_tx_sock
+#define ccid4hctx_s tfrchctx_s
+#define ccid4hctx_tfrc tfrchctx_tfrc
+#define ccid4hctx_delta tfrchctx_delta
+#define ccid4hctx_t_last_win_count tfrchctx_t_last_win_count
+#define ccid4hctx_t_ld tfrchctx_t_ld
+#define ccid4hctx_last_win_count tfrchctx_last_win_count
+#define ccid4hctx_no_feedback_timer tfrchctx_no_feedback_timer
+#define ccid4hctx_t_nom tfrchctx_t_nom
+#define ccid4hctx_hist tfrchctx_hist
+#define ccid4hctx_rtt tfrchctx_rtt
+#define ccid4hctx_t_ipi tfrchctx_t_ipi
+#define ccid4hctx_x tfrchctx_x
+#define ccid4hctx_p tfrchctx_p
+#define ccid4hctx_x_calc tfrchctx_x_calc
+#define ccid4hctx_t_rto tfrchctx_t_rto
+#define ccid4hctx_x_recv tfrchctx_x_recv
+
+#define ccid4_hc_tx_sk tfrc_hc_tx_sk
+
 static void ccid4_hc_tx_set_state(struct sock *sk,
 				  enum tfrc_hc_tx_states state)
 {
Index: leandro.new/net/dccp/ccids/lib/tfrc_ccids.h
=================================--- leandro.new.orig/net/dccp/ccids/lib/tfrc_ccids.h
+++ leandro.new/net/dccp/ccids/lib/tfrc_ccids.h
@@ -20,6 +20,7 @@
 #include <linux/tfrc.h>
 #include <asm/unaligned.h>
 #include "tfrc.h"
+#include "../../ccid.h"
 
 /* Two seconds as per RFC 3448 4.2 */
 #define TFRC_INITIAL_TIMEOUT	   (2 * USEC_PER_SEC)
@@ -72,3 +73,52 @@ enum tfrc_fback_type {
 	FBACK_PARAM_CHANGE
 };
 
+/** struct tfrc_hc_tx_sock - CCID3/4 sender half-connection socket
+ *
+ * @tfrchctx_x - Current sending rate in 64 * bytes per second
+ * @tfrchctx_x_recv - Receive rate    in 64 * bytes per second
+ * @tfrchctx_x_calc - Calculated rate in bytes per second
+ * @tfrchctx_rtt - Estimate of current round trip time in usecs
+ * @tfrchctx_p - Current loss event rate (0-1) scaled by 1000000
+ * @tfrchctx_s - Packet size in bytes
+ * @tfrchctx_t_rto - Nofeedback Timer setting in usecs
+ * @tfrchctx_t_ipi - Interpacket (send) interval (RFC 3448, 4.6) in usecs
+ * @tfrchctx_state - Sender state, one of %tfrc_hc_tx_states
+ * @tfrchctx_last_win_count - Last window counter sent
+ * @tfrchctx_t_last_win_count - Timestamp of earliest packet
+ *				 with last_win_count value sent
+ * @tfrchctx_no_feedback_timer - Handle to no feedback timer
+ * @tfrchctx_t_ld - Time last doubled during slow start
+ * @tfrchctx_t_nom - Nominal send time of next packet
+ * @tfrchctx_delta - Send timer delta (RFC 3448, 4.6) in usecs
+ * @tfrchctx_hist - Packet history
+ * @tfrchctx_options_received - Parsed set of retrieved options
+ */
+struct tfrc_hc_tx_sock {
+	struct tfrc_tx_info		tfrchctx_tfrc;
+#define tfrchctx_x			tfrchctx_tfrc.tfrctx_x
+#define tfrchctx_x_recv		tfrchctx_tfrc.tfrctx_x_recv
+#define tfrchctx_x_calc		tfrchctx_tfrc.tfrctx_x_calc
+#define tfrchctx_rtt			tfrchctx_tfrc.tfrctx_rtt
+#define tfrchctx_p			tfrchctx_tfrc.tfrctx_p
+#define tfrchctx_t_rto			tfrchctx_tfrc.tfrctx_rto
+#define tfrchctx_t_ipi			tfrchctx_tfrc.tfrctx_ipi
+	u16				tfrchctx_s;
+	enum tfrc_hc_tx_states	tfrchctx_state:8;
+	u8				tfrchctx_last_win_count;
+	ktime_t				tfrchctx_t_last_win_count;
+	struct timer_list		tfrchctx_no_feedback_timer;
+	ktime_t				tfrchctx_t_ld;
+	ktime_t				tfrchctx_t_nom;
+	u32				tfrchctx_delta;
+	struct tfrc_tx_hist_head	tfrchctx_hist;
+	struct tfrc_options_received	tfrchctx_options_received;
+};
+
+static inline struct tfrc_hc_tx_sock *tfrc_hc_tx_sk(const struct sock *sk)
+{
+    struct tfrc_hc_tx_sock *hctx = ccid_priv(dccp_sk(sk)->dccps_hc_tx_ccid);
+    BUG_ON(hctx = NULL);
+    return hctx;
+}
+
Index: leandro.new/net/dccp/probe.c
=================================--- leandro.new.orig/net/dccp/probe.c
+++ leandro.new/net/dccp/probe.c
@@ -76,6 +76,17 @@ static void printl(const char *fmt, ...)
 	wake_up(&dccpw.wait);
 }
 
+#define ccid3_hc_tx_sock tfrc_hc_tx_sock
+#define ccid3hctx_s tfrchctx_s
+#define ccid3hctx_p tfrchctx_p
+#define ccid3hctx_rtt tfrchctx_rtt
+#define ccid3hctx_x_calc tfrchctx_x_calc
+#define ccid3hctx_x_recv tfrchctx_x_recv
+#define ccid3hctx_x tfrchctx_x
+#define ccid3hctx_t_ipi tfrchctx_t_ipi
+
+#define ccid3_hc_tx_sk tfrc_hc_tx_sk
+
 static int jdccp_sendmsg(struct kiocb *iocb, struct sock *sk,
 			 struct msghdr *msg, size_t size)
 {
@@ -92,10 +103,10 @@ static int jdccp_sendmsg(struct kiocb *i
 			       "%llu %llu %d\n",
 			       NIPQUAD(inet->saddr), ntohs(inet->sport),
 			       NIPQUAD(inet->daddr), ntohs(inet->dport), size,
-			       hctx->ccid3hctx_s, hctx->ccid3hctx_rtt,
-			       hctx->ccid3hctx_p, hctx->ccid3hctx_x_calc,
-			       hctx->ccid3hctx_x_recv >> 6,
-			       hctx->ccid3hctx_x >> 6, hctx->ccid3hctx_t_ipi);
+			       hctx->tfrchctx_s, hctx->tfrchctx_rtt,
+			       hctx->tfrchctx_p, hctx->tfrchctx_x_calc,
+			       hctx->tfrchctx_x_recv >> 6,
+			       hctx->tfrchctx_x >> 6, hctx->tfrchctx_t_ipi);
 		else
 			printl("%d.%d.%d.%d:%u %d.%d.%d.%d:%u %d\n",
 			       NIPQUAD(inet->saddr), ntohs(inet->sport),
Index: leandro.new/net/dccp/ccids/ccid3.h
=================================--- leandro.new.orig/net/dccp/ccids/ccid3.h
+++ leandro.new/net/dccp/ccids/ccid3.h
@@ -37,56 +37,6 @@
  *  Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
  */
 #include "lib/tfrc_ccids.h"
-#include "../ccid.h"
-
-/** struct ccid3_hc_tx_sock - CCID3 sender half-connection socket
- *
- * @ccid3hctx_x - Current sending rate in 64 * bytes per second
- * @ccid3hctx_x_recv - Receive rate    in 64 * bytes per second
- * @ccid3hctx_x_calc - Calculated rate in bytes per second
- * @ccid3hctx_rtt - Estimate of current round trip time in usecs
- * @ccid3hctx_p - Current loss event rate (0-1) scaled by 1000000
- * @ccid3hctx_s - Packet size in bytes
- * @ccid3hctx_t_rto - Nofeedback Timer setting in usecs
- * @ccid3hctx_t_ipi - Interpacket (send) interval (RFC 3448, 4.6) in usecs
- * @tfrchctx_state - Sender state, one of %tfrc_hc_tx_states
- * @ccid3hctx_last_win_count - Last window counter sent
- * @ccid3hctx_t_last_win_count - Timestamp of earliest packet
- *				 with last_win_count value sent
- * @ccid3hctx_no_feedback_timer - Handle to no feedback timer
- * @ccid3hctx_t_ld - Time last doubled during slow start
- * @ccid3hctx_t_nom - Nominal send time of next packet
- * @ccid3hctx_delta - Send timer delta (RFC 3448, 4.6) in usecs
- * @ccid3hctx_hist - Packet history
- * @ccid3hctx_options_received - Parsed set of retrieved options
- */
-struct ccid3_hc_tx_sock {
-	struct tfrc_tx_info		ccid3hctx_tfrc;
-#define ccid3hctx_x			ccid3hctx_tfrc.tfrctx_x
-#define ccid3hctx_x_recv		ccid3hctx_tfrc.tfrctx_x_recv
-#define ccid3hctx_x_calc		ccid3hctx_tfrc.tfrctx_x_calc
-#define ccid3hctx_rtt			ccid3hctx_tfrc.tfrctx_rtt
-#define ccid3hctx_p			ccid3hctx_tfrc.tfrctx_p
-#define ccid3hctx_t_rto			ccid3hctx_tfrc.tfrctx_rto
-#define ccid3hctx_t_ipi			ccid3hctx_tfrc.tfrctx_ipi
-	u16				ccid3hctx_s;
-	enum tfrc_hc_tx_states	tfrchctx_state:8;
-	u8				ccid3hctx_last_win_count;
-	ktime_t				ccid3hctx_t_last_win_count;
-	struct timer_list		ccid3hctx_no_feedback_timer;
-	ktime_t				ccid3hctx_t_ld;
-	ktime_t				ccid3hctx_t_nom;
-	u32				ccid3hctx_delta;
-	struct tfrc_tx_hist_head	ccid3hctx_hist;
-	struct tfrc_options_received	tfrchctx_options_received;
-};
-
-static inline struct ccid3_hc_tx_sock *ccid3_hc_tx_sk(const struct sock *sk)
-{
-    struct ccid3_hc_tx_sock *hctx = ccid_priv(dccp_sk(sk)->dccps_hc_tx_ccid);
-    BUG_ON(hctx = NULL);
-    return hctx;
-}
 
 /** struct ccid3_hc_rx_sock - CCID3 receiver half-connection socket
  *
Index: leandro.new/net/dccp/ccids/ccid4.h
=================================--- leandro.new.orig/net/dccp/ccids/ccid4.h
+++ leandro.new/net/dccp/ccids/ccid4.h
@@ -49,7 +49,6 @@
  *  Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
  */
 #include "lib/tfrc_ccids.h" 
-#include "../ccid.h"
 
 /* The nominal packet size to be used into TFRC equation as per CCID-4 draft*/
 #define NOM_PACKET_SIZE            1460
@@ -62,55 +61,6 @@
  */
 #define CCID4HCTX_H    36
 
-/** struct ccid4_hc_tx_sock - CCID4 sender half-connection socket
- *
- * @ccid4hctx_x - Current sending rate in 64 * bytes per second
- * @ccid4hctx_x_recv - Receive rate    in 64 * bytes per second
- * @ccid4hctx_x_calc - Calculated rate in bytes per second
- * @ccid4hctx_rtt - Estimate of current round trip time in usecs
- * @ccid4hctx_p - Current loss event rate (0-1) scaled by 1000000
- * @ccid4hctx_s - Packet size in bytes
- * @ccid4hctx_t_rto - Nofeedback Timer setting in usecs
- * @ccid4hctx_t_ipi - Interpacket (send) interval (RFC 3448, 4.6) in usecs
- * @tfrchctx_state - Sender state, one of %tfrc_hc_tx_states
- * @ccid4hctx_last_win_count - Last window counter sent
- * @ccid4hctx_t_last_win_count - Timestamp of earliest packet
- *				 with last_win_count value sent
- * @ccid4hctx_no_feedback_timer - Handle to no feedback timer
- * @ccid4hctx_t_ld - Time last doubled during slow start
- * @ccid4hctx_t_nom - Nominal send time of next packet
- * @ccid4hctx_delta - Send timer delta (RFC 3448, 4.6) in usecs
- * @ccid4hctx_hist - Packet history
- * @ccid4hctx_options_received - Parsed set of retrieved options
- */
-struct ccid4_hc_tx_sock {
-	struct tfrc_tx_info		ccid4hctx_tfrc;
-#define ccid4hctx_x			ccid4hctx_tfrc.tfrctx_x
-#define ccid4hctx_x_recv		ccid4hctx_tfrc.tfrctx_x_recv
-#define ccid4hctx_x_calc		ccid4hctx_tfrc.tfrctx_x_calc
-#define ccid4hctx_rtt			ccid4hctx_tfrc.tfrctx_rtt
-#define ccid4hctx_p			ccid4hctx_tfrc.tfrctx_p
-#define ccid4hctx_t_rto			ccid4hctx_tfrc.tfrctx_rto
-#define ccid4hctx_t_ipi			ccid4hctx_tfrc.tfrctx_ipi
-	u16				ccid4hctx_s;
-	enum tfrc_hc_tx_states	tfrchctx_state:8;
-	u8				ccid4hctx_last_win_count;
-	ktime_t				ccid4hctx_t_last_win_count;
-	struct timer_list		ccid4hctx_no_feedback_timer;
-	ktime_t				ccid4hctx_t_ld;
-	ktime_t				ccid4hctx_t_nom;
-	u32				ccid4hctx_delta;
-	struct tfrc_tx_hist_head	ccid4hctx_hist;
-	struct tfrc_options_received	tfrchctx_options_received;
-};
-
-static inline struct ccid4_hc_tx_sock *ccid4_hc_tx_sk(const struct sock *sk)
-{
-    struct ccid4_hc_tx_sock *hctx = ccid_priv(dccp_sk(sk)->dccps_hc_tx_ccid);
-    BUG_ON(hctx = NULL);
-    return hctx;
-}
-
 /** struct ccid4_hc_rx_sock - CCID4 receiver half-connection socket
  *
  *  @ccid4hcrx_last_counter  -  Tracks window counter (RFC 4342, 8.1)
