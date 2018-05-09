From: Dmitry Vyukov <dvyukov@google.com>
Date: Wed, 09 May 2018 05:23:41 +0000
Subject: Re: BUG: please report to dccp@vger.kernel.org => prev = 0, last = 0 at net/dccp/ccids/lib/packet_hi
Message-Id: <CACT4Y+b7A89ZbBUktiDjBRAtedQHMO2pZqcB4QJSM8vG8NgkGw@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <20180408215707.GE685@sol.localdomain>
In-Reply-To: <20180408215707.GE685@sol.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

On Wed, May 9, 2018 at 7:05 AM, Eric Biggers <ebiggers3@gmail.com> wrote:
> On Sat, May 05, 2018 at 05:57:02PM -0700, syzbot wrote:
>> Hello,
>>
>> syzbot found the following crash on:
>>
>> HEAD commit:    c1c07416cdd4 Merge tag 'kbuild-fixes-v4.17' of git://git=
.k..
>> git tree:       upstream
>> console output: https://syzkaller.appspot.com/x/log.txt?x=13d5de47800000
>> kernel config:  https://syzkaller.appspot.com/x/.config?xZ1dc06635c10d27
>> dashboard link: https://syzkaller.appspot.com/bug?extid=99858724c0ba555a=
12ea
>> compiler:       gcc (GCC) 8.0.1 20180413 (experimental)
>> syzkaller repro:https://syzkaller.appspot.com/x/repro.syz?x=170afde78000=
00
>> C reproducer:   https://syzkaller.appspot.com/x/repro.c?x=141b4be7800000
>>
>> IMPORTANT: if you fix the bug, please add the following tag to the commi=
t:
>> Reported-by: syzbot+99858724c0ba555a12ea@syzkaller.appspotmail.com
>>
>> random: sshd: uninitialized urandom read (32 bytes read)
>> random: sshd: uninitialized urandom read (32 bytes read)
>> random: sshd: uninitialized urandom read (32 bytes read)
>> random: sshd: uninitialized urandom read (32 bytes read)
>> BUG: please report to dccp@vger.kernel.org =3D> prev =3D 0, last =3D 0 at
>> net/dccp/ccids/lib/packet_history.c:425/tfrc_rx_hist_sample_rtt()
>> CPU: 0 PID: 4495 Comm: syz-executor551 Not tainted 4.17.0-rc3+ #34
>> Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS
>> Google 01/01/2011
>> Call Trace:
>>  <IRQ>
>>  __dump_stack lib/dump_stack.c:77 [inline]
>>  dump_stack+0x1b9/0x294 lib/dump_stack.c:113
>>  tfrc_rx_hist_sample_rtt.cold.3+0x54/0x5c
>> net/dccp/ccids/lib/packet_history.c:422
>>  ccid3_hc_rx_packet_recv+0x5c8/0xed0 net/dccp/ccids/ccid3.c:765
>>  ccid_hc_rx_packet_recv net/dccp/ccid.h:185 [inline]
>>  dccp_deliver_input_to_ccids+0xf0/0x280 net/dccp/input.c:180
>>  dccp_rcv_established+0x87/0xb0 net/dccp/input.c:378
>>  dccp_v4_do_rcv+0x153/0x180 net/dccp/ipv4.c:654
>>  sk_backlog_rcv include/net/sock.h:909 [inline]
>>  __sk_receive_skb+0x3a2/0xd60 net/core/sock.c:513
>>  dccp_v4_rcv+0x10e5/0x1f3f net/dccp/ipv4.c:875
>>  ip_local_deliver_finish+0x2e3/0xd80 net/ipv4/ip_input.c:215
>>  NF_HOOK include/linux/netfilter.h:288 [inline]
>>  ip_local_deliver+0x1e1/0x720 net/ipv4/ip_input.c:256
>>  dst_input include/net/dst.h:450 [inline]
>>  ip_rcv_finish+0x81b/0x2200 net/ipv4/ip_input.c:396
>>  NF_HOOK include/linux/netfilter.h:288 [inline]
>>  ip_rcv+0xb70/0x143d net/ipv4/ip_input.c:492
>>  __netif_receive_skb_core+0x26f5/0x3630 net/core/dev.c:4592
>>  __netif_receive_skb+0x2c/0x1e0 net/core/dev.c:4657
>>  process_backlog+0x219/0x760 net/core/dev.c:5337
>>  napi_poll net/core/dev.c:5735 [inline]
>>  net_rx_action+0x7b7/0x1930 net/core/dev.c:5801
>>  __do_softirq+0x2e0/0xaf5 kernel/softirq.c:285
>>  do_softirq_own_stack+0x2a/0x40 arch/x86/entry/entry_64.S:1046
>>  </IRQ>
>>  do_softirq.part.17+0x14d/0x190 kernel/softirq.c:329
>>  do_softirq arch/x86/include/asm/preempt.h:23 [inline]
>>  __local_bh_enable_ip+0x1ec/0x230 kernel/softirq.c:182
>>  local_bh_enable include/linux/bottom_half.h:32 [inline]
>>  rcu_read_unlock_bh include/linux/rcupdate.h:728 [inline]
>>  ip_finish_output2+0xab2/0x1840 net/ipv4/ip_output.c:231
>>  ip_finish_output+0x828/0xf80 net/ipv4/ip_output.c:317
>>  NF_HOOK_COND include/linux/netfilter.h:277 [inline]
>>  ip_output+0x21b/0x850 net/ipv4/ip_output.c:405
>>  dst_output include/net/dst.h:444 [inline]
>>  ip_local_out+0xc5/0x1b0 net/ipv4/ip_output.c:124
>>  ip_queue_xmit+0x9d7/0x1f70 net/ipv4/ip_output.c:504
>>  dccp_transmit_skb+0x999/0x12e0 net/dccp/output.c:142
>>  dccp_xmit_packet+0x250/0x790 net/dccp/output.c:281
>>  dccp_write_xmit+0x190/0x1f0 net/dccp/output.c:363
>>  dccp_sendmsg+0x8c7/0x1020 net/dccp/proto.c:818
>>  inet_sendmsg+0x19f/0x690 net/ipv4/af_inet.c:798
>>  sock_sendmsg_nosec net/socket.c:629 [inline]
>>  sock_sendmsg+0xd5/0x120 net/socket.c:639
>>  ___sys_sendmsg+0x525/0x940 net/socket.c:2117
>>  __sys_sendmmsg+0x240/0x6f0 net/socket.c:2212
>>  __do_sys_sendmmsg net/socket.c:2241 [inline]
>>  __se_sys_sendmmsg net/socket.c:2238 [inline]
>>  __x64_sys_sendmmsg+0x9d/0x100 net/socket.c:2238
>>  do_syscall_64+0x1b1/0x800 arch/x86/entry/common.c:287
>>  entry_SYSCALL_64_after_hwframe+0x49/0xbe
>> RIP: 0033:0x445d09
>> RSP: 002b:00007f3c7eff5d88 EFLAGS: 00000293 ORIG_RAX: 0000000000000133
>> RAX: ffffffffffffffda RBX: 00000000006dac40 RCX: 0000000000445d09
>> RDX: 0000000000000001 RSI: 000000
>>
>>
>> ---
>> This bug is generated by a bot. It may contain errors.
>> See https://goo.gl/tpsmEJ for more information about syzbot.
>> syzbot engineers can be reached at syzkaller@googlegroups.com.
>>
>> syzbot will keep track of this bug report.
>> If you forgot to add the Reported-by tag, once the fix for this bug is
>> merged
>> into any tree, please reply to this email with:
>> #syz fix: exact-commit-title
>> If you want to test a patch for this bug, please reply with:
>> #syz test: git://repo/address.git branch
>> and provide the patch inline or as an attachment.
>> To mark this as a duplicate of another syzbot report, please reply with:
>> #syz dup: exact-subject-of-another-report
>
> There's already a bug report with this title, this one just had a few cha=
racters
> truncated from the end.  Dmitry, is that intentional?  The other one is
> https://groups.google.com/forum/#!msg/syzkaller-bugs/u5nq3PdPkIc/bBFjKHXP=
AgAJ:
>
> #syz dup: BUG: please report to dc...@vger.kernel.org =3D> prev =3D 0, la=
st =3D 0 at net/dccp/ccids/lib/packet_history.c:LINE/tfrc_rx_hist_sample_rt=
t()

