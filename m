From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Thu, 31 Jan 2008 18:31:41 +0000
Subject: [PATCH 3/6] [DCCP]: Reorganize struct dccp_sock to save 8 bytes
Message-Id: <1201804304-28777-4-git-send-email-acme@redhat.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

/home/acme/git/net-2.6/net/dccp/ipv6.c:
  struct dccp_sock  |   -8
  struct dccp6_sock |   -8
 2 structs changed

Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 include/linux/dccp.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/include/linux/dccp.h b/include/linux/dccp.h
index 484e45c..aa07370 100644
--- a/include/linux/dccp.h
+++ b/include/linux/dccp.h
@@ -525,6 +525,7 @@ struct dccp_sock {
 	__u64				dccps_gsr;
 	__u64				dccps_gar;
 	__be32				dccps_service;
+	__u32				dccps_mss_cache;
 	struct dccp_service_list	*dccps_service_list;
 	__u32				dccps_timestamp_echo;
 	__u32				dccps_timestamp_time;
@@ -533,7 +534,6 @@ struct dccp_sock {
 	__u16				dccps_pcslen;
 	__u16				dccps_pcrlen;
 	unsigned long			dccps_ndp_count;
-	__u32				dccps_mss_cache;
 	unsigned long			dccps_rate_last;
 	struct dccp_minisock		dccps_minisock;
 	struct dccp_ackvec		*dccps_hc_rx_ackvec;
-- 
1.5.3.8

