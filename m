From: Arnaldo Carvalho de Melo <acme@mandriva.com>
Date: Fri, 10 Mar 2006 21:22:17 +0000
Subject: [PATCH 4/9] [SECURITY] getpeersec: Fix build breakage
Message-Id: <11420257372609-git-send-email-acme@mandriva.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

a265d6baa827bd6411d1c5566b9e3596fec88a91 removes dummy_socket_getpeersec,
replacing it with two new functions, but still references the removed function
in the security_fixup_ops table, fix it by doing the replacement operation in
the fixup table too.

Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>

---

 security/dummy.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

3cf2f09e8adda7b2d1d9a2bbd05b42a5608044f4
diff --git a/security/dummy.c b/security/dummy.c
index a326d6e..a678f09 100644
--- a/security/dummy.c
+++ b/security/dummy.c
@@ -1008,7 +1008,8 @@ void security_fixup_ops (struct security
 	set_to_dummy_if_null(ops, socket_getsockopt);
 	set_to_dummy_if_null(ops, socket_shutdown);
 	set_to_dummy_if_null(ops, socket_sock_rcv_skb);
-	set_to_dummy_if_null(ops, socket_getpeersec);
+	set_to_dummy_if_null(ops, socket_getpeersec_stream);
+	set_to_dummy_if_null(ops, socket_getpeersec_dgram);
 	set_to_dummy_if_null(ops, sk_alloc_security);
 	set_to_dummy_if_null(ops, sk_free_security);
 	set_to_dummy_if_null(ops, sk_getsid);
-- 
1.2.2.gd27d


