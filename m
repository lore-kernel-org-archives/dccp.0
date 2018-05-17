From: Dmitry Vyukov <dvyukov@google.com>
Date: Thu, 17 May 2018 16:09:31 +0000
Subject: Re: suspicious RCU usage at ./include/net/inet_sock.h:LINE
Message-Id: <CACT4Y+a_0qXgZkXMmcFpb1RB9xcrMpMBhs574RiHLfOk-ZwcXQ@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Sun, Apr 8, 2018 at 9:29 PM, Eric Biggers <ebiggers3@gmail.com> wrote:
>> syzkaller has found reproducer for the following crash on
>> fba961ab29e5ffb055592442808bb0f7962e05da
>> git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git/master
>> compiler: gcc (GCC) 7.1.1 20170620
>> .config is attached
>> Raw console output is attached.
>> C reproducer is attached
>> syzkaller reproducer is attached. See https://goo.gl/kgGztJ
>> for information about syzkaller reproducers
>>
>>
>> Can not set IPV6_FL_F_REFLECT if flowlabel_consistency sysctl is enable
>>
>> ==============>> WARNING: suspicious RCU usage
>> 4.15.0-rc4+ #164 Not tainted
>> -----------------------------
>> ./include/net/inet_sock.h:136 suspicious rcu_dereference_check() usage!
>>
>> other info that might help us debug this:
>>
>>
>> rcu_scheduler_active = 2, debug_locks = 1
>> 1 lock held by syzkaller667189/5780:
>>  #0:  (sk_lock-AF_INET6){+.+.}, at: [<000000008d7d4e62>] lock_sock
>> include/net/sock.h:1462 [inline]
>>  #0:  (sk_lock-AF_INET6){+.+.}, at: [<000000008d7d4e62>]
>> do_ipv6_setsockopt.isra.9+0x23d/0x38f0 net/ipv6/ipv6_sockglue.c:167
>>
>> stack backtrace:
>> CPU: 0 PID: 5780 Comm: syzkaller667189 Not tainted 4.15.0-rc4+ #164
>> Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS
>> Google 01/01/2011
>> Call Trace:
>>  __dump_stack lib/dump_stack.c:17 [inline]
>>  dump_stack+0x194/0x257 lib/dump_stack.c:53
>>  lockdep_rcu_suspicious+0x123/0x170 kernel/locking/lockdep.c:4585
>>  ireq_opt_deref include/net/inet_sock.h:135 [inline]
>>  inet_csk_route_req+0x824/0xca0 net/ipv4/inet_connection_sock.c:544
>>  dccp_v4_send_response+0xa7/0x640 net/dccp/ipv4.c:485
>>  dccp_v4_conn_request+0x9ee/0x11b0 net/dccp/ipv4.c:633
>>  dccp_v6_conn_request+0xd30/0x1350 net/dccp/ipv6.c:317
>>  dccp_rcv_state_process+0x574/0x1620 net/dccp/input.c:612
>>  dccp_v4_do_rcv+0xeb/0x160 net/dccp/ipv4.c:682
>>  dccp_v6_do_rcv+0x81a/0x9b0 net/dccp/ipv6.c:578
>>  sk_backlog_rcv include/net/sock.h:907 [inline]
>>  __release_sock+0x124/0x360 net/core/sock.c:2274
>>  release_sock+0xa4/0x2a0 net/core/sock.c:2789
>>  do_ipv6_setsockopt.isra.9+0x50f/0x38f0 net/ipv6/ipv6_sockglue.c:898
>>  ipv6_setsockopt+0xd7/0x150 net/ipv6/ipv6_sockglue.c:922
>>  dccp_setsockopt+0x85/0xd0 net/dccp/proto.c:573
>>  sock_common_setsockopt+0x95/0xd0 net/core/sock.c:2978
>>  SYSC_setsockopt net/socket.c:1821 [inline]
>>  SyS_setsockopt+0x189/0x360 net/socket.c:1800
>>  entry_SYSCALL_64_fastpath+0x1f/0x96
>> RIP: 0033:0x445ec9
>> RSP: 002b:00007fa001b58db8 EFLAGS: 00000297 ORIG_RAX: 0000000000000036
>> RAX: ffffffffffffffda RBX: 00000000006dbc24 RCX: 0000000000445ec9
>> RDX: 0000000000000020 RSI: 0000000000000029 RDI: 0000000000000004
>> RBP: 00000000006dbc20 R08: 0000000000000020 R09: 0000000000000000
>> R10: 000000002030a000 R11: 0000000000000297 R12: 0000000000000000
>> R13: 00007fff809eec1f R14: 00007fa001b599c0 R15: 0000000000000001
>>
>> ==============>> WARNING: suspicious RCU usage
>> 4.15.0-rc4+ #164 Not tainted
>> -----------------------------
>> ./include/net/inet_sock.h:136 suspicious rcu_dereference_check() usage!
>>
>> other info that might help us debug this:
>>
>>
>> rcu_scheduler_active = 2, debug_locks = 1
>> 1 lock held by syzkaller667189/5780:
>>  #0:  (sk_lock-AF_INET6){+.+.}, at: [<000000008d7d4e62>] lock_sock
>> include/net/sock.h:1462 [inline]
>>  #0:  (sk_lock-AF_INET6){+.+.}, at: [<000000008d7d4e62>]
>> do_ipv6_setsockopt.isra.9+0x23d/0x38f0 net/ipv6/ipv6_sockglue.c:167
>>
>> stack backtrace:
>> CPU: 0 PID: 5780 Comm: syzkaller667189 Not tainted 4.15.0-rc4+ #164
>> Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS
>> Google 01/01/2011
>> Call Trace:
>>  __dump_stack lib/dump_stack.c:17 [inline]
>>  dump_stack+0x194/0x257 lib/dump_stack.c:53
>>  lockdep_rcu_suspicious+0x123/0x170 kernel/locking/lockdep.c:4585
>>  ireq_opt_deref include/net/inet_sock.h:135 [inline]
>>  dccp_v4_send_response+0x4b0/0x640 net/dccp/ipv4.c:496
>>  dccp_v4_conn_request+0x9ee/0x11b0 net/dccp/ipv4.c:633
>>  dccp_v6_conn_request+0xd30/0x1350 net/dccp/ipv6.c:317
>>  dccp_rcv_state_process+0x574/0x1620 net/dccp/input.c:612
>>  dccp_v4_do_rcv+0xeb/0x160 net/dccp/ipv4.c:682
>>  dccp_v6_do_rcv+0x81a/0x9b0 net/dccp/ipv6.c:578
>>  sk_backlog_rcv include/net/sock.h:907 [inline]
>>  __release_sock+0x124/0x360 net/core/sock.c:2274
>>  release_sock+0xa4/0x2a0 net/core/sock.c:2789
>>  do_ipv6_setsockopt.isra.9+0x50f/0x38f0 net/ipv6/ipv6_sockglue.c:898
>>  ipv6_setsockopt+0xd7/0x150 net/ipv6/ipv6_sockglue.c:922
>>  dccp_setsockopt+0x85/0xd0 net/dccp/proto.c:573
>>  sock_common_setsockopt+0x95/0xd0 net/core/sock.c:2978
>>  SYSC_setsockopt net/socket.c:1821 [inline]
>>  SyS_setsockopt+0x189/0x360 net/socket.c:1800
>>  entry_SYSCALL_64_fastpath+0x1f/0x96
>> RIP: 0033:0x445ec9
>> RSP: 002b:00007fa001b58db8 EFLAGS: 00000297 ORIG_RAX: 0000000000000036
>> RAX: ffffffffffffffda RBX: 00000000006dbc24 RCX: 0000000000445ec9
>> RDX: 0000000000000020 RSI: 0000000000000029 RDI: 0000000000000004
>> RBP: 00000000006dbc20 R08: 0000000000000020 R09: 0000000000000000
>> R10: 000000002030a000 R11: 0000000000000297 R12: 0000000000000000
>> R13: 00007fff809eec1f R14: 00007fa001b599c0 R15: 0000000000000001
>
> syzbot stopped hitting this for some reason, but the bug is still there.
> Here's a simplified reproducer that works on Linus' tree as of today:
>
> #include <linux/in.h>
> #include <stdlib.h>
> #include <sys/socket.h>
> #include <unistd.h>
>
> int main()
> {
>         int is_parent = (fork() != 0);
>         for (;;) {
>                 int fd = socket(AF_INET, SOCK_DCCP, 0);
>                 struct sockaddr_in addr = {
>                         .sin_family = AF_INET,
>                         .sin_port = htobe16(0x4e23),
>                 };
>                 if (is_parent) {
>                         connect(fd, (void *)&addr, sizeof(addr));
>                 } else {
>                         bind(fd, (void *)&addr, sizeof(addr));
>                         listen(fd, 100);
>                         setsockopt(fd, 0, 0xFFFF, NULL, 0);
>                 }
>                 close(fd);
>         }
> }



Still happens on the current upstream HEAD
e6506eb241871d68647c53cb6d0a16299550ae97.
