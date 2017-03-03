From: Dmitry Vyukov <dvyukov@google.com>
Date: Fri, 03 Mar 2017 15:12:12 +0000
Subject: Re: net/dccp: use-after-free in dccp_feat_activate_values
Message-Id: <CACT4Y+ZhNzcKTODGkD3R-68KgkOtYCaf4cZYPH51=HhREXVPGg@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <CAM_iQpUVusW6YJqSgXSo2hAA2dCZGYxw4h+A1_iBpaiYMsXDMA@mail.gmail.com>
In-Reply-To: <CAM_iQpUVusW6YJqSgXSo2hAA2dCZGYxw4h+A1_iBpaiYMsXDMA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Fri, Mar 3, 2017 at 4:06 PM, Dmitry Vyukov <dvyukov@google.com> wrote:
> On Fri, Mar 3, 2017 at 3:48 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> On Fri, 2017-03-03 at 06:32 -0800, Eric Dumazet wrote:
>>> On Fri, 2017-03-03 at 15:11 +0100, Dmitry Vyukov wrote:
>>> > On Mon, Feb 13, 2017 at 11:29 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
>>> > > On Mon, Feb 13, 2017 at 11:19 AM, Andrey Konovalov
>>> > > <andreyknvl@google.com> wrote:
>>> > >> Hi,
>>> > >>
>>> > >> I've got the following error report while fuzzing the kernel with syzkaller.
>>> > >>
>>> > >> On commit 926af6273fc683cd98cd0ce7bf0d04a02eed6742.
>>> > >>
>>> > >> A reproducer and .config are attached.
>>> > >> Note, that it takes quite some time to trigger the bug (up to 10 minutes).
>>> > >>
>>> > >> BUG: KASAN: use-after-free in dccp_feat_activate_values+0x967/0xab0
>>> > >> net/dccp/feat.c:1541 at addr ffff88003713be68
>>> > >> Read of size 8 by task syz-executor2/8457
>>> > >> CPU: 2 PID: 8457 Comm: syz-executor2 Not tainted 4.10.0-rc7+ #127
>>> > >> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
>>> > >> Call Trace:
>>> > >>  <IRQ>
>>> > >>  __dump_stack lib/dump_stack.c:15 [inline]
>>> > >>  dump_stack+0x292/0x398 lib/dump_stack.c:51
>>> > >>  kasan_object_err+0x1c/0x70 mm/kasan/report.c:162
>>> > >>  print_address_description mm/kasan/report.c:200 [inline]
>>> > >>  kasan_report_error mm/kasan/report.c:289 [inline]
>>> > >>  kasan_report.part.1+0x20e/0x4e0 mm/kasan/report.c:311
>>> > >>  kasan_report mm/kasan/report.c:332 [inline]
>>> > >>  __asan_report_load8_noabort+0x29/0x30 mm/kasan/report.c:332
>>> > >>  dccp_feat_activate_values+0x967/0xab0 net/dccp/feat.c:1541
>>> > >>  dccp_create_openreq_child+0x464/0x610 net/dccp/minisocks.c:121
>>> > >>  dccp_v6_request_recv_sock+0x1f6/0x1960 net/dccp/ipv6.c:457
>>> > >>  dccp_check_req+0x335/0x5a0 net/dccp/minisocks.c:186
>>> > >>  dccp_v6_rcv+0x69e/0x1d00 net/dccp/ipv6.c:711
>>> > >>  ip6_input_finish+0x46d/0x17a0 net/ipv6/ip6_input.c:279
>>> > >>  NF_HOOK include/linux/netfilter.h:257 [inline]
>>> > >>  ip6_input+0xdb/0x590 net/ipv6/ip6_input.c:322
>>> > >>  dst_input include/net/dst.h:507 [inline]
>>> > >>  ip6_rcv_finish+0x289/0x890 net/ipv6/ip6_input.c:69
>>> > >>  NF_HOOK include/linux/netfilter.h:257 [inline]
>>> > >>  ipv6_rcv+0x12ec/0x23d0 net/ipv6/ip6_input.c:203
>>> > >>  __netif_receive_skb_core+0x1ae5/0x3400 net/core/dev.c:4190
>>> > >>  __netif_receive_skb+0x2a/0x170 net/core/dev.c:4228
>>> > >>  process_backlog+0xe5/0x6c0 net/core/dev.c:4839
>>> > >>  napi_poll net/core/dev.c:5202 [inline]
>>> > >>  net_rx_action+0xe70/0x1900 net/core/dev.c:5267
>>> > >>  __do_softirq+0x2fb/0xb7d kernel/softirq.c:284
>>> > >>  do_softirq_own_stack+0x1c/0x30 arch/x86/entry/entry_64.S:902
>>> > >
>>> > >
>>> > > Seems there is a race condition between iterating dccp_feat_entry
>>> > > and freeing it, bh_lock_sock() seems not held in this path.
>>> >
>>> >
>>> >
>>> > Cong, where exactly do we need to add bh_lock_sock()?
>>> >
>>> > I am still seeing this on 4977ab6e92e267afe9d8f78438c3db330ca8434c
>>>
>>>
>>> I would try :
>>
>> Or something that would compile. I will take a deeper look after my
>> commute.
>
>
> Something that compiles is definitely better :)
> Reapplied.
>
>
>> diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
>> index 409d0cfd34474812c3bf74f26cd423a3d65ee441..56f883b301ccd610fc24efeac4fb47d3c2f95ecf 100644
>> --- a/net/dccp/ipv4.c
>> +++ b/net/dccp/ipv4.c
>> @@ -482,7 +482,11 @@ static int dccp_v4_send_response(const struct sock *sk, struct request_sock *req
>>         if (dst = NULL)
>>                 goto out;
>>
>> +       /* DCCP is not ready yet for lockless SYN processing */
>> +       bh_lock_sock((struct sock *)sk);
>>         skb = dccp_make_response(sk, dst, req);
>> +       bh_unlock_sock((struct sock *)sk);
>> +
>>         if (skb != NULL) {
>>                 const struct inet_request_sock *ireq = inet_rsk(req);
>>                 struct dccp_hdr *dh = dccp_hdr(skb);
>> diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
>> index 233b57367758c64c09ed40f7359cb8fcb1918d93..673f45f85b7c755c8165c6274ffb6b1fe5660683 100644
>> --- a/net/dccp/ipv6.c
>> +++ b/net/dccp/ipv6.c
>> @@ -214,7 +214,11 @@ static int dccp_v6_send_response(const struct sock *sk, struct request_sock *req
>>                 goto done;
>>         }
>>
>> +       /* DCCP is not ready yet for lockless SYN processing */
>> +       bh_lock_sock((struct sock *)sk);
>>         skb = dccp_make_response(sk, dst, req);
>> +       bh_unlock_sock((struct sock *)sk);
>> +
>>         if (skb != NULL) {
>>                 struct dccp_hdr *dh = dccp_hdr(skb);
>>                 struct ipv6_txoptions *opt;
>>
>>


The first bot that picked this up started spewing:

BUG: spinlock recursion on CPU#1, syz-executor2/9452
 lock: 0xffff8801cd09abc8, .magic: dead4ead, .owner:
syz-executor2/9452, .owner_cpu: 1
CPU: 1 PID: 9452 Comm: syz-executor2 Not tainted 4.10.0+ #14
Hardware name: Google Google Compute Engine/Google Compute Engine,
BIOS Google 01/01/2011
Call Trace:
 <IRQ>
 __dump_stack lib/dump_stack.c:15 [inline]
 dump_stack+0x2ee/0x3ef lib/dump_stack.c:51
 spin_dump+0x14d/0x280 kernel/locking/spinlock_debug.c:67
 spin_bug kernel/locking/spinlock_debug.c:75 [inline]
 debug_spin_lock_before kernel/locking/spinlock_debug.c:84 [inline]
 do_raw_spin_lock+0x3dd/0x5b0 kernel/locking/spinlock_debug.c:135
 __raw_spin_lock include/linux/spinlock_api_smp.h:145 [inline]
 _raw_spin_lock+0x3b/0x50 kernel/locking/spinlock.c:151
 spin_lock include/linux/spinlock.h:302 [inline]
 dccp_v6_send_response+0x4f0/0xc40 net/dccp/ipv6.c:217
 dccp_v6_conn_request+0xab2/0x1100 net/dccp/ipv6.c:379
 dccp_rcv_state_process+0x51d/0x1680 net/dccp/input.c:611
 dccp_v6_do_rcv+0x20d/0x350 net/dccp/ipv6.c:634
 sk_backlog_rcv include/net/sock.h:893 [inline]
 __sk_receive_skb+0x350/0xca0 net/core/sock.c:479
 dccp_v6_rcv+0xb17/0x1d10 net/dccp/ipv6.c:744
 ip6_input_finish+0x45b/0x1700 net/ipv6/ip6_input.c:279
 NF_HOOK include/linux/netfilter.h:257 [inline]
 ip6_input+0xdb/0x580 net/ipv6/ip6_input.c:322
 dst_input include/net/dst.h:507 [inline]
 ip6_rcv_finish+0x194/0x720 net/ipv6/ip6_input.c:69
 NF_HOOK include/linux/netfilter.h:257 [inline]
 ipv6_rcv+0x12d6/0x23b0 net/ipv6/ip6_input.c:203
 __netif_receive_skb_core+0x1fb9/0x3390 net/core/dev.c:4224
 __netif_receive_skb+0x2a/0x170 net/core/dev.c:4262
 process_backlog+0x11e/0x730 net/core/dev.c:4873
 napi_poll net/core/dev.c:5236 [inline]
 net_rx_action+0xeb4/0x1580 net/core/dev.c:5301
 __do_softirq+0x31f/0xbe7 kernel/softirq.c:284
 do_softirq_own_stack+0x1c/0x30 arch/x86/entry/entry_64.S:902
 </IRQ>
 do_softirq.part.21+0x2c0/0x300 kernel/softirq.c:328
 do_softirq kernel/softirq.c:176 [inline]
 __local_bh_enable_ip+0x24c/0x290 kernel/softirq.c:181
 local_bh_enable include/linux/bottom_half.h:31 [inline]
 rcu_read_unlock_bh include/linux/rcupdate.h:971 [inline]
 ip6_finish_output2+0xb0c/0x22f0 net/ipv6/ip6_output.c:123
 ip6_finish_output+0x2f9/0x950 net/ipv6/ip6_output.c:148
 NF_HOOK_COND include/linux/netfilter.h:246 [inline]
 ip6_output+0x1cb/0x8c0 net/ipv6/ip6_output.c:162
 ip6_xmit+0xc36/0x1e90 include/net/dst.h:501
 inet6_csk_xmit+0x320/0x5d0 net/ipv6/inet6_connection_sock.c:179
 dccp_transmit_skb+0xac5/0x10e0 net/dccp/output.c:141
 dccp_connect+0x376/0x680 net/dccp/output.c:563
 dccp_v6_connect+0xcbe/0x18c0 net/dccp/ipv6.c:916
 __inet_stream_connect+0x882/0xea0 net/ipv4/af_inet.c:604
 inet_stream_connect+0x55/0xa0 net/ipv4/af_inet.c:665
 SYSC_connect+0x251/0x580 net/socket.c:1579
 SyS_connect+0x24/0x30 net/socket.c:1560
 entry_SYSCALL_64_fastpath+0x1f/0xc2
RIP: 0033:0x44fb79
RSP: 002b:00007fa5aef1ab58 EFLAGS: 00000212 ORIG_RAX: 000000000000002a
RAX: ffffffffffffffda RBX: 0000000020e5afe0 RCX: 000000000044fb79
RDX: 0000000000000020 RSI: 0000000020e5afe0 RDI: 0000000000000005
RBP: 0000000000000005 R08: 0000000000000000 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000212 R12: 0000000000708000
R13: 0000000000000006 R14: 0000000000000000 R15: 0000000000000000
