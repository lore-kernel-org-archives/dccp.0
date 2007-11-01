From: Leandro <leandroal@gmail.com>
Date: Thu, 01 Nov 2007 00:30:29 +0000
Subject: [PATCH 8/25] Share common header files and defines between ccid-3/ccid-4
Message-Id: <200710312130.29210.leandroal@gmail.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[CCID-3/4] Share common header files between ccid-3/ccid-4

Signed-off-by: Leandro Melo de Sales <leandro@embedded.ufcg.edu.br>

Index: leandro.new/net/dccp/ccids/ccid4.h
=================================--- leandro.new.orig/net/dccp/ccids/ccid4.h
+++ leandro.new/net/dccp/ccids/ccid4.h
@@ -48,23 +48,9 @@
  *  along with this program; if not, write to the Free Software
  *  Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
  */
-#include <linux/ktime.h>
-#include <linux/list.h>
-#include <linux/types.h>
-#include <linux/tfrc.h>
-#include <asm/unaligned.h>
-#include "lib/tfrc.h"
+#include "lib/tfrc_ccids.h" 
 #include "../ccid.h"
 
-/* Two seconds as per RFC 3448 4.2 */
-#define TFRC_INITIAL_TIMEOUT	   (2 * USEC_PER_SEC)
-
-/* In usecs - half the scheduling granularity as per RFC3448 4.6 */
-#define TFRC_OPSYS_HALF_TIME_GRAN  (USEC_PER_SEC / (2 * HZ))
-
-/* Parameter t_mbi from [RFC 3448, 4.3]: backoff interval in seconds */
-#define TFRC_T_MBI		   64
-
 /* The nominal packet size to be used into TFRC equation as per CCID-4 draft*/
 #define NOM_PACKET_SIZE            1460
 
Index: leandro.new/net/dccp/ccids/lib/tfrc_ccids.h
=================================--- leandro.new.orig/net/dccp/ccids/lib/tfrc_ccids.h
+++ leandro.new/net/dccp/ccids/lib/tfrc_ccids.h
@@ -21,4 +21,13 @@
 #include <asm/unaligned.h>
 #include "tfrc.h"
 
+/* Two seconds as per RFC 3448 4.2 */
+#define TFRC_INITIAL_TIMEOUT	   (2 * USEC_PER_SEC)
+
+/* In usecs - half the scheduling granularity as per RFC3448 4.6 */
+#define TFRC_OPSYS_HALF_TIME_GRAN  (USEC_PER_SEC / (2 * HZ))
+
+/* Parameter t_mbi from [RFC 3448, 4.3]: backoff interval in seconds */
+#define TFRC_T_MBI		   64
+
 #endif /* _TFRC_CCIDS_H_ */
Index: leandro.new/net/dccp/ccids/ccid3.h
=================================--- leandro.new.orig/net/dccp/ccids/ccid3.h
+++ leandro.new/net/dccp/ccids/ccid3.h
@@ -36,22 +36,9 @@
  *  along with this program; if not, write to the Free Software
  *  Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
  */
-#include <linux/ktime.h>
-#include <linux/list.h>
-#include <linux/types.h>
-#include <linux/tfrc.h>
-#include "lib/tfrc.h"
+#include "lib/tfrc_ccids.h"
 #include "../ccid.h"
 
-/* Two seconds as per RFC 3448 4.2 */
-#define TFRC_INITIAL_TIMEOUT	   (2 * USEC_PER_SEC)
-
-/* In usecs - half the scheduling granularity as per RFC3448 4.6 */
-#define TFRC_OPSYS_HALF_TIME_GRAN  (USEC_PER_SEC / (2 * HZ))
-
-/* Parameter t_mbi from [RFC 3448, 4.3]: backoff interval in seconds */
-#define TFRC_T_MBI		   64
-
 enum ccid3_options {
 	TFRC_OPT_LOSS_EVENT_RATE = 192,
 	TFRC_OPT_LOSS_INTERVALS	 = 193,
