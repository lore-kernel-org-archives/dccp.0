From: Richard Sailer <richard_siegfried@systemli.org>
Date: Sat, 30 May 2020 15:59:00 +0000
Subject: [PATCH] net: dccp: Add SIOCOUTQ IOCTL support (send buffer fill)
Message-Id: <20200530155900.930808-1-richard_siegfried@systemli.org>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Richard Sailer <rs@tuxedocomputers.com>

This adds support for the SIOCOUTQ IOCTL to call send buffer fill
from the DCCP socket, like UDP and TCP already have.

Regarding the used data field. DCCP uses per packet sequence numbers,
not per byte, so sequence numbers can't be used like in TCP. sk_wmem_queued
is not used by DCCP and always 0, even in test on highly congested paths.
Therefore this uses sk_wmem_alloc like in UDP.
---
 Documentation/networking/dccp.txt | 2 ++
 net/dccp/proto.c                  | 8 ++++++++
 2 files changed, 10 insertions(+)

diff --git a/Documentation/networking/dccp.txt b/Documentation/networking/dccp.txt
index 55c575fcaf17d..682ecf8288827 100644
--- a/Documentation/networking/dccp.txt
+++ b/Documentation/networking/dccp.txt
@@ -185,6 +185,8 @@ FIONREAD
 	Works as in udp(7): returns in the `int' argument pointer the size of
 	the next pending datagram in bytes, or 0 when no datagram is pending.
 
+SIOCOUTQ
+  Returns the number of data bytes in the local send queue.
 
 Other tunables
 =======
diff --git a/net/dccp/proto.c b/net/dccp/proto.c
index 4af8a98fe7846..b286346a8c626 100644
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -375,6 +375,14 @@ int dccp_ioctl(struct sock *sk, int cmd, unsigned long arg)
 		goto out;
 
 	switch (cmd) {
+	case SIOCOUTQ: {
+		/* Using sk_wmem_alloc here because sk_wmem_queued is not used by DCCP and
+     * always 0, comparably to UDP.
+		 */
+		int amount = sk_wmem_alloc_get(sk);
+		rc = put_user(amount, (int __user *)arg);
+	}
+		       break;
 	case SIOCINQ: {
 		struct sk_buff *skb;
 		unsigned long amount = 0;
-- 
2.26.2
