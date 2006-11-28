From: Arnaldo Carvalho de Melo <acme@mandriva.com>
Date: Tue, 28 Nov 2006 21:58:51 +0000
Subject: [PATCH 5/7] [DCCP]: Make {set,get}sockopt(DCCP_SOCKOPT_PACKET_SIZE) return 0
Message-Id: <20061128215850.GN19882@mandriva.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

To reflect the fact that this now is of no effect, not making apps
stop working, just be warned in the system log.

Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>
---
 net/dccp/proto.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/dccp/proto.c b/net/dccp/proto.c
index 2604e34..5ec47d9 100644
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -471,7 +471,7 @@ static int do_dccp_setsockopt(struct soc
 	switch (optname) {
 	case DCCP_SOCKOPT_PACKET_SIZE:
 		DCCP_WARN("sockopt(PACKET_SIZE) is deprecated: fix your app\n");
-		err = -EINVAL;
+		err = 0;
 		break;
 	case DCCP_SOCKOPT_CHANGE_L:
 		if (optlen != sizeof(struct dccp_so_feat))
@@ -583,7 +583,7 @@ static int do_dccp_getsockopt(struct soc
 	switch (optname) {
 	case DCCP_SOCKOPT_PACKET_SIZE:
 		DCCP_WARN("sockopt(PACKET_SIZE) is deprecated: fix your app\n");
-		return -EINVAL;
+		return 0;
 	case DCCP_SOCKOPT_SERVICE:
 		return dccp_getsockopt_service(sk, len,
 					       (__be32 __user *)optval, optlen);
-- 
1.4.2.1.g3d5c

