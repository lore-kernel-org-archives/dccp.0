From: Arnaldo Carvalho de Melo <acme@mandriva.com>
Date: Sat, 25 Feb 2006 21:16:12 +0000
Subject: [PATCH 1/3] [DCCP] ipv4: make struct dccp_v4_prot static
Message-Id: <11409021722029-git-send-email-acme@mandriva.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

There's no reason for struct dccp_v4_prot being global.

Signed-off-by: Adrian Bunk <bunk@stusta.de
Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>

---

 net/dccp/ipv4.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

16106bb9b047c6a60190f11a674d804bdf1f8320
diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index 033c3ab..3fe958e 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -1022,7 +1022,7 @@ static struct timewait_sock_ops dccp_tim
 	.twsk_obj_size	= sizeof(struct inet_timewait_sock),
 };
 
-struct proto dccp_v4_prot = {
+static struct proto dccp_v4_prot = {
 	.name			= "DCCP",
 	.owner			= THIS_MODULE,
 	.close			= dccp_close,
-- 
1.2.2.gd27d


