From: syzbot <syzbot+554ccde221001ab5479a@syzkaller.appspotmail.com>
Date: Mon, 02 Apr 2018 09:20:02 +0000
Subject: KASAN: use-after-free Read in ccid2_hc_tx_packet_recv
Message-Id: <0000000000003872fd0568da185f@google.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hello,

syzbot hit the following crash on upstream commit
0adb32858b0bddf4ada5f364a84ed60b196dbcda (Sun Apr 1 21:20:27 2018 +0000)
Linux 4.16
syzbot dashboard link:  
https://syzkaller.appspot.com/bug?extidU4ccde221001ab5479a

Unfortunately, I don't have any reproducer for this crash yet.
Raw console output:  
https://syzkaller.appspot.com/x/log.txt?idX22430194958336
Kernel config:  
https://syzkaller.appspot.com/x/.config?id=-2374466361298166459
compiler: gcc (GCC) 7.1.1 20170620
user-space arch: i386

IMPORTANT: if you fix the bug, please add the following tag to the commit:
Reported-by: syzbot+554ccde221001ab5479a@syzkaller.appspotmail.com
It will help syzbot understand when the bug is fixed. See footer for  
details.
If you forward the report, please keep this part and the footer.

R10: 0000000000000000 R11: 0000000000000000 R12: 0000000000000000
R13: 0000000000000000 R14: 0000000000000000 R15: 0000000000000000
dccp_parse_options: DCCP(000000007d56a000): Option 32 (len=7) error=9
=================================
dccp_check_seqno: Step 6 failed for RESET packet, (LSWL(279336972291068) <=  
P.seqno(279336972291066) <= S.SWH(279336972291142)) and (P.ackno exists or  
LAWL(234137106534459) <= P.ackno(234137106534459) <=  
S.AWH(234137106534460), sending SYNC...
BUG: KASAN: use-after-free in ccid2_hc_tx_packet_recv+0x234a/0x2440  
net/dccp/ccids/ccid2.c:598
Read of size 1 at addr ffff8801bb7a4a82 by task syz-executor1/1660

CPU: 1 PID: 1660 Comm: syz-executor1 Not tainted 4.16.0+ #285
Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS  
Google 01/01/2011
Call Trace:
  __dump_stack lib/dump_stack.c:17 [inline]
  dump_stack+0x194/0x24d lib/dump_stack.c:53
  print_address_description+0x73/0x250 mm/kasan/report.c:256
  kasan_report_error mm/kasan/report.c:354 [inline]
  kasan_report+0x23c/0x360 mm/kasan/report.c:412
  __asan_report_load1_noabort+0x14/0x20 mm/kasan/report.c:430
  ccid2_hc_tx_packet_recv+0x234a/0x2440 net/dccp/ccids/ccid2.c:598
  ccid_hc_tx_packet_recv net/dccp/ccid.h:192 [inline]
  dccp_deliver_input_to_ccids+0x1d0/0x250 net/dccp/input.c:186
  dccp_rcv_established+0x88/0xb0 net/dccp/input.c:378
  dccp_v4_do_rcv+0x135/0x160 net/dccp/ipv4.c:653
  sk_backlog_rcv include/net/sock.h:908 [inline]
  __release_sock+0x124/0x360 net/core/sock.c:2271
  release_sock+0xa4/0x2a0 net/core/sock.c:2786
  dccp_sendmsg+0x528/0xe60 net/dccp/proto.c:820
  inet_sendmsg+0x11f/0x5e0 net/ipv4/af_inet.c:764
  sock_sendmsg_nosec net/socket.c:630 [inline]
  sock_sendmsg+0xca/0x110 net/socket.c:640
  ___sys_sendmsg+0x320/0x8b0 net/socket.c:2046
  __sys_sendmmsg+0x31b/0x620 net/socket.c:2129
  C_SYSC_sendmmsg net/compat.c:745 [inline]
  compat_SyS_sendmmsg+0x32/0x40 net/compat.c:742
  do_syscall_32_irqs_on arch/x86/entry/common.c:330 [inline]
  do_fast_syscall_32+0x3ec/0xf9f arch/x86/entry/common.c:392
  entry_SYSENTER_compat+0x70/0x7f arch/x86/entry/entry_64_compat.S:139
RIP: 0023:0xf7f6dc99
RSP: 002b:00000000f5f690ac EFLAGS: 00000282 ORIG_RAX: 0000000000000159
RAX: ffffffffffffffda RBX: 0000000000000013 RCX: 000000002000b880
RDX: 0000000000000122 RSI: 0000000000000000 RDI: 0000000000000000
RBP: 0000000000000000 R08: 0000000000000000 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000000 R12: 0000000000000000
R13: 0000000000000000 R14: 0000000000000000 R15: 0000000000000000

Allocated by task 1660:
  save_stack+0x43/0xd0 mm/kasan/kasan.c:447
  set_track mm/kasan/kasan.c:459 [inline]
  kasan_kmalloc+0xad/0xe0 mm/kasan/kasan.c:552
  __do_kmalloc_node mm/slab.c:3670 [inline]
  __kmalloc_node_track_caller+0x47/0x70 mm/slab.c:3684
  __kmalloc_reserve.isra.39+0x41/0xd0 net/core/skbuff.c:137
  __alloc_skb+0x13b/0x780 net/core/skbuff.c:205
  alloc_skb include/linux/skbuff.h:983 [inline]
  dccp_send_ack+0xb6/0x350 net/dccp/output.c:580
  ccid2_hc_rx_packet_recv+0x10d/0x180 net/dccp/ccids/ccid2.c:766
  ccid_hc_rx_packet_recv net/dccp/ccid.h:185 [inline]
  dccp_deliver_input_to_ccids+0xd9/0x250 net/dccp/input.c:180
  dccp_rcv_established+0x88/0xb0 net/dccp/input.c:378
  dccp_v4_do_rcv+0x135/0x160 net/dccp/ipv4.c:653
  sk_backlog_rcv include/net/sock.h:908 [inline]
  __sk_receive_skb+0x33e/0xc10 net/core/sock.c:513
  dccp_v4_rcv+0xf5f/0x1c80 net/dccp/ipv4.c:874
  ip_local_deliver_finish+0x2f1/0xc50 net/ipv4/ip_input.c:216
  NF_HOOK include/linux/netfilter.h:288 [inline]
  ip_local_deliver+0x1ce/0x6e0 net/ipv4/ip_input.c:257
  dst_input include/net/dst.h:449 [inline]
  ip_rcv_finish+0xa36/0x2040 net/ipv4/ip_input.c:397
  NF_HOOK include/linux/netfilter.h:288 [inline]
  ip_rcv+0xb76/0x1820 net/ipv4/ip_input.c:493
  __netif_receive_skb_core+0x1a41/0x3460 net/core/dev.c:4562
  __netif_receive_skb+0x2c/0x1b0 net/core/dev.c:4627
  process_backlog+0x203/0x740 net/core/dev.c:5307
  napi_poll net/core/dev.c:5705 [inline]
  net_rx_action+0x792/0x1910 net/core/dev.c:5771
  __do_softirq+0x2d7/0xb85 kernel/softirq.c:285

Freed by task 1660:
  save_stack+0x43/0xd0 mm/kasan/kasan.c:447
  set_track mm/kasan/kasan.c:459 [inline]
  __kasan_slab_free+0x11a/0x170 mm/kasan/kasan.c:520
  kasan_slab_free+0xe/0x10 mm/kasan/kasan.c:527
  __cache_free mm/slab.c:3486 [inline]
  kfree+0xd9/0x260 mm/slab.c:3801
  skb_free_head+0x74/0xb0 net/core/skbuff.c:550
  skb_release_data+0x58c/0x790 net/core/skbuff.c:570
  skb_release_all+0x4a/0x60 net/core/skbuff.c:627
  __kfree_skb net/core/skbuff.c:641 [inline]
  kfree_skb+0x15d/0x4c0 net/core/skbuff.c:659
  dccp_v4_do_rcv+0x10d/0x160 net/dccp/ipv4.c:688
  sk_backlog_rcv include/net/sock.h:908 [inline]
  __release_sock+0x124/0x360 net/core/sock.c:2271
  release_sock+0xa4/0x2a0 net/core/sock.c:2786
  dccp_sendmsg+0x528/0xe60 net/dccp/proto.c:820
  inet_sendmsg+0x11f/0x5e0 net/ipv4/af_inet.c:764
  sock_sendmsg_nosec net/socket.c:630 [inline]
  sock_sendmsg+0xca/0x110 net/socket.c:640
  ___sys_sendmsg+0x320/0x8b0 net/socket.c:2046
  __sys_sendmmsg+0x31b/0x620 net/socket.c:2129
  C_SYSC_sendmmsg net/compat.c:745 [inline]
  compat_SyS_sendmmsg+0x32/0x40 net/compat.c:742
  do_syscall_32_irqs_on arch/x86/entry/common.c:330 [inline]
  do_fast_syscall_32+0x3ec/0xf9f arch/x86/entry/common.c:392
  entry_SYSENTER_compat+0x70/0x7f arch/x86/entry/entry_64_compat.S:139

The buggy address belongs to the object at ffff8801bb7a4600
  which belongs to the cache kmalloc-2048 of size 2048
The buggy address is located 1154 bytes inside of
  2048-byte region [ffff8801bb7a4600, ffff8801bb7a4e00)
The buggy address belongs to the page:
page:ffffea0006ede900 count:1 mapcount:0 mapping:ffff8801bb7a4600 index:0x0  
compound_mapcount: 0
flags: 0x2fffc0000008100(slab|head)
raw: 02fffc0000008100 ffff8801bb7a4600 0000000000000000 0000000100000003
raw: ffffea0006bcbd20 ffffea0006f5b1a0 ffff8801dac00c40 0000000000000000
page dumped because: kasan: bad access detected

Memory state around the buggy address:
  ffff8801bb7a4980: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
  ffff8801bb7a4a00: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
> ffff8801bb7a4a80: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
                    ^
  ffff8801bb7a4b00: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
  ffff8801bb7a4b80: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
=================================


---
This bug is generated by a dumb bot. It may contain errors.
See https://goo.gl/tpsmEJ for details.
Direct all questions to syzkaller@googlegroups.com.

syzbot will keep track of this bug report.
If you forgot to add the Reported-by tag, once the fix for this bug is  
merged
into any tree, please reply to this email with:
#syz fix: exact-commit-title
To mark this as a duplicate of another syzbot report, please reply with:
#syz dup: exact-subject-of-another-report
If it's a one-off invalid bug report, please reply with:
#syz invalid
Note: if the crash happens again, it will cause creation of a new bug  
report.
Note: all commands must start from beginning of the line in the email body.
