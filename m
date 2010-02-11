From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 11 Feb 2010 06:26:18 +0000
Subject: [PATCH 1/2] dccp: support for passing MSG_TRUNC
Message-Id: <1265869579-5829-2-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

DCCP is datagram-oriented but lacks UDP's support for MSG_TRUNC as defined in
recvmsg(2)/recv(2). Hence the following 'Hello world\0' receiver

  len = recv(fd, buf, 10, MSG_PEEK | MSG_TRUNC);

wrongly (always) returns 10, while in UDP it returns 12 as expected.
This patch adds the missing MSG_TRUNC support to recvmsg().

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/proto.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -835,6 +835,8 @@ verify_sock_status:
 			len = -EFAULT;
 			break;
 		}
+		if (flags & MSG_TRUNC)
+			len = skb->len;
 	found_fin_ok:
 		if (!(flags & MSG_PEEK))
 			sk_eat_skb(sk, skb, 0);
