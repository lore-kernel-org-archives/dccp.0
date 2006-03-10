From: Arnaldo Carvalho de Melo <acme@mandriva.com>
Date: Fri, 10 Mar 2006 21:22:17 +0000
Subject: [PATCH 1/9] [SNAP]: Remove leftover unused hdr variable
Message-Id: <11420257372132-git-send-email-acme@mandriva.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>

---

 net/802/psnap.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

ad864a85e3a5ff4f063d8e415ffd44a7a249feb2
diff --git a/net/802/psnap.c b/net/802/psnap.c
index 97c95ee..270b9d2 100644
--- a/net/802/psnap.c
+++ b/net/802/psnap.c
@@ -59,7 +59,6 @@ static int snap_rcv(struct sk_buff *skb,
 	proto = find_snap_client(skb->h.raw);
 	if (proto) {
 		/* Pass the frame on. */
-		u8 *hdr = skb->data;
 		skb->h.raw  += 5;
 		skb_pull_rcsum(skb, 5);
 		rc = proto->rcvfunc(skb, dev, &snap_packet_type, orig_dev);
-- 
1.2.2.gd27d


