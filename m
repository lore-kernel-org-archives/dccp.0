From: Dmitry Vyukov <dvyukov@google.com>
Date: Fri, 03 Mar 2017 14:11:59 +0000
Subject: Re: net/dccp: use-after-free in dccp_feat_activate_values
Message-Id: <CACT4Y+YUJGsvzFuFT3r0M-3KbPrcx62fzSHHQX=B43-syLYU0A@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <CAM_iQpUVusW6YJqSgXSo2hAA2dCZGYxw4h+A1_iBpaiYMsXDMA@mail.gmail.com>
In-Reply-To: <CAM_iQpUVusW6YJqSgXSo2hAA2dCZGYxw4h+A1_iBpaiYMsXDMA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Mon, Feb 13, 2017 at 11:29 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> On Mon, Feb 13, 2017 at 11:19 AM, Andrey Konovalov
> <andreyknvl@google.com> wrote:
>> Hi,
>>
>> I've got the following error report while fuzzing the kernel with syzkaller.
>>
>> On commit 926af6273fc683cd98cd0ce7bf0d04a02eed6742.
>>
>> A reproducer and .config are attached.
>> Note, that it takes quite some time to trigger the bug (up to 10 minutes).
>>
>> BUG: KASAN: use-after-free in dccp_feat_activate_values+0x967/0xab0
>> net/dccp/feat.c:1541 at addr ffff88003713be68
>> Read of size 8 by task syz-executor2/8457
>> CPU: 2 PID: 8457 Comm: syz-executor2 Not tainted 4.10.0-rc7+ #127
>> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
>> Call Trace:
>>  <IRQ>
>>  __dump_stack lib/dump_stack.c:15 [inline]
>>  dump_stack+0x292/0x398 lib/dump_stack.c:51
>>  kasan_object_err+0x1c/0x70 mm/kasan/report.c:162
>>  print_address_description mm/kasan/report.c:200 [inline]
>>  kasan_report_error mm/kasan/report.c:289 [inline]
>>  kasan_report.part.1+0x20e/0x4e0 mm/kasan/report.c:311
>>  kasan_report mm/kasan/report.c:332 [inline]
>>  __asan_report_load8_noabort+0x29/0x30 mm/kasan/report.c:332
>>  dccp_feat_activate_values+0x967/0xab0 net/dccp/feat.c:1541
>>  dccp_create_openreq_child+0x464/0x610 net/dccp/minisocks.c:121
>>  dccp_v6_request_recv_sock+0x1f6/0x1960 net/dccp/ipv6.c:457
>>  dccp_check_req+0x335/0x5a0 net/dccp/minisocks.c:186
>>  dccp_v6_rcv+0x69e/0x1d00 net/dccp/ipv6.c:711
>>  ip6_input_finish+0x46d/0x17a0 net/ipv6/ip6_input.c:279
>>  NF_HOOK include/linux/netfilter.h:257 [inline]
>>  ip6_input+0xdb/0x590 net/ipv6/ip6_input.c:322
>>  dst_input include/net/dst.h:507 [inline]
>>  ip6_rcv_finish+0x289/0x890 net/ipv6/ip6_input.c:69
>>  NF_HOOK include/linux/netfilter.h:257 [inline]
>>  ipv6_rcv+0x12ec/0x23d0 net/ipv6/ip6_input.c:203
>>  __netif_receive_skb_core+0x1ae5/0x3400 net/core/dev.c:4190
>>  __netif_receive_skb+0x2a/0x170 net/core/dev.c:4228
>>  process_backlog+0xe5/0x6c0 net/core/dev.c:4839
>>  napi_poll net/core/dev.c:5202 [inline]
>>  net_rx_action+0xe70/0x1900 net/core/dev.c:5267
>>  __do_softirq+0x2fb/0xb7d kernel/softirq.c:284
>>  do_softirq_own_stack+0x1c/0x30 arch/x86/entry/entry_64.S:902
>
>
> Seems there is a race condition between iterating dccp_feat_entry
> and freeing it, bh_lock_sock() seems not held in this path.



Cong, where exactly do we need to add bh_lock_sock()?

I am still seeing this on 4977ab6e92e267afe9d8f78438c3db330ca8434c

