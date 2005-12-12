From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Mon, 12 Dec 2005 01:18:57 +0000
Subject: [PATCH 5/5][TCPv6]: Fix skb leak
Message-Id: <39e6f6c70512111718w18e9704ekf04a33bf32058861@mail.gmail.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----=_Part_3217_12016568.1134350337026"
List-Id: <dccp.vger.kernel.org>
To: dccp@vger.kernel.org

------=_Part_3217_12016568.1134350337026
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Hi David,

  Please consider pulling from:

master.kernel.org:/pub/scm/linux/kernel/git/acme/net-2.6.16.git

Best Regards,

- Arnaldo

------=_Part_3217_12016568.1134350337026
Content-Type: text/x-patch; name=5.patch; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="5.patch"

tree 402c2b51d32d31f999fed91365c509d1fbd355c7
parent 9b0c0171dae84125f43b6ca80f9108768863df97
author Arnaldo Carvalho de Melo <acme@mandriva.com> 1134349890 -0200
committer Arnaldo Carvalho de Melo <acme@mandriva.com> 1134349890 -0200

[TCPv6]: Fix skb leak

Spotted by Francois Romieu, thanks! The DCCP case was fixed as
well in another patch.

Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>

------------------------------------------------------------------------------

 tcp_ipv6.c |   19 +++++++++----------
 1 file changed, 9 insertions(+), 10 deletions(-)

------------------------------------------------------------------------------

diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 7a077de..514b57b 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -779,13 +779,12 @@ static void tcp_v6_send_reset(struct sk_
 	/* sk = NULL, but it is safe for now. RST socket required. */
 	if (!ip6_dst_lookup(NULL, &buff->dst, &fl)) {
 
-		if ((xfrm_lookup(&buff->dst, &fl, NULL, 0)) < 0)
+		if (xfrm_lookup(&buff->dst, &fl, NULL, 0) >= 0) {
+			ip6_xmit(NULL, buff, &fl, NULL, 0);
+			TCP_INC_STATS_BH(TCP_MIB_OUTSEGS);
+			TCP_INC_STATS_BH(TCP_MIB_OUTRSTS);
 			return;
-
-		ip6_xmit(NULL, buff, &fl, NULL, 0);
-		TCP_INC_STATS_BH(TCP_MIB_OUTSEGS);
-		TCP_INC_STATS_BH(TCP_MIB_OUTRSTS);
-		return;
+		}
 	}
 
 	kfree_skb(buff);
@@ -844,11 +843,11 @@ static void tcp_v6_send_ack(struct sk_bu
 	fl.fl_ip_sport = t1->source;
 
 	if (!ip6_dst_lookup(NULL, &buff->dst, &fl)) {
-		if ((xfrm_lookup(&buff->dst, &fl, NULL, 0)) < 0)
+		if (xfrm_lookup(&buff->dst, &fl, NULL, 0) >= 0) {
+			ip6_xmit(NULL, buff, &fl, NULL, 0);
+			TCP_INC_STATS_BH(TCP_MIB_OUTSEGS);
 			return;
-		ip6_xmit(NULL, buff, &fl, NULL, 0);
-		TCP_INC_STATS_BH(TCP_MIB_OUTSEGS);
-		return;
+		}
 	}
 
 	kfree_skb(buff);

------=_Part_3217_12016568.1134350337026--
