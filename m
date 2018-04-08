From: Eric Biggers <ebiggers3@gmail.com>
Date: Sun, 08 Apr 2018 21:57:07 +0000
Subject: Re: BUG: please report to dccp@vger.kernel.org => prev = 0, last = 0 at net/dccp/ccids/lib/packet_hi
Message-Id: <20180408215707.GE685@sol.localdomain>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Thu, Jan 18, 2018 at 01:34:02AM -0800, syzbot wrote:
> syzbot has found reproducer for the following crash on linux-next commit
> a362f6d2cdbd089dd7040ba66dcb0ad276a20cf7 (Thu Jan 18 07:07:54 2018 +0000)
> Add linux-next specific files for 20180118
> 
> So far this crash happened 185 times on linux-next, mmots, net-next,
> upstream.
> C reproducer is attached.
> syzkaller reproducer is attached.
> Raw console output is attached.
> compiler: gcc (GCC) 7.1.1 20170620
> .config is attached.
> 
> IMPORTANT: if you fix the bug, please add the following tag to the commit:
> Reported-by:
> syzbot+3ca02e1a9272a28e8959b32039154c5605164653@syzkaller.appspotmail.com
> It will help syzbot understand when the bug is fixed.
> 
> BUG: please report to dccp@vger.kernel.org => prev = 0, last = 0 at
> net/dccp/ccids/lib/packet_history.c:425/tfrc_rx_hist_sample_rtt()
> CPU: 1 PID: 6246 Comm: syzkaller158939 Not tainted 4.15.0-rc8-next-20180118+
> #100
> Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS
> Google 01/01/2011
> Call Trace:
>  <IRQ>
>  __dump_stack lib/dump_stack.c:17 [inline]
>  dump_stack+0x194/0x257 lib/dump_stack.c:53
>  tfrc_rx_hist_sample_rtt+0x407/0x4d0 net/dccp/ccids/lib/packet_history.c:422
>  ccid3_hc_rx_packet_recv+0x696/0xeb3 net/dccp/ccids/ccid3.c:765
>  ccid_hc_rx_packet_recv net/dccp/ccid.h:185 [inline]
>  dccp_deliver_input_to_ccids+0xd9/0x250 net/dccp/input.c:180
>  dccp_rcv_established+0x88/0xb0 net/dccp/input.c:378
>  dccp_v4_do_rcv+0x135/0x160 net/dccp/ipv4.c:653
>  sk_backlog_rcv include/net/sock.h:908 [inline]
>  __sk_receive_skb+0x33e/0xc10 net/core/sock.c:513
>  dccp_v4_rcv+0xf5f/0x1c80 net/dccp/ipv4.c:874
>  ip_local_deliver_finish+0x2f1/0xc50 net/ipv4/ip_input.c:216
>  NF_HOOK include/linux/netfilter.h:288 [inline]
>  ip_local_deliver+0x1ce/0x6e0 net/ipv4/ip_input.c:257
>  dst_input include/net/dst.h:449 [inline]
>  ip_rcv_finish+0x953/0x1e30 net/ipv4/ip_input.c:397
>  NF_HOOK include/linux/netfilter.h:288 [inline]
>  ip_rcv+0xc5a/0x1840 net/ipv4/ip_input.c:493
>  __netif_receive_skb_core+0x1a41/0x3460 net/core/dev.c:4537
>  __netif_receive_skb+0x2c/0x1b0 net/core/dev.c:4602
>  process_backlog+0x203/0x740 net/core/dev.c:5282
>  napi_poll net/core/dev.c:5680 [inline]
>  net_rx_action+0x792/0x1910 net/core/dev.c:5746
>  __do_softirq+0x2d7/0xb85 kernel/softirq.c:285
>  do_softirq_own_stack+0x2a/0x40 arch/x86/entry/entry_64.S:1150
>  </IRQ>
>  do_softirq.part.19+0x14d/0x190 kernel/softirq.c:329
>  do_softirq kernel/softirq.c:177 [inline]
>  __local_bh_enable_ip+0x1ee/0x230 kernel/softirq.c:182
>  local_bh_enable include/linux/bottom_half.h:32 [inline]
>  rcu_read_unlock_bh include/linux/rcupdate.h:726 [inline]
>  ip_finish_output2+0x962/0x1550 net/ipv4/ip_output.c:231
>  ip_finish_output+0x864/0xd10 net/ipv4/ip_output.c:317
>  NF_HOOK_COND include/linux/netfilter.h:277 [inline]
>  ip_output+0x1d2/0x860 net/ipv4/ip_output.c:405
>  dst_output include/net/dst.h:443 [inline]
>  ip_local_out+0x95/0x160 net/ipv4/ip_output.c:124
>  ip_queue_xmit+0x8c0/0x18e0 net/ipv4/ip_output.c:504
>  dccp_transmit_skb+0x9ac/0x10f0 net/dccp/output.c:142
>  dccp_xmit_packet+0x215/0x740 net/dccp/output.c:281
>  dccp_write_xmit+0x17d/0x1d0 net/dccp/output.c:363
>  dccp_sendmsg+0x95f/0xdc0 net/dccp/proto.c:813
>  inet_sendmsg+0x11f/0x5e0 net/ipv4/af_inet.c:764
>  sock_sendmsg_nosec net/socket.c:630 [inline]
>  sock_sendmsg+0xca/0x110 net/socket.c:640
>  ___sys_sendmsg+0x767/0x8b0 net/socket.c:2020
>  __sys_sendmsg+0xe5/0x210 net/socket.c:2054
>  SYSC_sendmsg net/socket.c:2065 [inline]
>  SyS_sendmsg+0x2d/0x50 net/socket.c:2061
>  entry_SYSCALL_64_fastpath+0x29/0xa0
> RIP: 0033:0x446469
> RSP: 002b:00007fcecb23bda8 EFLAGS: 00000293 ORIG_RAX: 000000000000002e
> RAX: ffffffffffffffda RBX: 00000000006dbc3c RCX: 0000000000446469
> RDX: 0000000000000080 RSI: 00000000206c8000 RDI: 0000000000000005
> RBP: 00000000006dbc38 R08: 0000000000000000 R09: 0000000000000000
> R10: 0000000000000000 R11: 0000000000000293 R12: f8e4cbe49e572d45
> R13: 54c1b85d98aba1df R14: a6eaa24dbeb18c29 R15: 000000000000000c
> 

This is still happening.  It *might* be related to the other bug "suspicious RCU
usage at ./include/net/inet_sock.h:LINE".  Here's a simplified reproducer for
this one:

#include <linux/dccp.h>
#include <linux/in.h>
#include <sys/socket.h>
#include <sys/wait.h>
#include <unistd.h>

int main()
{
        struct sockaddr_in addr = { .sin_family = AF_INET };
        socklen_t addrlen = sizeof(addr);
        int fd;

        while (fork())
                wait(NULL);
        fd = socket(AF_INET, SOCK_DCCP, 0);
        bind(fd, (void *)&addr, addrlen);
        getsockname(fd, (void *)&addr, &addrlen);
        listen(fd, 100);
        if (fork()) {
                fd = socket(AF_INET, SOCK_DCCP, 0);
                setsockopt(fd, SOL_DCCP, DCCP_SOCKOPT_CCID, "\x03", 1);
                connect(fd, (void *)&addr, sizeof(addr));
        } else {
                fd = accept(fd, NULL, 0);
        }
        for (int i = 0; i < 1000; i++)
                write(fd, "X", 1);
}