=================================
BUG: KASAN: use-after-free in dccp_feat_activate_values+0x94c/0xa90
net/dccp/feat.c:1541 at addr ffff880059f18998
Read of size 8 by task syz-executor/3952
CPU: 2 PID: 3952 Comm: syz-executor Not tainted 4.10.0+ #269
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
Call Trace:
 <IRQ>
 __dump_stack lib/dump_stack.c:15 [inline]
 dump_stack+0x2ee/0x3ef lib/dump_stack.c:51
 kasan_object_err+0x1c/0x70 mm/kasan/report.c:166
 print_address_description mm/kasan/report.c:204 [inline]
 kasan_report_error mm/kasan/report.c:288 [inline]
 kasan_report.part.2+0x198/0x440 mm/kasan/report.c:310
 kasan_report mm/kasan/report.c:331 [inline]
 __asan_report_load8_noabort+0x29/0x30 mm/kasan/report.c:331
 dccp_feat_activate_values+0x94c/0xa90 net/dccp/feat.c:1541
 dccp_create_openreq_child+0x464/0x610 net/dccp/minisocks.c:121
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
 net_rx_action+0xf0a/0x1980 net/core/dev.c:5236
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
 dccp_xmit_packet+0x20f/0x750 net/dccp/output.c:280
 dccp_write_xmit+0x168/0x1d0 net/dccp/output.c:362
 dccp_sendmsg+0x793/0xb00 net/dccp/proto.c:796
 inet_sendmsg+0x164/0x5b0 net/ipv4/af_inet.c:761
 sock_sendmsg_nosec net/socket.c:633 [inline]
 sock_sendmsg+0xca/0x110 net/socket.c:643
 SYSC_sendto+0x660/0x810 net/socket.c:1685
 SyS_sendto+0x40/0x50 net/socket.c:1653
 entry_SYSCALL_64_fastpath+0x1f/0xc2
RIP: 0033:0x4458d9
RSP: 002b:00007f59f536bb58 EFLAGS: 00000282 ORIG_RAX: 000000000000002c
RAX: ffffffffffffffda RBX: 000000000000001a RCX: 00000000004458d9
RDX: 0000000000000037 RSI: 0000000020e62000 RDI: 000000000000001a
RBP: 00000000006e1b90 R08: 0000000020e62fe0 R09: 0000000000000020
R10: 0000000000008000 R11: 0000000000000282 R12: 0000000000708150
R13: 0000000020d0aff8 R14: 0000000000000004 R15: 0000000000000000
Object at ffff880059f18980, in cache kmalloc-64 size: 64
Allocated:
PID = 3932
 save_stack_trace+0x16/0x20 arch/x86/kernel/stacktrace.c:57
 save_stack+0x43/0xd0 mm/kasan/kasan.c:502
 set_track mm/kasan/kasan.c:514 [inline]
 kasan_kmalloc+0xaa/0xd0 mm/kasan/kasan.c:605
 kmem_cache_alloc_trace+0x10b/0x6e0 mm/slab.c:3637
 kmalloc include/linux/slab.h:490 [inline]
 dccp_feat_entry_new+0x20b/0x400 net/dccp/feat.c:467
 dccp_feat_push_change+0x38/0x220 net/dccp/feat.c:487
 __feat_register_sp+0x223/0x2f0 net/dccp/feat.c:741
 dccp_feat_propagate_ccid+0x22b/0x2b0 net/dccp/feat.c:949
 dccp_feat_server_ccid_dependencies+0x1b3/0x250 net/dccp/feat.c:1012
 dccp_make_response+0x1f1/0xc50 net/dccp/output.c:423
 dccp_v6_send_response+0x4ec/0xc20 net/dccp/ipv6.c:217
 dccp_v6_conn_request+0xab2/0x1100 net/dccp/ipv6.c:377
 dccp_rcv_state_process+0x50c/0x1650 net/dccp/input.c:606
 dccp_v6_do_rcv+0x20d/0x350 net/dccp/ipv6.c:632
 sk_backlog_rcv include/net/sock.h:896 [inline]
 __sk_receive_skb+0x350/0xca0 net/core/sock.c:479
 dccp_v6_rcv+0xb17/0x1d10 net/dccp/ipv6.c:742
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
 net_rx_action+0xf0a/0x1980 net/core/dev.c:5236
 __do_softirq+0x31f/0xbe7 kernel/softirq.c:284
Freed:
PID = 24
 save_stack_trace+0x16/0x20 arch/x86/kernel/stacktrace.c:57
 save_stack+0x43/0xd0 mm/kasan/kasan.c:502
 set_track mm/kasan/kasan.c:514 [inline]
 kasan_slab_free+0x6f/0xb0 mm/kasan/kasan.c:578
 __cache_free mm/slab.c:3513 [inline]
 kfree+0xd3/0x250 mm/slab.c:3830
 dccp_feat_entry_destructor.part.4+0x48/0x60 net/dccp/feat.c:418
 dccp_feat_entry_destructor net/dccp/feat.c:416 [inline]
 dccp_feat_list_pop net/dccp/feat.c:541 [inline]
 dccp_feat_activate_values+0x57f/0xa90 net/dccp/feat.c:1543
 dccp_create_openreq_child+0x464/0x610 net/dccp/minisocks.c:121
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
 net_rx_action+0xf0a/0x1980 net/core/dev.c:5236
 __do_softirq+0x31f/0xbe7 kernel/softirq.c:284
Memory state around the buggy address:
 ffff880059f18880: 00 00 00 00 00 fc fc fc fc fc fc fc fc fc fc fc
 ffff880059f18900: 00 00 00 00 00 fc fc fc fc fc fc fc fc fc fc fc
>ffff880059f18980: fb fb fb fb fb fb fb fb fc fc fc fc fc fc fc fc
                            ^
 ffff880059f18a00: fb fb fb fb fb fb fb fb fc fc fc fc fc fc fc fc
 ffff880059f18a80: 00 00 00 00 00 fc fc fc fc fc fc fc fc fc fc fc
=================================
