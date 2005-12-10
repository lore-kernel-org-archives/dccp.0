From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Sat, 10 Dec 2005 19:28:18 +0000
Subject: [PATCH 3/6][IPV6]: Export some symbols for DCCPv6
Message-Id: <39e6f6c70512101128k30af1c14he3b72fcfc4c60447@mail.gmail.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----=_Part_22591_2200513.1134242898629"
List-Id: <dccp.vger.kernel.org>
To: dccp@vger.kernel.org

------=_Part_22591_2200513.1134242898629
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Hi David,

    Please consider pulling from:

master.kernel.org:/pub/scm/linux/kernel/git/acme/net-2.6.16.git

Best Regards,

- Arnaldo

------=_Part_22591_2200513.1134242898629
Content-Type: text/x-patch; name=3.patch; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="3.patch"

tree cf4a4fc231acd6967b29a1a6002719ea36288063
parent 997f378c6a3d3b034717ad814da0517ab58c457e
author Arnaldo Carvalho de Melo <acme@mandriva.com> 1134240390 -0200
committer Arnaldo Carvalho de Melo <acme@mandriva.com> 1134240390 -0200

[IPV6]: Export some symbols for DCCPv6

Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>

------------------------------------------------------------------------------

 af_inet6.c      |    2 ++
 exthdrs.c       |    4 ++++
 ip6_flowlabel.c |    2 ++
 ip6_output.c    |    2 ++
 4 files changed, 10 insertions(+)

------------------------------------------------------------------------------

diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index fd040e9..23675ef 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -389,6 +389,8 @@ int inet6_destroy_sock(struct sock *sk)
 	return 0;
 }
 
+EXPORT_SYMBOL_GPL(inet6_destroy_sock);
+
 /*
  *	This does both peername and sockname.
  */
diff --git a/net/ipv6/exthdrs.c b/net/ipv6/exthdrs.c
index be6faf3..113374d 100644
--- a/net/ipv6/exthdrs.c
+++ b/net/ipv6/exthdrs.c
@@ -413,6 +413,8 @@ ipv6_invert_rthdr(struct sock *sk, struc
 	return opt;
 }
 
+EXPORT_SYMBOL_GPL(ipv6_invert_rthdr);
+
 /**********************************
   Hop-by-hop options.
  **********************************/
@@ -579,6 +581,8 @@ ipv6_dup_options(struct sock *sk, struct
 	return opt2;
 }
 
+EXPORT_SYMBOL_GPL(ipv6_dup_options);
+
 static int ipv6_renew_option(void *ohdr,
 			     struct ipv6_opt_hdr __user *newopt, int newoptlen,
 			     int inherit,
diff --git a/net/ipv6/ip6_flowlabel.c b/net/ipv6/ip6_flowlabel.c
index 1cf0276..89d12b4 100644
--- a/net/ipv6/ip6_flowlabel.c
+++ b/net/ipv6/ip6_flowlabel.c
@@ -200,6 +200,8 @@ struct ip6_flowlabel * fl6_sock_lookup(s
 	return NULL;
 }
 
+EXPORT_SYMBOL_GPL(fl6_sock_lookup);
+
 void fl6_free_socklist(struct sock *sk)
 {
 	struct ipv6_pinfo *np = inet6_sk(sk);
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 8523c76..b4c4beb 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -775,6 +775,8 @@ out_err_release:
 	return err;
 }
 
+EXPORT_SYMBOL_GPL(ip6_dst_lookup);
+
 static inline int ip6_ufo_append_data(struct sock *sk,
 			int getfrag(void *from, char *to, int offset, int len,
 			int odd, struct sk_buff *skb),

------=_Part_22591_2200513.1134242898629--
