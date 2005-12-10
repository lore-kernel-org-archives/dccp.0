From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Sat, 10 Dec 2005 19:29:32 +0000
Subject: [PATCH 6/6][IPV6]: Export ipv6_opt_accepted
Message-Id: <39e6f6c70512101129sae17bb0o69bea0631e0454cc@mail.gmail.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----=_Part_22639_15804733.1134242972042"
List-Id: <dccp.vger.kernel.org>
To: dccp@vger.kernel.org

------=_Part_22639_15804733.1134242972042
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Hi David,

    Please consider pulling from:

master.kernel.org:/pub/scm/linux/kernel/git/acme/net-2.6.16.git

Best Regards,

- Arnaldo

------=_Part_22639_15804733.1134242972042
Content-Type: text/x-patch; name=6.patch; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="6.patch"

tree a47e827887f6af53382373476e58a3dde8418c22
parent 273cab383a9bf4c564e11f0fc2c5bd07f394d76c
author Arnaldo Carvalho de Melo <acme@mandriva.com> 1134242431 -0200
committer Arnaldo Carvalho de Melo <acme@mandriva.com> 1134242431 -0200

[IPV6]: Export ipv6_opt_accepted

It was already non-TCP specific, will be used by DCCPv6.

Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>

------------------------------------------------------------------------------

 include/net/ipv6.h  |    2 ++
 net/ipv6/af_inet6.c |   21 +++++++++++++++++++++
 net/ipv6/tcp_ipv6.c |   16 ----------------
 3 files changed, 23 insertions(+), 16 deletions(-)

------------------------------------------------------------------------------

diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index 0a2ad51..8513761 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -240,6 +240,8 @@ extern struct ipv6_txoptions *	ipv6_rene
 struct ipv6_txoptions *ipv6_fixup_options(struct ipv6_txoptions *opt_space,
 					  struct ipv6_txoptions *opt);
 
+extern int ipv6_opt_accepted(struct sock *sk, struct sk_buff *skb);
+
 extern int ip6_frag_nqueues;
 extern atomic_t ip6_frag_mem;
 
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index 23675ef..bf17aab 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -663,6 +663,27 @@ int inet6_sk_rebuild_header(struct sock 
 
 EXPORT_SYMBOL_GPL(inet6_sk_rebuild_header);
 
+int ipv6_opt_accepted(struct sock *sk, struct sk_buff *skb)
+{
+	struct ipv6_pinfo *np = inet6_sk(sk);
+	struct inet6_skb_parm *opt = IP6CB(skb);
+
+	if (np->rxopt.all) {
+		if ((opt->hop && (np->rxopt.bits.hopopts ||
+				  np->rxopt.bits.ohopopts)) ||
+		    ((IPV6_FLOWINFO_MASK & *(u32*)skb->nh.raw) &&
+		     np->rxopt.bits.rxflow) ||
+		    (opt->srcrt && (np->rxopt.bits.srcrt ||
+		     np->rxopt.bits.osrcrt)) ||
+		    ((opt->dst1 || opt->dst0) &&
+		     (np->rxopt.bits.dstopts || np->rxopt.bits.odstopts)))
+			return 1;
+	}
+	return 0;
+}
+
+EXPORT_SYMBOL_GPL(ipv6_opt_accepted);
+
 int
 snmp6_mib_init(void *ptr[2], size_t mibsize, size_t mibalign)
 {
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 92d6924..4c4983c 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -711,22 +711,6 @@ static struct request_sock_ops tcp6_requ
 	.send_reset	=	tcp_v6_send_reset
 };
 
-static int ipv6_opt_accepted(struct sock *sk, struct sk_buff *skb)
-{
-	struct ipv6_pinfo *np = inet6_sk(sk);
-	struct inet6_skb_parm *opt = IP6CB(skb);
-
-	if (np->rxopt.all) {
-		if ((opt->hop && (np->rxopt.bits.hopopts || np->rxopt.bits.ohopopts)) ||
-		    ((IPV6_FLOWINFO_MASK & *(u32*)skb->nh.raw) && np->rxopt.bits.rxflow) ||
-		    (opt->srcrt && (np->rxopt.bits.srcrt || np->rxopt.bits.osrcrt)) ||
-		    ((opt->dst1 || opt->dst0) && (np->rxopt.bits.dstopts || np->rxopt.bits.odstopts)))
-			return 1;
-	}
-	return 0;
-}
-
-
 static void tcp_v6_send_check(struct sock *sk, int len, struct sk_buff *skb)
 {
 	struct ipv6_pinfo *np = inet6_sk(sk);

------=_Part_22639_15804733.1134242972042--
