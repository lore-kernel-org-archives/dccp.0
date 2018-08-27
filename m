From: syzbot <syzbot+3967c1caf256f4d5aefe@syzkaller.appspotmail.com>
Date: Mon, 27 Aug 2018 17:10:04 +0000
Subject: KASAN: use-after-free Read in ccid_hc_tx_delete
Message-Id: <000000000000de3c7705746dcbb7@google.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hello,

syzbot found the following crash on:

HEAD commit:    aba16dc5cf93 Merge branch 'ida-4.19' of git://git.infradea..
git tree:       upstream
console output: https://syzkaller.appspot.com/x/log.txt?x50d382400000
kernel config:  https://syzkaller.appspot.com/x/.config?x;576e333ca31bb2
dashboard link: https://syzkaller.appspot.com/bug?extid967c1caf256f4d5aefe
compiler:       gcc (GCC) 8.0.1 20180413 (experimental)
syz repro:      https://syzkaller.appspot.com/x/repro.syz?x9d007a400000

IMPORTANT: if you fix the bug, please add the following tag to the commit:
Reported-by: syzbot+3967c1caf256f4d5aefe@syzkaller.appspotmail.com

8021q: adding VLAN 0 to HW filter on device team0
8021q: adding VLAN 0 to HW filter on device team0
8021q: adding VLAN 0 to HW filter on device team0
hrtimer: interrupt took 33823 ns
=================================
BUG: KASAN: use-after-free in ccid_hc_tx_delete+0xe0/0x100  
net/dccp/ccid.c:188
Read of size 8 at addr ffff8801b0726b40 by task syz-executor3/6567

CPU: 1 PID: 6567 Comm: syz-executor3 Not tainted 4.18.0+ #210
Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS  
Google 01/01/2011
Call Trace:
  <IRQ>
  __dump_stack lib/dump_stack.c:77 [inline]
  dump_stack+0x1c9/0x2b4 lib/dump_stack.c:113
  print_address_description+0x6c/0x20b mm/kasan/report.c:256
  kasan_report_error mm/kasan/report.c:354 [inline]
  kasan_report.cold.7+0x242/0x30d mm/kasan/report.c:412
  __asan_report_load8_noabort+0x14/0x20 mm/kasan/report.c:433
  ccid_hc_tx_delete+0xe0/0x100 net/dccp/ccid.c:188
  dccp_sk_destruct+0x3c/0x80 net/dccp/proto.c:181
  __sk_destruct+0x107/0xa60 net/core/sock.c:1560
  __rcu_reclaim kernel/rcu/rcu.h:236 [inline]
  rcu_do_batch kernel/rcu/tree.c:2576 [inline]
  invoke_rcu_callbacks kernel/rcu/tree.c:2880 [inline]
  __rcu_process_callbacks kernel/rcu/tree.c:2847 [inline]
  rcu_process_callbacks+0xf78/0x27c0 kernel/rcu/tree.c:2864
  __do_softirq+0x2eb/0xa74 kernel/softirq.c:292
  invoke_softirq kernel/softirq.c:372 [inline]
  irq_exit+0x1d6/0x210 kernel/softirq.c:412
  exiting_irq arch/x86/include/asm/apic.h:536 [inline]
  smp_apic_timer_interrupt+0x18e/0x6a0 arch/x86/kernel/apic/apic.c:1056
  apic_timer_interrupt+0xf/0x20 arch/x86/entry/entry_64.S:864
  </IRQ>
