From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 25 Jul 2008 09:02:55 +0000
Subject: [PATCH 3/6] dccp: Fix sequence number check for ICMPv4 packets
Message-Id: <1216976578-17767-4-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Wei Yongjun <yjwei@cn.fujitsu.com>

The payload of ICMP message is a part of the packet sent by ourself,
so the sequence number check must use AWL and AWH, not SWL and SWH.

For example:
     Endpoint A                  Endpoint B

     DATA-ACK       -------->
     (SEQ=X)
                    <--------    ICMP (Fragmentation Needed)
                                 (SEQ=X)

Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
Acked-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ipv4.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

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
