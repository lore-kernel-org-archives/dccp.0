From: Arnaldo Carvalho de Melo <acme@mandriva.com>
Date: Thu, 09 Mar 2006 03:08:09 +0000
Subject: [PATCH 4/5] [DCCP]: Remove leftover dccp_send_response prototype
Message-Id: <11418736892593-git-send-email-acme@mandriva.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>

---

 net/dccp/dccp.h |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

13e1f7a3d97bbe362f610e50bc5998fd70e791c2
diff --git a/net/dccp/dccp.h b/net/dccp/dccp.h
index d57d213..7f5be08 100644
--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -118,7 +118,6 @@ DECLARE_SNMP_STAT(struct dccp_mib, dccp_
 
 extern int  dccp_retransmit_skb(struct sock *sk, struct sk_buff *skb);
 
-extern int dccp_send_response(struct sock *sk);
 extern void dccp_send_ack(struct sock *sk);
 extern void dccp_send_delayed_ack(struct sock *sk);
 extern void dccp_send_sync(struct sock *sk, const u64 seq,
-- 
1.2.2.gd27d


