From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Wed, 04 Jan 2006 04:13:14 +0000
Subject: [PATCH 4/4][IPVS]: Add missing include <linux/net.h>
Message-Id: <39e6f6c70601032013o55f670e4l851e05c60fc3b2c1@mail.gmail.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----=_Part_37853_18705395.1136347994106"
List-Id: <dccp.vger.kernel.org>
To: dccp@vger.kernel.org

------=_Part_37853_18705395.1136347994106
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Hi David,

 Please consider pulling from:

master.kernel.org:/pub/scm/linux/kernel/git/acme/net-2.6.git

Best Regards,

- Arnaldo

------=_Part_37853_18705395.1136347994106
Content-Type: text/x-patch; name=4.patch; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="4.patch"

tree 322e5309316ce619cb354c517186b35019026cbc
parent 80e40daa4797a156781d1594642b654eb1c461df
author Arnaldo Carvalho de Melo <acme@mandriva.com> 1136347340 -0200
committer Arnaldo Carvalho de Melo <acme@mandriva.com> 1136347340 -0200

[IPVS]: Add missing include <linux/net.h>

  CC [M]  net/ipv4/ipvs/ip_vs_conn.o
  /pub/scm/linux/kernel/git/acme/net-2.6/net/ipv4/ipvs/ip_vs_conn.c: In
  function 'ip_vs_conn_new':
  /pub/scm/linux/kernel/git/acme/net-2.6/net/ipv4/ipvs/ip_vs_conn.c:606:
  warning: implicit declaration of function 'net_ratelimit'
  /pub/scm/linux/kernel/git/acme/net-2.6/net/ipv4/ipvs/ip_vs_conn.c: In
  function 'ip_vs_random_dropentry':
  /pub/scm/linux/kernel/git/acme/net-2.6/net/ipv4/ipvs/ip_vs_conn.c:810:
  warning: implicit declaration of function 'net_random'

Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>

------------------------------------------------------------------------------

 ip_vs_conn.c |    1 +
 1 file changed, 1 insertion(+)

------------------------------------------------------------------------------

diff --git a/net/ipv4/ipvs/ip_vs_conn.c b/net/ipv4/ipvs/ip_vs_conn.c
index ed5bd56..81d9035 100644
--- a/net/ipv4/ipvs/ip_vs_conn.c
+++ b/net/ipv4/ipvs/ip_vs_conn.c
@@ -25,6 +25,7 @@
  */
 
 #include <linux/in.h>
+#include <linux/net.h>
 #include <linux/kernel.h>
 #include <linux/module.h>
 #include <linux/vmalloc.h>


------=_Part_37853_18705395.1136347994106--
