From: Arnaldo Carvalho de Melo <acme@mandriva.com>
Date: Wed, 22 Feb 2006 21:38:41 +0000
Subject: [PATCH 1/4] [DCCP]: Make CCID2 be the default
Message-Id: <1140644321223-git-send-email-acme@mandriva.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

As per the draft. This fixes the build when netfilter dccp components are built
and dccp isn't. Thanks to Reuben Farrelly for reporting this.

The following changesets will introduce /proc/sys/net/dccp/defaults/ to give
more flexibility to DCCP developers and testers while apps doesn't use
setsockopt to specify the desired CCID, etc.

Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>

---

 include/linux/dccp.h |    9 ---------
 1 files changed, 0 insertions(+), 9 deletions(-)

499dbc5e7f577a3a1712cee8dcb0e540082ab81d
diff --git a/include/linux/dccp.h b/include/linux/dccp.h
index 496dbad..e35f680 100644
--- a/include/linux/dccp.h
+++ b/include/linux/dccp.h
@@ -320,17 +320,8 @@ static inline unsigned int dccp_hdr_len(
 /* initial values for each feature */
 #define DCCPF_INITIAL_SEQUENCE_WINDOW		100
 #define DCCPF_INITIAL_ACK_RATIO			2
-
-#if defined(CONFIG_IP_DCCP_CCID2) || defined(CONFIG_IP_DCCP_CCID2_MODULE)
 #define DCCPF_INITIAL_CCID			2
 #define DCCPF_INITIAL_SEND_ACK_VECTOR		1
-#elif defined(CONFIG_IP_DCCP_CCID3) || defined(CONFIG_IP_DCCP_CCID3_MODULE)
-#define DCCPF_INITIAL_CCID			3
-#define DCCPF_INITIAL_SEND_ACK_VECTOR		0
-#else
-#error  "At least one CCID must be built as the default"
-#endif
-
 /* FIXME: for now we're default to 1 but it should really be 0 */
 #define DCCPF_INITIAL_SEND_NDP_COUNT		1
 
-- 
1.1.GIT


