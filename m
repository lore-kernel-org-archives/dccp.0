From: Dmitry Vyukov <dvyukov@google.com>
Date: Tue, 05 Jul 2016 11:59:37 +0000
Subject: dccp: potential deadlock in dccp_v4_ctl_send_reset
Message-Id: <CACT4Y+YX6mx3MroiLGVGTg35y2V0QBHHQecrhQV9bnpEPfDK4Q@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hello,

While running syzkaller fuzzer I've got the following deadlock report:

================[ INFO: inconsistent lock state ]
4.7.0-rc5+ #28 Not tainted
---------------------------------
inconsistent {IN-SOFTIRQ-W} -> {SOFTIRQ-ON-W} usage.
syz-executor/354 [HC0[0]:SC0[0]:HE1:SE1] takes:
 (slock-AF_INET){+.?...}, at: [<     inline     >] spin_lock
include/linux/spinlock.h:302
 (slock-AF_INET){+.?...}, at: [<ffffffff864831b1>]
dccp_v4_ctl_send_reset+0xac1/0x10d0 net/dccp/ipv4.c:530
{IN-SOFTIRQ-W} state was registered at:
  [<     inline     >] mark_irqflags kernel/locking/lockdep.c:2915
  [<ffffffff814791ec>] __lock_acquire+0xb5c/0x2fb0 kernel/locking/lockdep.c:3287
  [<ffffffff8147c293>] lock_acquire+0x1e3/0x460 kernel/locking/lockdep.c:3741
  [<     inline     >] __raw_spin_lock include/linux/spinlock_api_smp.h:144
  [<ffffffff86a93f83>] _raw_spin_lock+0x33/0x50 kernel/locking/spinlock.c:151
  [<     inline     >] spin_lock include/linux/spinlock.h:302
  [<ffffffff85cf22a5>] udp_queue_rcv_skb+0x4d5/0x18d0 net/ipv4/udp.c:1597
  [<ffffffff85cf3d72>] __udp4_lib_rcv+0x6d2/0x3270 net/ipv4/udp.c:1770
  [<ffffffff85cf78c1>] udp_rcv+0x21/0x30 net/ipv4/udp.c:1962
  [<ffffffff85c1de10>] ip_local_deliver_finish+0x2b0/0xa30
net/ipv4/ip_input.c:216
  [<     inline     >] NF_HOOK_THRESH include/linux/netfilter.h:219
  [<     inline     >] NF_HOOK include/linux/netfilter.h:242
  [<ffffffff85c1ec82>] ip_local_deliver+0x1b2/0x350 net/ipv4/ip_input.c:257
  [<     inline     >] dst_input include/net/dst.h:507
  [<ffffffff85c1c73d>] ip_rcv_finish+0x6fd/0x1b20 net/ipv4/ip_input.c:395
  [<     inline     >] NF_HOOK_THRESH include/linux/netfilter.h:219
  [<     inline     >] NF_HOOK include/linux/netfilter.h:242
  [<ffffffff85c1f7e9>] ip_rcv+0x9c9/0x1150 net/ipv4/ip_input.c:486
  [<ffffffff8590f5ee>] __netif_receive_skb_core+0x180e/0x28b0
net/core/dev.c:4205
  [<ffffffff859106ba>] __netif_receive_skb+0x2a/0x170 net/core/dev.c:4243
  [<ffffffff85913545>] netif_receive_skb_internal+0x1b5/0x390
net/core/dev.c:4271
  [<     inline     >] napi_skb_finish net/core/dev.c:4599
  [<ffffffff8591818e>] napi_gro_receive+0x2de/0x500 net/core/dev.c:4631
  [<ffffffff83ed3f73>] e1000_clean_rx_irq+0x4e3/0x1160
drivers/net/ethernet/intel/e1000e/netdev.c:1028
  [<ffffffff83ed5a46>] e1000_clean+0xa16/0x24e0
drivers/net/ethernet/intel/e1000/e1000_main.c:3836
  [<     inline     >] napi_poll net/core/dev.c:5135
  [<ffffffff8591560d>] net_rx_action+0x7ed/0xf10 net/core/dev.c:5200
  [<ffffffff86a97ebc>] __do_softirq+0x25c/0xa50 kernel/softirq.c:273
  [<     inline     >] invoke_softirq kernel/softirq.c:350
  [<ffffffff81381cef>] irq_exit+0x18f/0x1d0 kernel/softirq.c:391
  [<     inline     >] exiting_irq ./arch/x86/include/asm/apic.h:658
  [<ffffffff86a976fb>] smp_apic_timer_interrupt+0x7b/0xa0
arch/x86/kernel/apic/apic.c:932
  [<ffffffff86a95a6c>] apic_timer_interrupt+0x8c/0xa0
