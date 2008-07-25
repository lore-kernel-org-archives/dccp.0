From: Wei Yongjun <yjwei@cn.fujitsu.com>
Date: Fri, 25 Jul 2008 02:35:58 +0000
Subject: [PATCHv2 1/4] DCCP: Fix to check the sequence number in ICMP message
Message-Id: <48893C0E.7020904@cn.fujitsu.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

The payload of ICMP message is a part of the packet which send by 
ourself, so check the sequence number must used AWL and AWH, not SWL and 
SWH.

For example:
     Endpoint A                  Endpoint B

     DATA-ACK       -------->
     (SEQ=X)
                    <--------    ICMP (Fragmentation Needed)
                                 (SEQ=X)

Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
---
 net/dccp/ipv4.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index f966729..8fd4d57 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -238,7 +238,7 @@ static void dccp_v4_err(struct sk_buff *skb, u32 info)
 	dp = dccp_sk(sk);
 	seq = dccp_hdr_seq(dh);
 	if ((1 << sk->sk_state) & ~(DCCPF_REQUESTING | DCCPF_LISTEN) &&
-	    !between48(seq, dp->dccps_swl, dp->dccps_swh)) {
+	    !between48(seq, dp->dccps_awl, dp->dccps_awh)) {
 		NET_INC_STATS_BH(net, LINUX_MIB_OUTOFWINDOWICMPS);
 		goto out;
 	}


