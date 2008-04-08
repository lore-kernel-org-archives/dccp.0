From: Pavel Emelyanov <xemul@openvz.org>
Date: Tue, 08 Apr 2008 17:25:49 +0000
Subject: [RFC][PATCH 8/12][NETNS][DCCPV6]: Don't pass NULL to ip6_dst_lookup.
Message-Id: <47FBAA9D.7030305@openvz.org>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This call uses the sock to get the net to lookup the routing
in. With CONFIG_NET_NS this code will OOPS, since the sk ptr
is NULL.

After looking inside the ip6_dst_lookup and drawing the analogy
with respective ipv6 code, it seems, that the dccp ctl socket 
is a good candidate for the first argument.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---
 net/dccp/ipv6.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index 94d749e..b657dea 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -322,7 +322,7 @@ static void dccp_v6_ctl_send_reset(struct sock *sk, struct sk_buff *rxskb)
 	security_skb_classify_flow(rxskb, &fl);
 
 	/* sk = NULL, but it is safe for now. RST socket required. */
-	if (!ip6_dst_lookup(NULL, &skb->dst, &fl)) {
+	if (!ip6_dst_lookup(dccp_v6_ctl_sk, &skb->dst, &fl)) {
 		if (xfrm_lookup(&skb->dst, &fl, NULL, 0) >= 0) {
 			ip6_xmit(dccp_v6_ctl_sk, skb, &fl, NULL, 0);
 			DCCP_INC_STATS_BH(DCCP_MIB_OUTSEGS);
-- 
1.5.3.4

