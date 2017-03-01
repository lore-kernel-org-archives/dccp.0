From: Dmitry Vyukov <dvyukov@google.com>
Date: Wed, 01 Mar 2017 09:38:54 +0000
Subject: net/dccp: dccp_create_openreq_child freed held lock
Message-Id: <CACT4Y+ZOAWRzJH3=xJ1z5bFVCM2-smuVSykziQPhSgkv1k3FBQ@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hello,

I've got the following report while running syzkaller fuzzer on
86292b33d4b79ee03e2f43ea0381ef85f077c760:

[ BUG: held lock freed! ]
4.10.0+ #234 Not tainted
-------------------------
syz-executor6/6898 is freeing memory
ffff88006286cac0-ffff88006286d3b7, with a lock still held there!
 (slock-AF_INET6){+.-...}, at: [<ffffffff8362c2c9>] spin_lock
include/linux/spinlock.h:299 [inline]
 (slock-AF_INET6){+.-...}, at: [<ffffffff8362c2c9>]
sk_clone_lock+0x3d9/0x12c0 net/core/sock.c:1504
5 locks held by syz-executor6/6898:
 #0:  (sk_lock-AF_INET6){+.+.+.}, at: [<ffffffff839a34b4>] lock_sock
include/net/sock.h:1460 [inline]
 #0:  (sk_lock-AF_INET6){+.+.+.}, at: [<ffffffff839a34b4>]
inet_stream_connect+0x44/0xa0 net/ipv4/af_inet.c:681
 #1:  (rcu_read_lock){......}, at: [<ffffffff83bc1c2a>]
inet6_csk_xmit+0x12a/0x5d0 net/ipv6/inet6_connection_sock.c:126
 #2:  (rcu_read_lock){......}, at: [<ffffffff8369b424>] __skb_unlink
include/linux/skbuff.h:1767 [inline]
 #2:  (rcu_read_lock){......}, at: [<ffffffff8369b424>] __skb_dequeue
include/linux/skbuff.h:1783 [inline]
 #2:  (rcu_read_lock){......}, at: [<ffffffff8369b424>]
process_backlog+0x264/0x730 net/core/dev.c:4835
 #3:  (rcu_read_lock){......}, at: [<ffffffff83aeb5c0>]
ip6_input_finish+0x0/0x1700 net/ipv6/ip6_input.c:59
 #4:  (slock-AF_INET6){+.-...}, at: [<ffffffff8362c2c9>] spin_lock
include/linux/spinlock.h:299 [inline]
 #4:  (slock-AF_INET6){+.-...}, at: [<ffffffff8362c2c9>]
sk_clone_lock+0x3d9/0x12c0 net/core/sock.c:1504

stack backtrace:
CPU: 3 PID: 6898 Comm: syz-executor6 Not tainted 4.10.0+ #234
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
Call Trace:
 <IRQ>
 __dump_stack lib/dump_stack.c:15 [inline]
 dump_stack+0x2ee/0x3ef lib/dump_stack.c:51
 print_freed_lock_bug kernel/locking/lockdep.c:4248 [inline]
 debug_check_no_locks_freed+0x4d2/0x5c0 kernel/locking/lockdep.c:4281