arch/x86/entry/entry_64.S:451
  [<ffffffff83729a6b>] class_dev_iter_next+0x8b/0xd0 drivers/base/class.c:324
  [<ffffffff8372a761>] class_find_device+0x101/0x1c0 drivers/base/class.c:428
  [<     inline     >] tty_get_device drivers/tty/tty_io.c:3134
  [<ffffffff83105a56>] alloc_tty_struct+0x5f6/0x840 drivers/tty/tty_io.c:3178
  [<ffffffff83105d18>] tty_init_dev+0x78/0x4b0 drivers/tty/tty_io.c:1528
  [<ffffffff83121053>] ptmx_open+0xf3/0x310 drivers/tty/pty.c:753
  [<ffffffff8181aa1e>] chrdev_open+0x22e/0x4c0 fs/char_dev.c:392
  [<ffffffff81806218>] do_dentry_open+0x698/0xca0 fs/open.c:736
  [<ffffffff818097cf>] vfs_open+0x10f/0x210 fs/open.c:849
  [<     inline     >] do_last fs/namei.c:3360
  [<ffffffff8183e999>] path_openat+0x12f9/0x2a80 fs/namei.c:3483
  [<ffffffff8184372c>] do_filp_open+0x18c/0x250 fs/namei.c:3518
  [<ffffffff81809fcc>] do_sys_open+0x1fc/0x420 fs/open.c:1016
  [<     inline     >] SYSC_open fs/open.c:1034
  [<ffffffff8180a21d>] SyS_open+0x2d/0x40 fs/open.c:1029
  [<ffffffff86a94e00>] entry_SYSCALL_64_fastpath+0x23/0xc1
arch/x86/entry/entry_64.S:207
irq event stamp: 201
hardirqs last  enabled at (201): [<     inline     >]
__raw_spin_unlock_irqrestore include/linux/spinlock_api_smp.h:162
hardirqs last  enabled at (201): [<ffffffff86a94b51>]
_raw_spin_unlock_irqrestore+0x31/0xc0 kernel/locking/spinlock.c:191
hardirqs last disabled at (200): [<     inline     >]
__raw_spin_lock_irqsave include/linux/spinlock_api_smp.h:110
hardirqs last disabled at (200): [<ffffffff86a949f8>]
_raw_spin_lock_irqsave+0x78/0xd0 kernel/locking/spinlock.c:159
softirqs last  enabled at (170): [<     inline     >] spin_unlock_bh
include/linux/spinlock.h:352
softirqs last  enabled at (170): [<ffffffff858b426c>]
__release_sock+0xcc/0x3a0 net/core/sock.c:2051
softirqs last disabled at (168): [<     inline     >] spin_lock_bh
include/linux/spinlock.h:307
softirqs last disabled at (168): [<ffffffff858b43fe>]
__release_sock+0x25e/0x3a0 net/core/sock.c:2065

other info that might help us debug this:
 Possible unsafe locking scenario:

       CPU0
       ----
  lock(slock-AF_INET);
  <Interrupt>
    lock(slock-AF_INET);

 *** DEADLOCK ***

1 lock held by syz-executor/354:
 #0:  (sk_lock-AF_INET){+.+.+.}, at: [<     inline     >] lock_sock
include/net/sock.h:1388
 #0:  (sk_lock-AF_INET){+.+.+.}, at: [<ffffffff85d193f4>]
inet_stream_connect+0x44/0xa0 net/ipv4/af_inet.c:660

stack backtrace:
CPU: 3 PID: 354 Comm: syz-executor Not tainted 4.7.0-rc5+ #28
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
 ffffffff880b58e0 ffff8800361378c0 ffffffff82cc01af ffffffff00000000
 fffffbfff1016b1c ffff88003abfe840 ffffffff899bb700 ffff88003abff0a8
 ffffffff86cae460 0000000000000001 ffff880036137930 ffffffff8147684d
Call Trace:
 [<     inline     >] __dump_stack lib/dump_stack.c:15
 [<ffffffff82cc01af>] dump_stack+0x12e/0x18f lib/dump_stack.c:51
 [<ffffffff8147684d>] print_usage_bug+0x34d/0x3a0 kernel/locking/lockdep.c:2383
 [<     inline     >] valid_state kernel/locking/lockdep.c:2396
 [<     inline     >] mark_lock_irq kernel/locking/lockdep.c:2594
 [<ffffffff8147748c>] mark_lock+0xbec/0xe80 kernel/locking/lockdep.c:3057
 [<     inline     >] mark_irqflags kernel/locking/lockdep.c:2933
 [<ffffffff814793ce>] __lock_acquire+0xd3e/0x2fb0 kernel/locking/lockdep.c:3287
 [<ffffffff8147c293>] lock_acquire+0x1e3/0x460 kernel/locking/lockdep.c:3741
 [<     inline     >] __raw_spin_lock include/linux/spinlock_api_smp.h:144
 [<ffffffff86a93f83>] _raw_spin_lock+0x33/0x50 kernel/locking/spinlock.c:151
 [<     inline     >] spin_lock include/linux/spinlock.h:302
 [<ffffffff864831b1>] dccp_v4_ctl_send_reset+0xac1/0x10d0 net/dccp/ipv4.c:530
 [<ffffffff864838b9>] dccp_v4_do_rcv+0xf9/0x190 net/dccp/ipv4.c:684
 [<     inline     >] sk_backlog_rcv include/net/sock.h:872
 [<ffffffff858b42c7>] __release_sock+0x127/0x3a0 net/core/sock.c:2058
 [<ffffffff858b4599>] release_sock+0x59/0x1c0 net/core/sock.c:2516
 [<ffffffff85d19428>] inet_stream_connect+0x78/0xa0 net/ipv4/af_inet.c:662
 [<ffffffff858a62ae>] SYSC_connect+0x23e/0x2e0 net/socket.c:1536
 [<ffffffff858ab3d4>] SyS_connect+0x24/0x30 net/socket.c:1517
 [<ffffffff86a94e00>] entry_SYSCALL_64_fastpath+0x23/0xc1
arch/x86/entry/entry_64.S:207


On commit 1a0a02d1efa066001fd315c1b4df583d939fa2c4 (Jun 30).
