From: Richard Sailer <richard_siegfried@systemli.org>
Date: Mon, 20 Jul 2020 16:06:14 +0000
Subject: [PATCH net-next v5] net: dccp: Add SIOCOUTQ IOCTL support (send buffer fill)
Message-Id: <20200720160614.117090-1-richard_siegfried@systemli.org>
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
v5: More infos into dccp.rst, +empty line after declarations
---
 Documentation/networking/dccp.rst | 3 +++
 net/dccp/proto.c                  | 9 +++++++++
 2 files changed, 12 insertions(+)

diff --git a/Documentation/networking/dccp.rst b/Documentation/networking/dccp.rst
index dde16be044562..91e5c33ba3ff5 100644
--- a/Documentation/networking/dccp.rst
+++ b/Documentation/networking/dccp.rst
@@ -192,6 +192,9 @@ FIONREAD
 	Works as in udp(7): returns in the ``int`` argument pointer the size of
 	the next pending datagram in bytes, or 0 when no datagram is pending.
 
+SIOCOUTQ
+	Returns the number of unsent data bytes in the socket send queue as ``int``
+	into the buffer specified by the argument pointer.
 
 Other tunables
 =======
diff --git a/net/dccp/proto.c b/net/dccp/proto.c
index fd92d3fe321f0..9e453611107f1 100644
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -375,6 +375,15 @@ int dccp_ioctl(struct sock *sk, int cmd, unsigned long arg)
 		goto out;
 
 	switch (cmd) {
+	case SIOCOUTQ: {
+		int amount = sk_wmem_alloc_get(sk);
+		/* Using sk_wmem_alloc here because sk_wmem_queued is not used by DCCP and
+		 * always 0, comparably to UDP.
+		 */
+
+		rc = put_user(amount, (int __user *)arg);
+	}
+		break;
 	case SIOCINQ: {
 		struct sk_buff *skb;
 		unsigned long amount = 0;
-- 
2.27.0
