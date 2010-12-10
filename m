From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 10 Dec 2010 11:59:31 +0000
Subject: [PATCH 1/1] dccp: remove unused macros
Message-Id: <1291982371-5666-2-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Shan Wei <shanwei@cn.fujitsu.com>

Remove macros which have been unused since the initial implementation
(commit 7c657876b63cb1d8a2ec06f8fc6c37bb8412e66c, [DCCP]: Initial
 implementation from Tue Aug 9 20:14:34 2005 -0700).

Signed-off-by: Shan Wei <shanwei@cn.fujitsu.com>
Acked-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/dccp.h |    8 --------
 1 files changed, 0 insertions(+), 8 deletions(-)

diff --git a/net/dccp/dccp.h b/net/dccp/dccp.h
index 48ad5d9..4508705 100644
--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -93,9 +93,6 @@ extern void dccp_time_wait(struct sock *sk, int state, int timeo);
 #define DCCP_FALLBACK_RTT	(USEC_PER_SEC / 5)
 #define DCCP_SANE_RTT_MAX	(3 * USEC_PER_SEC)
 
-/* Maximal interval between probes for local resources.  */
-#define DCCP_RESOURCE_PROBE_INTERVAL ((unsigned)(HZ / 2U))
-
 /* sysctl variables for DCCP */
 extern int  sysctl_dccp_request_retries;
 extern int  sysctl_dccp_retries1;
@@ -203,12 +200,7 @@ struct dccp_mib {
 DECLARE_SNMP_STAT(struct dccp_mib, dccp_statistics);
 #define DCCP_INC_STATS(field)	    SNMP_INC_STATS(dccp_statistics, field)
 #define DCCP_INC_STATS_BH(field)    SNMP_INC_STATS_BH(dccp_statistics, field)
-#define DCCP_INC_STATS_USER(field)  SNMP_INC_STATS_USER(dccp_statistics, field)
 #define DCCP_DEC_STATS(field)	    SNMP_DEC_STATS(dccp_statistics, field)
-#define DCCP_ADD_STATS_BH(field, val) \
-			SNMP_ADD_STATS_BH(dccp_statistics, field, val)
-#define DCCP_ADD_STATS_USER(field, val)	\
-			SNMP_ADD_STATS_USER(dccp_statistics, field, val)
 
 /*
  * 	Checksumming routines