I think this happened when we started truncating kernel crash titles
to 120 columns, so it's intentional.
However, the dup command did not pass. It's hard to understand who
received what today, but this suggests that somebody altered email in
the command to dc...@vger.kernel.org:
https://groups.google.com/forum/message/raw?msg=3Dsyzkaller-bugs/GMndq4-h7B=
I/VIz4aBEOAwAJ
We can also mark the old one as invalid.


> Anyway, this is apparently a DCCP bug, and as I posted on the other threa=
d it's
> easily reproducible with the following program.  Gerrit, are you still th=
e DCCP
> maintainer, or is the MAINTAINERS file outdated?
>
>         #include <linux/dccp.h>
>         #include <linux/in.h>
>         #include <sys/socket.h>
>         #include <sys/wait.h>
>         #include <unistd.h>
>
>         int main()
>         {
>                 struct sockaddr_in addr =3D { .sin_family =3D AF_INET };
>                 socklen_t addrlen =3D sizeof(addr);
>                 int fd;
>
>                 while (fork())
>                         wait(NULL);
>                 fd =3D socket(AF_INET, SOCK_DCCP, 0);
>                 bind(fd, (void *)&addr, addrlen);
>                 getsockname(fd, (void *)&addr, &addrlen);
>                 listen(fd, 100);
>                 if (fork()) {
>                         fd =3D socket(AF_INET, SOCK_DCCP, 0);
>                         setsockopt(fd, SOL_DCCP, DCCP_SOCKOPT_CCID, "\x03=
", 1);
>                         connect(fd, (void *)&addr, sizeof(addr));
>                 } else {
>                         fd =3D accept(fd, NULL, 0);
>                 }
>                 for (int i =3D 0; i < 1000; i++)
>                         write(fd, "X", 1);
>         }
>
> - Eric
