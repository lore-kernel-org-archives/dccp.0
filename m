From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 24 Oct 2006 13:59:01 +0000
Subject: [PATCH 1/17] [DCCP]: set safe upper bound for option length
Message-Id: <200610241459.01779@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This is a re-send from 
http://www.mail-archive.com/dccp@vger.kernel.org/msg00553.html

It is the same patch as before, but I have built in Arnaldo's suggestions
pointed out in that posting. 

Signed-off-by: Gerrit Renker  <gerrit@erg.abdn.ac.uk>
------------------------------------------------------------------------------

 net/dccp/dccp.h |   18 ++++++++++++------
 1 file changed, 12 insertions(+), 6 deletions(-)

------------------------------------------------------------------------------

diff --git a/net/dccp/dccp.h b/net/dccp/dccp.h
index 272e858..9f00dd8 100644
--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -40,12 +40,18 @@ extern void dccp_tw_deschedule(struct in
 
 extern void dccp_time_wait(struct sock *sk, int state, int timeo);
 
-/* FIXME: Right size this */
-#define DCCP_MAX_OPT_LEN 128
-
-#define DCCP_MAX_PACKET_HDR 32
-
-#define MAX_DCCP_HEADER  (DCCP_MAX_PACKET_HDR + DCCP_MAX_OPT_LEN + MAX_HEADER)
+/*
+ *  Set safe upper bounds for header and option length. Since Data Offset is 8
+ *  bits (RFC 4340, sec. 5.1), the total header length can never be more than
+ *  4 * 255 = 1020 bytes. The largest possible header length is 28 bytes (X=1):
+ *    - DCCP-Response with ACK Subheader and 4 bytes of Service code      OR
+ *    - DCCP-Reset    with ACK Subheader and 4 bytes of Reset Code fields
+ *  Hence a safe upper bound for the maximum option length is 1020-28 = 992
+ */
+#define MAX_DCCP_SPECIFIC_HEADER (255 * sizeof(int))
+#define DCCP_MAX_PACKET_HDR 28
+#define DCCP_MAX_OPT_LEN (MAX_DCCP_SPECIFIC_HEADER - DCCP_MAX_PACKET_HDR)
+#define MAX_DCCP_HEADER (MAX_DCCP_SPECIFIC_HEADER + MAX_HEADER)
 
 #define DCCP_TIMEWAIT_LEN (60 * HZ) /* how long to wait to destroy TIME-WAIT
 				     * state, about 60 seconds */
