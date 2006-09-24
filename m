From: Arnaldo Carvalho de Melo <acme@mandriva.com>
Date: Sun, 24 Sep 2006 21:18:57 +0000
Subject: [PATCH 2/4][DCCP]: Introduce constants for CCID numbers
Message-Id: <20060924211856.GC6263@mandriva.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hi David,

   Please consider pulling from:

master.kernel.org:/pub/scm/linux/kernel/git/acme/net-2.6.git

Best Regards,

- Arnaldo

Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>
---
 include/linux/dccp.h |    8 +++++++-
 1 files changed, 7 insertions(+), 1 deletions(-)

diff --git a/include/linux/dccp.h b/include/linux/dccp.h
index 29f9291..d6f4ec4 100644
--- a/include/linux/dccp.h
+++ b/include/linux/dccp.h
@@ -169,6 +169,12 @@ enum {
 	DCCPO_MAX_CCID_SPECIFIC = 255,
 };
 
+/* DCCP CCIDS */
+enum {
+	DCCPC_CCID2 = 2,
+	DCCPC_CCID3 = 3,
+};
+
 /* DCCP features */
 enum {
 	DCCPF_RESERVED = 0,
@@ -320,7 +326,7 @@ static inline unsigned int dccp_hdr_len(
 /* initial values for each feature */
 #define DCCPF_INITIAL_SEQUENCE_WINDOW		100
 #define DCCPF_INITIAL_ACK_RATIO			2
-#define DCCPF_INITIAL_CCID			2
+#define DCCPF_INITIAL_CCID			DCCPC_CCID2
 #define DCCPF_INITIAL_SEND_ACK_VECTOR		1
 /* FIXME: for now we're default to 1 but it should really be 0 */
 #define DCCPF_INITIAL_SEND_NDP_COUNT		1
-- 
1.4.2.1.g3d5c

