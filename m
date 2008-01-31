From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Thu, 31 Jan 2008 18:31:43 +0000
Subject: [PATCH 5/6] [INET_TIMEWAIT_SOCK]: Reorganize struct inet_timewait_sock to save some bytes
Message-Id: <1201804304-28777-6-git-send-email-acme@redhat.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

/home/acme/git/net-2.6/net/ipv6/tcp_ipv6.c:
  struct inet_timewait_sock |   -8
  struct tcp_timewait_sock  |   -8
 2 structs changed
  tcp_v6_rcv                |   -6
 1 function changed, 6 bytes removed, diff: -6

Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 include/net/inet_timewait_sock.h |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/include/net/inet_timewait_sock.h b/include/net/inet_timewait_sock.h
index 67e9250..faead52 100644
--- a/include/net/inet_timewait_sock.h
+++ b/include/net/inet_timewait_sock.h
@@ -116,8 +116,8 @@ struct inet_timewait_sock {
 #define tw_hash			__tw_common.skc_hash
 #define tw_prot			__tw_common.skc_prot
 #define tw_net			__tw_common.skc_net
+	int			tw_timeout;
 	volatile unsigned char	tw_substate;
-	/* 3 bits hole, try to pack */
 	unsigned char		tw_rcv_wscale;
 	/* Socket demultiplex comparisons on incoming packets. */
 	/* these five are in inet_sock */
@@ -130,7 +130,6 @@ struct inet_timewait_sock {
 	__u8			tw_ipv6only:1;
 	/* 15 bits hole, try to pack */
 	__u16			tw_ipv6_offset;
-	int			tw_timeout;
 	unsigned long		tw_ttd;
 	struct inet_bind_bucket	*tw_tb;
 	struct hlist_node	tw_death_node;
-- 
1.5.3.8

