From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Wed, 04 Jan 2006 04:13:09 +0000
Subject: [PATCH 3/4][TCP]: syn_flood_warning is only needed if CONFIG_SYN_COOKIES is selected
Message-Id: <39e6f6c70601032013m36fa395age319ce53976dedd8@mail.gmail.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----=_Part_37849_15737938.1136347989267"
List-Id: <dccp.vger.kernel.org>
To: dccp@vger.kernel.org

------=_Part_37849_15737938.1136347989267
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Hi David,

 Please consider pulling from:

master.kernel.org:/pub/scm/linux/kernel/git/acme/net-2.6.git

Best Regards,

- Arnaldo

------=_Part_37849_15737938.1136347989267
Content-Type: text/x-patch; name=3.patch; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="3.patch"

tree 31a9a37e00b690edf3e54d61393e364f203549c3
parent e4dfd449c80a41bb615b23d0fc198ba08360a1f8
author Arnaldo Carvalho de Melo <acme@mandriva.com> 1136347086 -0200
committer Arnaldo Carvalho de Melo <acme@mandriva.com> 1136347086 -0200

[TCP]: syn_flood_warning is only needed if CONFIG_SYN_COOKIES is selected

  CC      net/ipv4/tcp_ipv4.o
  /pub/scm/linux/kernel/git/acme/net-2.6/net/ipv4/tcp_ipv4.c:665: warning:
  'syn_flood_warning' defined but not used

Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>

------------------------------------------------------------------------------

 tcp_ipv4.c |    2 ++
 1 file changed, 2 insertions(+)

------------------------------------------------------------------------------

diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 5c70493..e9f83e5 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -661,6 +661,7 @@ static void tcp_v4_reqsk_destructor(stru
 	kfree(inet_rsk(req)->opt);
 }
 
+#ifdef CONFIG_SYN_COOKIES
 static void syn_flood_warning(struct sk_buff *skb)
 {
 	static unsigned long warntime;
@@ -672,6 +673,7 @@ static void syn_flood_warning(struct sk_
 		       ntohs(skb->h.th->dest));
 	}
 }
+#endif
 
 /*
  * Save and compile IPv4 options into the request_sock if needed.


------=_Part_37849_15737938.1136347989267--