9pnet_virtio: no channels available for device ./bus
 kmem_cache_free+0x62/0x240 mm/slab.c:3770
 sk_prot_free net/core/sock.c:1375 [inline]
 __sk_destruct+0x487/0x6b0 net/core/sock.c:1450
 sk_destruct+0x47/0x80 net/core/sock.c:1458
 __sk_free+0x57/0x230 net/core/sock.c:1466
 sk_free+0x23/0x30 net/core/sock.c:1477
 dccp_create_openreq_child+0x50e/0x610 net/dccp/minisocks.c:125
 dccp_v6_request_recv_sock+0x1f1/0x17e0 net/dccp/ipv6.c:457
 dccp_check_req+0x335/0x5a0 net/dccp/minisocks.c:186
 dccp_v6_rcv+0x653/0x1d10 net/dccp/ipv6.c:711
 ip6_input_finish+0x45b/0x1700 net/ipv6/ip6_input.c:279
 NF_HOOK include/linux/netfilter.h:257 [inline]
 ip6_input+0xdb/0x580 net/ipv6/ip6_input.c:322
 dst_input include/net/dst.h:492 [inline]
 ip6_rcv_finish+0x194/0x720 net/ipv6/ip6_input.c:69
 NF_HOOK include/linux/netfilter.h:257 [inline]
 ipv6_rcv+0x12df/0x2380 net/ipv6/ip6_input.c:203
 __netif_receive_skb_core+0x1ac8/0x33f0 net/core/dev.c:4179
 __netif_receive_skb+0x2a/0x170 net/core/dev.c:4217
 process_backlog+0x11e/0x730 net/core/dev.c:4837
 napi_poll net/core/dev.c:5171 [inline]
 net_rx_action+0xeb4/0x1580 net/core/dev.c:5236
 __do_softirq+0x31f/0xbe7 kernel/softirq.c:284
 do_softirq_own_stack+0x1c/0x30 arch/x86/entry/entry_64.S:902
 </IRQ>
 do_softirq.part.21+0x2c0/0x300 kernel/softirq.c:328
 do_softirq kernel/softirq.c:176 [inline]
 __local_bh_enable_ip+0x24c/0x290 kernel/softirq.c:181
 local_bh_enable include/linux/bottom_half.h:31 [inline]
 rcu_read_unlock_bh include/linux/rcupdate.h:971 [inline]
 ip6_finish_output2+0xb85/0x2380 net/ipv6/ip6_output.c:124
 ip6_finish_output+0x2f9/0x950 net/ipv6/ip6_output.c:149
 NF_HOOK_COND include/linux/netfilter.h:246 [inline]
 ip6_output+0x1cb/0x8c0 net/ipv6/ip6_output.c:163
 ip6_xmit+0xc36/0x1e80 include/net/dst.h:486
 inet6_csk_xmit+0x320/0x5d0 net/ipv6/inet6_connection_sock.c:139
 dccp_transmit_skb+0xac5/0x10e0 net/dccp/output.c:141
 dccp_send_ack+0x1bf/0x350 net/dccp/output.c:594
 dccp_rcv_request_sent_state_process net/dccp/input.c:501 [inline]
 dccp_rcv_state_process+0x102d/0x1650 net/dccp/input.c:671
 dccp_v6_do_rcv+0x20d/0x350 net/dccp/ipv6.c:632
 sk_backlog_rcv include/net/sock.h:896 [inline]
 __release_sock+0x126/0x3a0 net/core/sock.c:2052
 release_sock+0xa5/0x2b0 net/core/sock.c:2539
 inet_wait_for_connect net/ipv4/af_inet.c:557 [inline]
 __inet_stream_connect+0x712/0xf80 net/ipv4/af_inet.c:643
 inet_stream_connect+0x58/0xa0 net/ipv4/af_inet.c:682
 SYSC_connect+0x251/0x580 net/socket.c:1577
 SyS_connect+0x24/0x30 net/socket.c:1558
 entry_SYSCALL_64_fastpath+0x1f/0xc2
RIP: 0033:0x4458d9
RSP: 002b:00007fbd320fbb58 EFLAGS: 00000282 ORIG_RAX: 000000000000002a
RAX: ffffffffffffffda RBX: 0000000000000020 RCX: 00000000004458d9
RDX: 0000000000000020 RSI: 0000000020e5afe0 RDI: 0000000000000020
RBP: 00000000006de450 R08: 0000000000000000 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000282 R12: 00000000007080a8
R13: 0000000000000001 R14: 00000000007080b0 R15: 00007fbd320fc700


It seems that dccp_create_openreq_child needs to unlock the sock if
dccp_feat_activate_values fails.
