From: Fabian Frederick <fabf@skynet.be>
Date: Mon, 17 Nov 2014 21:00:22 +0000
Subject: [PATCH 1/1 net-next] dccp: spelling s/reseting/resetting
Message-Id: <1416258022-7320-1-git-send-email-fabf@skynet.be>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Signed-off-by: Fabian Frederick <fabf@skynet.be>
---
 net/dccp/input.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/dccp/input.c b/net/dccp/input.c
index 3c8ec7d..3bd14e8 100644
--- a/net/dccp/input.c
+++ b/net/dccp/input.c
@@ -537,7 +537,7 @@ static int dccp_rcv_respond_partopen_state_process(struct sock *sk,
 	case DCCP_PKT_DATAACK:
 	case DCCP_PKT_ACK:
 		/*
-		 * FIXME: we should be reseting the PARTOPEN (DELACK) timer
+		 * FIXME: we should be resetting the PARTOPEN (DELACK) timer
 		 * here but only if we haven't used the DELACK timer for
 		 * something else, like sending a delayed ack for a TIMESTAMP
 		 * echo, etc, for now were not clearing it, sending an extra
-- 
1.9.3

