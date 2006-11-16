From: Arnaldo Carvalho de Melo <acme@mandriva.com>
Date: Thu, 16 Nov 2006 16:32:42 +0000
Subject: [PATCH 1/3][DCCP]: One NET_INC_STATS() could be NET_INC_STATS_BH in dccp_v4_err()
Message-Id: <20061116163241.GC5195@mandriva.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Spotted by Eric Dumazet in tcp_v4_rcv().

Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>
---
 net/dccp/ipv4.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index 6bca719..a20eb71 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -244,7 +244,7 @@ static void dccp_v4_err(struct sk_buff *
 	seq = dccp_hdr_seq(skb);
 	if (sk->sk_state != DCCP_LISTEN &&
 	    !between48(seq, dp->dccps_swl, dp->dccps_swh)) {
-		NET_INC_STATS(LINUX_MIB_OUTOFWINDOWICMPS);
+		NET_INC_STATS_BH(LINUX_MIB_OUTOFWINDOWICMPS);
 		goto out;
 	}
 
-- 
1.4.2.1.g3d5c

