From: Jules Irenge <jbi.octave@gmail.com>
Date: Sun, 23 Feb 2020 23:16:55 +0000
Subject: [PATCH 14/30] dccp: Add missing annotation for dccp_child_process()
Message-Id: <20200223231711.157699-15-jbi.octave@gmail.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Sparse reports a warning at dccp_child_process()
warning: context imbalance in dccp_child_process() - unexpected unlock
The root cause is the missing annotation at dccp_child_process()
Add the missing __releases(child) annotation

Signed-off-by: Jules Irenge <jbi.octave@gmail.com>
---
 net/dccp/minisocks.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/dccp/minisocks.c b/net/dccp/minisocks.c
index 25187528c308..c5c74a34d139 100644
--- a/net/dccp/minisocks.c
+++ b/net/dccp/minisocks.c
@@ -216,6 +216,7 @@ EXPORT_SYMBOL_GPL(dccp_check_req);
  */
 int dccp_child_process(struct sock *parent, struct sock *child,
 		       struct sk_buff *skb)
+	__releases(child)
 {
 	int ret = 0;
 	const int state = child->sk_state;
-- 
2.24.1
