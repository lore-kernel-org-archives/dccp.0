From: Pavel Emelyanov <xemul@openvz.org>
Date: Tue, 08 Apr 2008 17:23:35 +0000
Subject: [RFC][PATCH 7/12][NETNS][DCCPV4]: Enable DCCPv4 in net namespaces.
Message-Id: <47FBAA17.3010704@openvz.org>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This enables sockets creation with IPPROTO_DCCP and enables
the ip level to pass DCCP packets to the DCCP level.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---
 net/dccp/ipv4.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index 66f860b..b997466 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -952,6 +952,7 @@ static struct net_protocol dccp_v4_protocol = {
 	.handler	= dccp_v4_rcv,
 	.err_handler	= dccp_v4_err,
 	.no_policy	= 1,
+	.netns_ok	= 1,
 };
 
 static const struct proto_ops inet_dccp_ops = {
-- 
1.5.3.4

