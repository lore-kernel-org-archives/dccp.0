From: Shan Wei <shanwei@cn.fujitsu.com>
Date: Thu, 20 Jan 2011 09:12:54 +0000
Subject: [PATCH clean-up] dccp: clean up unused DCCP_STATE_MASK definition
Message-Id: <4D37FC96.9000407@cn.fujitsu.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Remove unused DCCP_STATE_MASK macro.


Signed-off-by: Shan Wei <shanwei@cn.fujitsu.com>
---
 include/linux/dccp.h |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/include/linux/dccp.h b/include/linux/dccp.h
index 010e2d8..d638e85 100644
--- a/include/linux/dccp.h
+++ b/include/linux/dccp.h
@@ -279,8 +279,6 @@ enum dccp_state {
 	DCCP_MAX_STATES
 };
 
-#define DCCP_STATE_MASK 0x1f
-
 enum {
 	DCCPF_OPEN	      = TCPF_ESTABLISHED,
 	DCCPF_REQUESTING      = TCPF_SYN_SENT,
-- 
1.6.3.3
