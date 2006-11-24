From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 24 Nov 2006 10:17:27 +0000
Subject: [PATCH 6/6] [UPDATE]: Tidy up unused structures
Message-Id: <200611241017.27776@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This is an update which

	* keeps DCCP_SOCKOPT_PACKET_SIZE, adding a comment 
	* adds warning messages and error codes for set/getsockopt 
          in case an application tries to use this option
	* updates the changelog message

---------------------------- Commit Message ------------------------------

[CCID 3]: Tidy up unused structures

This removes and cleans up unused variables and structures which have
become unnecessary following the introduction of the EWMA patch to
automatically track the CCID 3 receiver/sender packet sizes `s'.

It deprecates the PACKET_SIZE socket option by returning an error code
and printing a deprecation warning if an application tries to read or
write this socket option.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---------------------------------------------------------------------------

 include/linux/dccp.h   |    4 +---
 net/dccp/ccids/ccid3.h |    4 ----
 net/dccp/proto.c       |    8 ++++----
 3 files changed, 5 insertions(+), 11 deletions(-)

---------------------------------------------------------------------------

--- a/include/linux/dccp.h
+++ b/include/linux/dccp.h
@@ -200,7 +200,7 @@ struct dccp_so_feat {
 };
 
 /* DCCP socket options */
-#define DCCP_SOCKOPT_PACKET_SIZE	1
+#define DCCP_SOCKOPT_PACKET_SIZE	1 /* XXX deprecated, without effect */
 #define DCCP_SOCKOPT_SERVICE		2
 #define DCCP_SOCKOPT_CHANGE_L		3
 #define DCCP_SOCKOPT_CHANGE_R		4
@@ -460,7 +460,6 @@ struct dccp_ackvec;
  * @dccps_service_list - second .. last service code on passive socket
  * @dccps_timestamp_time - time of latest TIMESTAMP option
  * @dccps_timestamp_echo - latest timestamp received on a TIMESTAMP option
- * @dccps_packet_size - Set thru setsockopt
  * @dccps_l_ack_ratio -
  * @dccps_r_ack_ratio -
  * @dccps_pcslen - sender   partial checksum coverage (via sockopt)
@@ -495,7 +494,6 @@ struct dccp_sock {
 	struct dccp_service_list	*dccps_service_list;
 	struct timeval			dccps_timestamp_time;
 	__u32				dccps_timestamp_echo;
-	__u32				dccps_packet_size;
 	__u16				dccps_l_ack_ratio;
 	__u16				dccps_r_ack_ratio;
 	__u16				dccps_pcslen;
--- a/net/dccp/ccids/ccid3.h
+++ b/net/dccp/ccids/ccid3.h
@@ -42,10 +42,6 @@
 #include <linux/tfrc.h>
 #include "../ccid.h"
 
-#define TFRC_MIN_PACKET_SIZE	   16
-#define TFRC_STD_PACKET_SIZE	  256
-#define TFRC_MAX_PACKET_SIZE	65535
-
 /* Two seconds as per CCID3 spec */
 #define TFRC_INITIAL_TIMEOUT	   (2 * USEC_PER_SEC)
 
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -470,7 +470,8 @@ static int do_dccp_setsockopt(struct soc
 	lock_sock(sk);
 	switch (optname) {
 	case DCCP_SOCKOPT_PACKET_SIZE:
-		dp->dccps_packet_size = val;
+		DCCP_WARN("sockopt(PACKET_SIZE) is deprecated: fix your app\n");
+		err = -EINVAL;
 		break;
 	case DCCP_SOCKOPT_CHANGE_L:
 		if (optlen != sizeof(struct dccp_so_feat))
@@ -581,9 +582,8 @@ static int do_dccp_getsockopt(struct soc
 
 	switch (optname) {
 	case DCCP_SOCKOPT_PACKET_SIZE:
-		val = dp->dccps_packet_size;
-		len = sizeof(dp->dccps_packet_size);
-		break;
+		DCCP_WARN("sockopt(PACKET_SIZE) is deprecated: fix your app\n");
+		return -EINVAL;
 	case DCCP_SOCKOPT_SERVICE:
 		return dccp_getsockopt_service(sk, len,
 					       (__be32 __user *)optval, optlen);
