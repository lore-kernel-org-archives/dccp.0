From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Wed, 26 Sep 2007 18:39:47 +0000
Subject: [PATCH 3/8] [DCCP]: Add FIXME for send_delayed_ack
Message-Id: <20070926183947.GE10932@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This adds a FIXME to signal that the function dccp_send_delayed_ack is nowhere
used in the entire DCCP/CCID code.

Using a delayed Ack timer is suggested in 11.3 of RFC 4340, but it has also
rather subtle implications for the Ack-Ratio-accounting.

CCID2 does not use this (maybe it should).

I think leaving the function in is good, in case someone wants to implement
this.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Signed-off-by: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
---
 net/dccp/dccp.h   |    1 -
 net/dccp/output.c |    1 +
 2 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/dccp/dccp.h b/net/dccp/dccp.h
index bd4645b..f62eeb3 100644
--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -209,7 +209,6 @@ extern void dccp_v4_send_check(struct sock *sk, int len, struct sk_buff *skb);
 extern int  dccp_retransmit_skb(struct sock *sk, struct sk_buff *skb);
 
 extern void dccp_send_ack(struct sock *sk);
-extern void dccp_send_delayed_ack(struct sock *sk);
 extern void dccp_reqsk_send_ack(struct sk_buff *sk, struct request_sock *rsk);
 
 extern void dccp_send_sync(struct sock *sk, const u64 seq,
diff --git a/net/dccp/output.c b/net/dccp/output.c
index 6e23d5b..d0c9ec6 100644
--- a/net/dccp/output.c
+++ b/net/dccp/output.c
@@ -477,6 +477,7 @@ void dccp_send_ack(struct sock *sk)
 
 EXPORT_SYMBOL_GPL(dccp_send_ack);
 
+/* FIXME: Is this still necessary (11.3) - currently nowhere used by DCCP. */
 void dccp_send_delayed_ack(struct sock *sk)
 {
 	struct inet_connection_sock *icsk = inet_csk(sk);
-- 
1.5.2.2

