From: YueHaibing <yuehaibing@huawei.com>
Date: Fri, 24 Apr 2020 13:13:34 +0000
Subject: [PATCH net-next] dccp: remove unused inline function dccp_set_seqno
Message-Id: <20200424131334.37532-1-yuehaibing@huawei.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

There's no callers in-tree since commit 792b48780e8b ("dccp: Implement
both feature-local and feature-remote Sequence Window feature")

Signed-off-by: YueHaibing <yuehaibing@huawei.com>
---
 net/dccp/dccp.h | 5 -----
 1 file changed, 5 deletions(-)

diff --git a/net/dccp/dccp.h b/net/dccp/dccp.h
index 9c3b27c257bb..7dce4f6c7025 100644
--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -108,11 +108,6 @@ extern int  sysctl_dccp_sync_ratelimit;
 #define ADD48(a, b)	 (((a) + (b)) & UINT48_MAX)
 #define SUB48(a, b)	 ADD48((a), COMPLEMENT48(b))
 
-static inline void dccp_set_seqno(u64 *seqno, u64 value)
-{
-	*seqno = value & UINT48_MAX;
-}
-
 static inline void dccp_inc_seqno(u64 *seqno)
 {
 	*seqno = ADD48(*seqno, 1);
-- 
2.17.1

