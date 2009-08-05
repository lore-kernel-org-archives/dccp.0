From: Wei Yongjun <yjwei@cn.fujitsu.com>
Date: Wed, 05 Aug 2009 07:44:39 +0000
Subject: [PATCH] dccp: missing destroy of percpu counter variable while unload
Message-Id: <4A793867.3030104@cn.fujitsu.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

percpu counter dccp_orphan_count is init in dccp_init() by
percpu_counter_init() while dccp module is loaded, but the
destroy of it is missing while dccp module is unloaded. We
can get the kernel WARNING about this. Reproduct by the
following commands:

  $ modprobe dccp
  $ rmmod dccp
  $ modprobe dccp

WARNING: at lib/list_debug.c:26 __list_add+0x27/0x5c()
Hardware name: VMware Virtual Platform
list_add corruption. next->prev should be prev (c080c0c4), but was (null). =
(next
=CA7188cc).
Modules linked in: dccp(+) nfsd lockd nfs_acl auth_rpcgss exportfs sunrpc
Pid: 1956, comm: modprobe Not tainted 2.6.31-rc5 #55
Call Trace:
 [<c042f8fa>] warn_slowpath_common+0x6a/0x81
 [<c053a6cb>] ? __list_add+0x27/0x5c
 [<c042f94f>] warn_slowpath_fmt+0x29/0x2c
 [<c053a6cb>] __list_add+0x27/0x5c
 [<c053c9b3>] __percpu_counter_init+0x4d/0x5d
 [<ca9c90c7>] dccp_init+0x19/0x2ed [dccp]
 [<c0401141>] do_one_initcall+0x4f/0x111
 [<ca9c90ae>] ? dccp_init+0x0/0x2ed [dccp]
 [<c06971b5>] ? notifier_call_chain+0x26/0x48
 [<c0444943>] ? __blocking_notifier_call_chain+0x45/0x51
 [<c04516f7>] sys_init_module+0xac/0x1bd
 [<c04028e4>] sysenter_do_call+0x12/0x22

Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
---
 net/dccp/proto.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/dccp/proto.c b/net/dccp/proto.c
index 3281013..1bca920 100644
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -1159,6 +1159,7 @@ static void __exit dccp_fini(void)
 	kmem_cache_destroy(dccp_hashinfo.bind_bucket_cachep);
 	dccp_ackvec_exit();
 	dccp_sysctl_exit();
+	percpu_counter_destroy(&dccp_orphan_count);
 }
=20
 module_init(dccp_init);
--=20
1.6.2.2