RIP: 0010:memset_erms+0x9/0x10 arch/x86/lib/memset_64.S:65
Code: c1 e9 03 40 0f b6 f6 48 b8 01 01 01 01 01 01 01 01 48 0f af c6 f3 48  
ab 89 d1 f3 aa 4c 89 c8 c3 90 49 89 f9 40 88 f0 48 89 d1 <f3> aa 4c 89 c8  
c3 90 49 89 fa 40 0f b6 ce 48 b8 01 01 01 01 01 01
RSP: 0018:ffff8801b2aa75b0 EFLAGS: 00010246 ORIG_RAX: ffffffffffffff13
RAX: 0000000000000000 RBX: 00000000006080c0 RCX: 0000000000000240
RDX: 0000000000000800 RSI: 0000000000000000 RDI: ffff8801addbc880
RBP: ffff8801b2aa7630 R08: ffff8801d7642a80 R09: ffff8801addbc2c0
R10: ffff8801d7642240 R11: 0000000000000000 R12: ffff8801addbc2c0
R13: ffff8801dac00c40 R14: ffff8801dac00c40 R15: 00000000006080c0
  kmalloc include/linux/slab.h:513 [inline]
  kzalloc include/linux/slab.h:707 [inline]
  perf_event_alloc.part.93+0x1e2/0x33c0 kernel/events/core.c:9927
  perf_event_alloc kernel/events/core.c:10399 [inline]
  __do_sys_perf_event_open+0xa9c/0x2f30 kernel/events/core.c:10500
  __se_sys_perf_event_open kernel/events/core.c:10389 [inline]
  __x64_sys_perf_event_open+0xbe/0x150 kernel/events/core.c:10389
  do_syscall_64+0x1b9/0x820 arch/x86/entry/common.c:290
  entry_SYSCALL_64_after_hwframe+0x49/0xbe
RIP: 0033:0x457089
Code: fd b4 fb ff c3 66 2e 0f 1f 84 00 00 00 00 00 66 90 48 89 f8 48 89 f7  
48 89 d6 48 89 ca 4d 89 c2 4d 89 c8 4c 8b 4c 24 08 0f 05 <48> 3d 01 f0 ff  
ff 0f 83 cb b4 fb ff c3 66 2e 0f 1f 84 00 00 00 00
RSP: 002b:00007fc7df221c78 EFLAGS: 00000246 ORIG_RAX: 000000000000012a
RAX: ffffffffffffffda RBX: 00007fc7df2226d4 RCX: 0000000000457089
RDX: ffffffffffffffff RSI: 0000000000000000 RDI: 000000002001d000
RBP: 00000000009300a0 R08: 0000000000000000 R09: 0000000000000000
R10: ffffffffffffffff R11: 0000000000000246 R12: 00000000ffffffff
R13: 00000000004d3300 R14: 00000000004c8290 R15: 0000000000000000

Allocated by task 6568:
  save_stack+0x43/0xd0 mm/kasan/kasan.c:448
  set_track mm/kasan/kasan.c:460 [inline]
  kasan_kmalloc+0xc4/0xe0 mm/kasan/kasan.c:553
  kasan_slab_alloc+0x12/0x20 mm/kasan/kasan.c:490
  kmem_cache_alloc+0x12e/0x710 mm/slab.c:3554
  ccid_new+0x25b/0x3e0 net/dccp/ccid.c:151
  dccp_hdlr_ccid+0x27/0x150 net/dccp/feat.c:44
  __dccp_feat_activate+0x184/0x270 net/dccp/feat.c:344
  dccp_feat_activate_values+0x3b6/0x839 net/dccp/feat.c:1538
  dccp_rcv_request_sent_state_process net/dccp/input.c:472 [inline]
  dccp_rcv_state_process+0x11dc/0x1a30 net/dccp/input.c:678
  dccp_v6_do_rcv+0x26f/0xb80 net/dccp/ipv6.c:638
  sk_backlog_rcv include/net/sock.h:931 [inline]
  __release_sock+0x12f/0x3a0 net/core/sock.c:2336
  release_sock+0xad/0x2c0 net/core/sock.c:2849
  inet_wait_for_connect net/ipv4/af_inet.c:588 [inline]
  __inet_stream_connect+0x61f/0x1160 net/ipv4/af_inet.c:680
  inet_stream_connect+0x58/0xa0 net/ipv4/af_inet.c:719
  __sys_connect+0x37d/0x4c0 net/socket.c:1662
  __do_sys_connect net/socket.c:1673 [inline]
  __se_sys_connect net/socket.c:1670 [inline]
  __x64_sys_connect+0x73/0xb0 net/socket.c:1670
  do_syscall_64+0x1b9/0x820 arch/x86/entry/common.c:290
  entry_SYSCALL_64_after_hwframe+0x49/0xbe

