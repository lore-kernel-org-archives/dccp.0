From: Joe Perches <joe@perches.com>
Date: Tue, 20 Nov 2007 01:53:38 +0000
Subject: [PATCH 51/59] net/dccp: Add missing "space"
Message-Id: <29542305a25cef11c0f5f7e978d9bf50ef60b4b3.1195454436.git.joe@perches.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org


Signed-off-by: Joe Perches <joe@perches.com>
---
 net/dccp/ccids/lib/loss_interval.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/dccp/ccids/lib/loss_interval.c b/net/dccp/ccids/lib/loss_interval.c
index 40ad428..d26b88d 100644
--- a/net/dccp/ccids/lib/loss_interval.c
+++ b/net/dccp/ccids/lib/loss_interval.c
@@ -166,7 +166,7 @@ static u32 dccp_li_calc_first_li(struct sock *sk,
 	}
 
 	if (unlikely(interval = 0)) {
-		DCCP_WARN("%s(%p), Could not find a win_count interval > 0."
+		DCCP_WARN("%s(%p), Could not find a win_count interval > 0. "
 			  "Defaulting to 1\n", dccp_role(sk), sk);
 		interval = 1;
 	}
-- 
1.5.3.5.652.gf192c

