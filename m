From: syzbot <syzbot+554ccde221001ab5479a@syzkaller.appspotmail.com>
Date: Fri, 25 May 2018 13:52:02 +0000
Subject: Re: KASAN: use-after-free Read in ccid2_hc_tx_packet_recv
Message-Id: <00000000000097140a056d081254@google.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

syzbot has found a reproducer for the following crash on:

HEAD commit:    b50694381cfc Merge branch 'stable/for-linus-4.17' of git:/..
git tree:       upstream
console output: https://syzkaller.appspot.com/x/log.txt?x=17151cb7800000
kernel config:  https://syzkaller.appspot.com/x/.config?x=982e2df1b9e60b02
dashboard link: https://syzkaller.appspot.com/bug?extidU4ccde221001ab5479a
compiler:       gcc (GCC) 8.0.1 20180413 (experimental)
syzkaller repro:https://syzkaller.appspot.com/x/repro.syz?x=1363ccb7800000
C reproducer:   https://syzkaller.appspot.com/x/repro.c?x=1272e2b7800000

IMPORTANT: if you fix the bug, please add the following tag to the commit:
Reported-by: syzbot+554ccde221001ab5479a@syzkaller.appspotmail.com

Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS =20
Google 01/01/2011
Call Trace:
  __dump_stack lib/dump_stack.c:77 [inline]
  dump_stack+0x1b9/0x294 lib/dump_stack.c:113
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D
  fail_dump lib/fault-inject.c:51 [inline]
  should_fail.cold.4+0xa/0x1a lib/fault-inject.c:149
BUG: KASAN: use-after-free in ccid2_hc_tx_packet_recv+0x2383/0x275e =20
net/dccp/ccids/ccid2.c:597
Read of size 1 at addr ffff8801ba4911c2 by task syz-executor940/4542

  __should_failslab+0x124/0x180 mm/failslab.c:32
  should_failslab+0x9/0x14 mm/slab_common.c:1522
  slab_pre_alloc_hook mm/slab.h:423 [inline]
  slab_alloc mm/slab.c:3378 [inline]
  kmem_cache_alloc_trace+0x4b/0x780 mm/slab.c:3618
  kmalloc include/linux/slab.h:512 [inline]
  dccp_ackvec_parsed_add+0xa1/0x310 net/dccp/ackvec.c:352
  ccid2_hc_tx_parse_options+0x9a/0xb0 net/dccp/ccids/ccid2.c:510
  ccid_hc_tx_parse_options net/dccp/ccid.h:207 [inline]
  dccp_parse_options+0x658/0x11f0 net/dccp/options.c:233
  dccp_rcv_established+0x44/0xb0 net/dccp/input.c:374
  dccp_v4_do_rcv+0x153/0x180 net/dccp/ipv4.c:654
  sk_backlog_rcv include/net/sock.h:909 [inline]
  __release_sock+0x12f/0x3a0 net/core/sock.c:2335
  release_sock+0xa4/0x2b0 net/core/sock.c:2850
  dccp_sendmsg+0x771/0x1020 net/dccp/proto.c:820
  inet_sendmsg+0x19f/0x690 net/ipv4/af_inet.c:798
  sock_sendmsg_nosec net/socket.c:629 [inline]
  sock_sendmsg+0xd5/0x120 net/socket.c:639
  ___sys_sendmsg+0x525/0x940 net/socket.c:2117
  __sys_sendmmsg+0x240/0x6f0 net/socket.c:2212
  __do_sys_sendmmsg net/socket.c:2241 [inline]
  __se_sys_sendmmsg net/socket.c:2238 [inline]
  __x64_sys_sendmmsg+0x9d/0x100 net/socket.c:2238
  do_syscall_64+0x1b1/0x800 arch/x86/entry/common.c:287
  entry_SYSCALL_64_after_hwframe+0x49/0xbe
