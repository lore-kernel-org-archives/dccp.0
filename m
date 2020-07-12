From: Richard Sailer <richard_siegfried@systemli.org>
Date: Sun, 12 Jul 2020 22:55:20 +0000
Subject: [PATCH net-next v4] net: dccp: Add SIOCOUTQ IOCTL support (send buffer fill)
Message-Id: <20200712225520.269542-1-richard_siegfried@systemli.org>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This adds support for the SIOCOUTQ IOCTL to get the send buffer fill
of a DCCP socket, like UDP and TCP sockets already have.

Regarding the used data field: DCCP uses per packet sequence numbers,
not per byte, so sequence numbers can't be used like in TCP. sk_wmem_queued
is not used by DCCP and always 0, even in test on highly congested paths.
Therefore this uses sk_wmem_alloc like in UDP.

Signed-off-by: Richard Sailer <richard_siegfried@systemli.org>
---
v4: Update to apply to .rst doc file
---
 Documentation/networking/dccp.rst | 2 ++
 net/dccp/proto.c                  | 8 ++++++++
 2 files changed, 10 insertions(+)

diff --git a/Documentation/networking/dccp.rst b/Documentation/networking/dccp.rst
index dde16be044562..74659da107f6b 100644
--- a/Documentation/networking/dccp.rst
+++ b/Documentation/networking/dccp.rst
@@ -192,6 +192,8 @@ FIONREAD
 	Works as in udp(7): returns in the ``int`` argument pointer the size of
 	the next pending datagram in bytes, or 0 when no datagram is pending.
 
+SIOCOUTQ
+  Returns the number of data bytes in the local send queue.
 
 Other tunables
 =======
diff --git a/net/dccp/proto.c b/net/dccp/proto.c
index c13b6609474b6..dab74e8a8a69b 100644
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -375,6 +375,14 @@ int dccp_ioctl(struct sock *sk, int cmd, unsigned long arg)
 		goto out;
 
 	switch (cmd) {
+	case SIOCOUTQ: {
+		/* Using sk_wmem_alloc here because sk_wmem_queued is not used by DCCP and
+		 * always 0, comparably to UDP.
+		 */
+		int amount = sk_wmem_alloc_get(sk);
+		rc = put_user(amount, (int __user *)arg);
+	}
+		break;
 	case SIOCINQ: {
 		struct sk_buff *skb;
 		unsigned long amount = 0;
-- 
2.27.0