Freed by task 6582:
  save_stack+0x43/0xd0 mm/kasan/kasan.c:448
  set_track mm/kasan/kasan.c:460 [inline]
  __kasan_slab_free+0x11a/0x170 mm/kasan/kasan.c:521
  kasan_slab_free+0xe/0x10 mm/kasan/kasan.c:528
  __cache_free mm/slab.c:3498 [inline]
  kmem_cache_free+0x86/0x280 mm/slab.c:3756
  ccid_hc_tx_delete+0xc3/0x100 net/dccp/ccid.c:190
  dccp_hdlr_ccid+0x7d/0x150 net/dccp/feat.c:53
  __dccp_feat_activate+0x184/0x270 net/dccp/feat.c:344
  dccp_feat_activate_values+0x3b6/0x839 net/dccp/feat.c:1538
  dccp_create_openreq_child+0x47a/0x620 net/dccp/minisocks.c:127
  dccp_v6_request_recv_sock+0x253/0x2040 net/dccp/ipv6.c:466
  dccp_check_req+0x46e/0x6c0 net/dccp/minisocks.c:196
  dccp_v6_rcv+0x88e/0x1d9c net/dccp/ipv6.c:744
  ip6_input_finish+0x407/0x1a40 net/ipv6/ip6_input.c:383
  NF_HOOK include/linux/netfilter.h:287 [inline]
  ip6_input+0xe9/0x600 net/ipv6/ip6_input.c:426
  dst_input include/net/dst.h:450 [inline]
  ip6_rcv_finish+0x17a/0x330 net/ipv6/ip6_input.c:76
  NF_HOOK include/linux/netfilter.h:287 [inline]
  ipv6_rcv+0x11e/0x650 net/ipv6/ip6_input.c:271
  __netif_receive_skb_one_core+0x14d/0x200 net/core/dev.c:4892
  __netif_receive_skb+0x2c/0x1e0 net/core/dev.c:5002
  process_backlog+0x219/0x760 net/core/dev.c:5808
  napi_poll net/core/dev.c:6228 [inline]
  net_rx_action+0x799/0x1900 net/core/dev.c:6294
  __do_softirq+0x2eb/0xa74 kernel/softirq.c:292

The buggy address belongs to the object at ffff8801b0726b40
  which belongs to the cache ccid2_hc_tx_sock of size 1240
The buggy address is located 0 bytes inside of
  1240-byte region [ffff8801b0726b40, ffff8801b0727018)
The buggy address belongs to the page:
page:ffffea0006c1c980 count:1 mapcount:0 mapping:ffff8801cd8b6680 index:0x0  
compound_mapcount: 0
flags: 0x2fffc0000008100(slab|head)
raw: 02fffc0000008100 ffff8801cd8b3648 ffffea0006c1e308 ffff8801cd8b6680
raw: 0000000000000000 ffff8801b0726040 0000000100000005 0000000000000000
page dumped because: kasan: bad access detected

Memory state around the buggy address:
  ffff8801b0726a00: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
  ffff8801b0726a80: fb fb fb fc fc fc fc fc fc fc fc fc fc fc fc fc
> ffff8801b0726b00: fc fc fc fc fc fc fc fc fb fb fb fb fb fb fb fb
                                            ^
  ffff8801b0726b80: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
  ffff8801b0726c00: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
=================================


---
This bug is generated by a bot. It may contain errors.
See https://goo.gl/tpsmEJ for more information about syzbot.
syzbot engineers can be reached at syzkaller@googlegroups.com.

syzbot will keep track of this bug report. See:
https://goo.gl/tpsmEJ#bug-status-tracking for how to communicate with  
syzbot.
syzbot can test patches for this bug, for details see:
https://goo.gl/tpsmEJ#testing-patches