RIP: 0033:0x441819
RSP: 002b:00007ffdb9a9df08 EFLAGS: 00000246 ORIG_RAX: 0000000000000133
RAX: ffffffffffffffda RBX: 0000000000000000 RCX: 0000000000441819
RDX: 04000000000001e6 RSI: 0000000020000c00 RDI: 0000000000000005
RBP: 00007ffdb9a9df20 R08: 0000000000000002 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000246 R12: ffffffffffffffff
R13: 04000000000001e6 R14: 0000000000000006 R15: 0000000000000000
CPU: 0 PID: 4542 Comm: syz-executor940 Not tainted 4.17.0-rc6+ #66
dccp_parse_options: DCCP(        (ptrval)): Option 38 (len=3D1) error=3D5
Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS =20
Google 01/01/2011
Call Trace:
  __dump_stack lib/dump_stack.c:77 [inline]
  dump_stack+0x1b9/0x294 lib/dump_stack.c:113
  print_address_description+0x6c/0x20b mm/kasan/report.c:256
  kasan_report_error mm/kasan/report.c:354 [inline]
  kasan_report.cold.7+0x242/0x2fe mm/kasan/report.c:412
  __asan_report_load1_noabort+0x14/0x20 mm/kasan/report.c:430
  ccid2_hc_tx_packet_recv+0x2383/0x275e net/dccp/ccids/ccid2.c:597
  ccid_hc_tx_packet_recv net/dccp/ccid.h:192 [inline]
  dccp_deliver_input_to_ccids+0x203/0x280 net/dccp/input.c:186
  dccp_rcv_established+0x87/0xb0 net/dccp/input.c:378
  dccp_v4_do_rcv+0x153/0x180 net/dccp/ipv4.c:654
  sk_backlog_rcv include/net/sock.h:909 [inline]
  __release_sock+0x12f/0x3a0 net/core/sock.c:2335
  release_sock+0xa4/0x2b0 net/core/sock.c:2850
  dccp_sendmsg+0x771/0x1020 net/dccp/proto.c:820
  inet_sendmsg+0x19f/0x690 net/ipv4/af_inet.c:798
  sock_sendmsg_nosec net/socket.c:629 [inline]
  sock_sendmsg+0xd5/0x120 net/socket.c:639
  ___sys_sendmsg+0x525/0x940 net/socket.c:2117
  __sys_sendmmsg+0x240/0x6f0 net/socket.c:2212
  __do_sys_sendmmsg net/socket.c:2241 [inline]
  __se_sys_sendmmsg net/socket.c:2238 [inline]
  __x64_sys_sendmmsg+0x9d/0x100 net/socket.c:2238
  do_syscall_64+0x1b1/0x800 arch/x86/entry/common.c:287
  entry_SYSCALL_64_after_hwframe+0x49/0xbe
RIP: 0033:0x441819
RSP: 002b:00007ffdb9a9df08 EFLAGS: 00000246 ORIG_RAX: 0000000000000133
RAX: ffffffffffffffda RBX: 0000000000000000 RCX: 0000000000441819
RDX: 04000000000001e6 RSI: 0000000020000c00 RDI: 0000000000000005
RBP: 00007ffdb9a9df20 R08: 0000000000000002 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000246 R12: ffffffffffffffff
R13: 04000000000001e6 R14: 0000000000000006 R15: 0000000000000000

