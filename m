From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Date: Tue, 21 Feb 2017 11:27:40 +0000
Subject: [PATCH] net/dccp: fix use after free in tw_timer_handler()
Message-Id: <20170221112740.661-1-aryabinin@virtuozzo.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

DCCP doesn't purge timewait sockets on network namespace shutdown.
So, after net namespace destroyed we could still have an active timer
which will trigger use after free in tw_timer_handler():

    BUG: KASAN: use-after-free in tw_timer_handler+0x4a/0xa0 at addr ffff88010e0d1e10
    Read of size 8 by task swapper/1/0
    Call Trace:
     __asan_load8+0x54/0x90
     tw_timer_handler+0x4a/0xa0
     call_timer_fn+0x127/0x480
     expire_timers+0x1db/0x2e0
     run_timer_softirq+0x12f/0x2a0
     __do_softirq+0x105/0x5b4
     irq_exit+0xdd/0xf0
     smp_apic_timer_interrupt+0x57/0x70
     apic_timer_interrupt+0x90/0xa0

    Object at ffff88010e0d1bc0, in cache net_namespace size: 6848
    Allocated:
     save_stack_trace+0x1b/0x20
     kasan_kmalloc+0xee/0x180
     kasan_slab_alloc+0x12/0x20
     kmem_cache_alloc+0x134/0x310
     copy_net_ns+0x8d/0x280
     create_new_namespaces+0x23f/0x340
     unshare_nsproxy_namespaces+0x75/0xf0
     SyS_unshare+0x299/0x4f0
     entry_SYSCALL_64_fastpath+0x18/0xad
    Freed:
     save_stack_trace+0x1b/0x20
     kasan_slab_free+0xae/0x180
     kmem_cache_free+0xb4/0x350
     net_drop_ns+0x3f/0x50
     cleanup_net+0x3df/0x450
     process_one_work+0x419/0xbb0
     worker_thread+0x92/0x850
     kthread+0x192/0x1e0
     ret_from_fork+0x2e/0x40

Add .exit_batch hook to dccp_v4_ops()/dccp_v6_ops() which will purge
timewait sockets on net namespace destruction and prevent above issue.

Reported-by: Dmitry Vyukov <dvyukov@google.com>
Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
---
 net/dccp/ipv4.c | 6 ++++++
 net/dccp/ipv6.c | 6 ++++++
 2 files changed, 12 insertions(+)

diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index d859a5c..da7cb16 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -1018,9 +1018,15 @@ static void __net_exit dccp_v4_exit_net(struct net *net)
 	inet_ctl_sock_destroy(net->dccp.v4_ctl_sk);
 }
 
+static void __net_exit dccp_v4_exit_batch(struct list_head *net_exit_list)
+{
+	inet_twsk_purge(&dccp_hashinfo, &dccp_death_row, AF_INET);
+}
+
 static struct pernet_operations dccp_v4_ops = {
 	.init	= dccp_v4_init_net,
 	.exit	= dccp_v4_exit_net,
+	.exit_batch = dccp_v4_exit_batch,
 };
 
 static int __init dccp_v4_init(void)
diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index c4e879c..f3d8f92 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -1077,9 +1077,15 @@ static void __net_exit dccp_v6_exit_net(struct net *net)
 	inet_ctl_sock_destroy(net->dccp.v6_ctl_sk);
 }
 
+static void __net_exit dccp_v6_exit_batch(struct list_head *net_exit_list)
+{
+	inet_twsk_purge(&dccp_hashinfo, &dccp_death_row, AF_INET6);
+}
+
 static struct pernet_operations dccp_v6_ops = {
 	.init   = dccp_v6_init_net,
 	.exit   = dccp_v6_exit_net,
+	.exit_batch = dccp_v6_exit_batch,
 };
 
 static int __init dccp_v6_init(void)
-- 
2.10.2