Allocated by task 4542:
  save_stack+0x43/0xd0 mm/kasan/kasan.c:448
  set_track mm/kasan/kasan.c:460 [inline]
  kasan_kmalloc+0xc4/0xe0 mm/kasan/kasan.c:553
  __do_kmalloc_node mm/slab.c:3682 [inline]
  __kmalloc_node_track_caller+0x47/0x70 mm/slab.c:3696
  __kmalloc_reserve.isra.38+0x3a/0xe0 net/core/skbuff.c:137
  __alloc_skb+0x14d/0x780 net/core/skbuff.c:205
  alloc_skb include/linux/skbuff.h:987 [inline]
  dccp_send_ack+0xd2/0x340 net/dccp/output.c:580
  ccid2_hc_rx_packet_recv+0x139/0x1b0 net/dccp/ccids/ccid2.c:776
  ccid_hc_rx_packet_recv net/dccp/ccid.h:185 [inline]
  dccp_deliver_input_to_ccids+0xf0/0x280 net/dccp/input.c:180
  dccp_rcv_established+0x87/0xb0 net/dccp/input.c:378
  dccp_v4_do_rcv+0x153/0x180 net/dccp/ipv4.c:654
  sk_backlog_rcv include/net/sock.h:909 [inline]
  __sk_receive_skb+0x3a2/0xd60 net/core/sock.c:513
  dccp_v4_rcv+0x10e5/0x1f3f net/dccp/ipv4.c:875
  ip_local_deliver_finish+0x2e3/0xd80 net/ipv4/ip_input.c:215
  NF_HOOK include/linux/netfilter.h:288 [inline]
  ip_local_deliver+0x1e1/0x720 net/ipv4/ip_input.c:256
  dst_input include/net/dst.h:450 [inline]
  ip_rcv_finish+0x81b/0x2200 net/ipv4/ip_input.c:396
  NF_HOOK include/linux/netfilter.h:288 [inline]
  ip_rcv+0xb70/0x143d net/ipv4/ip_input.c:492
  __netif_receive_skb_core+0x26f5/0x3630 net/core/dev.c:4592
  __netif_receive_skb+0x2c/0x1e0 net/core/dev.c:4657
  process_backlog+0x219/0x760 net/core/dev.c:5337
  napi_poll net/core/dev.c:5735 [inline]
  net_rx_action+0x7b7/0x1930 net/core/dev.c:5801
  __do_softirq+0x2e0/0xaf5 kernel/softirq.c:285

Freed by task 4542:
  save_stack+0x43/0xd0 mm/kasan/kasan.c:448
  set_track mm/kasan/kasan.c:460 [inline]
  __kasan_slab_free+0x11a/0x170 mm/kasan/kasan.c:521
  kasan_slab_free+0xe/0x10 mm/kasan/kasan.c:528
  __cache_free mm/slab.c:3498 [inline]
  kfree+0xd9/0x260 mm/slab.c:3813
  skb_free_head+0x99/0xc0 net/core/skbuff.c:550
  skb_release_data+0x690/0x860 net/core/skbuff.c:570
  skb_release_all+0x4a/0x60 net/core/skbuff.c:627
  __kfree_skb net/core/skbuff.c:641 [inline]
  kfree_skb+0x195/0x560 net/core/skbuff.c:659
  dccp_v4_do_rcv+0x12b/0x180 net/dccp/ipv4.c:689
  sk_backlog_rcv include/net/sock.h:909 [inline]
  __release_sock+0x12f/0x3a0 net/core/sock.c:2335
  release_sock+0xa4/0x2b0 net/core/sock.c:2850
  dccp_sendmsg+0x771/0x1020 net/dccp/proto.c:820
  inet_sendmsg+0x19f/0x690 net/ipv4/af_inet.c:798
  sock_sendmsg_nosec net/socket.c:629 [inline]
  sock_sendmsg+0xd5/0x120 net/socket.c:639
  ___sys_sendmsg+0x525/0x940 net/socket.c:2117
  __sys_sendmmsg+0x240/0x6f0 net/socket.c:2212
  __do_sys_sendmmsg net/socket.c:2241 [inline]
  __se_sys_sendmmsg net/socket.c:2238 [inline]
  __x64_sys_sendmmsg+0x9d/0x100 net/socket.c:2238
  do_syscall_64+0x1b1/0x800 arch/x86/entry/common.c:287
  entry_SYSCALL_64_after_hwframe+0x49/0xbe

The buggy address belongs to the object at ffff8801ba490d40
  which belongs to the cache kmalloc-2048 of size 2048
The buggy address is located 1154 bytes inside of
  2048-byte region [ffff8801ba490d40, ffff8801ba491540)
The buggy address belongs to the page:
page:ffffea0006e92400 count:1 mapcount:0 mapping:ffff8801ba4904c0 index:0x0=
 =20
compound_mapcount: 0
flags: 0x2fffc0000008100(slab|head)
raw: 02fffc0000008100 ffff8801ba4904c0 0000000000000000 0000000100000003
raw: ffffea0006ed9a20 ffffea0006fa5fa0 ffff8801da800c40 0000000000000000
page dumped because: kasan: bad access detected

Memory state around the buggy address:
  ffff8801ba491080: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
  ffff8801ba491100: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
> ffff8801ba491180: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
                                            ^
  ffff8801ba491200: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
  ffff8801ba491280: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D

