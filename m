From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 05 Jul 2016 17:32:33 +0000
Subject: Re: dccp: potential deadlock in dccp_v4_ctl_send_reset
Message-Id: <1467739953.1273.2.camel@edumazet-glaptop3.roam.corp.google.com>
List-Id: <dccp.vger.kernel.org>
References: <CACT4Y+YX6mx3MroiLGVGTg35y2V0QBHHQecrhQV9bnpEPfDK4Q@mail.gmail.com>
In-Reply-To: <CACT4Y+YX6mx3MroiLGVGTg35y2V0QBHHQecrhQV9bnpEPfDK4Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Tue, 2016-07-05 at 10:17 -0700, Cong Wang wrote:
> On Tue, Jul 5, 2016 at 4:59 AM, Dmitry Vyukov <dvyukov@google.com> wrote:
> > other info that might help us debug this:
> >  Possible unsafe locking scenario:
> >
> >        CPU0
> >        ----
> >   lock(slock-AF_INET);
> >   <Interrupt>
> >     lock(slock-AF_INET);
> >
> >  *** DEADLOCK ***
> >
> > 1 lock held by syz-executor/354:
> >  #0:  (sk_lock-AF_INET){+.+.+.}, at: [<     inline     >] lock_sock
> > include/net/sock.h:1388
> >  #0:  (sk_lock-AF_INET){+.+.+.}, at: [<ffffffff85d193f4>]
> > inet_stream_connect+0x44/0xa0 net/ipv4/af_inet.c:660
> >
> > stack backtrace:
> > CPU: 3 PID: 354 Comm: syz-executor Not tainted 4.7.0-rc5+ #28
> > Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
> >  ffffffff880b58e0 ffff8800361378c0 ffffffff82cc01af ffffffff00000000
> >  fffffbfff1016b1c ffff88003abfe840 ffffffff899bb700 ffff88003abff0a8
> >  ffffffff86cae460 0000000000000001 ffff880036137930 ffffffff8147684d
> > Call Trace:
> >  [<     inline     >] __dump_stack lib/dump_stack.c:15
> >  [<ffffffff82cc01af>] dump_stack+0x12e/0x18f lib/dump_stack.c:51
> >  [<ffffffff8147684d>] print_usage_bug+0x34d/0x3a0 kernel/locking/lockdep.c:2383
> >  [<     inline     >] valid_state kernel/locking/lockdep.c:2396
> >  [<     inline     >] mark_lock_irq kernel/locking/lockdep.c:2594
> >  [<ffffffff8147748c>] mark_lock+0xbec/0xe80 kernel/locking/lockdep.c:3057
> >  [<     inline     >] mark_irqflags kernel/locking/lockdep.c:2933
> >  [<ffffffff814793ce>] __lock_acquire+0xd3e/0x2fb0 kernel/locking/lockdep.c:3287
> >  [<ffffffff8147c293>] lock_acquire+0x1e3/0x460 kernel/locking/lockdep.c:3741
> >  [<     inline     >] __raw_spin_lock include/linux/spinlock_api_smp.h:144
> >  [<ffffffff86a93f83>] _raw_spin_lock+0x33/0x50 kernel/locking/spinlock.c:151
> >  [<     inline     >] spin_lock include/linux/spinlock.h:302
> >  [<ffffffff864831b1>] dccp_v4_ctl_send_reset+0xac1/0x10d0 net/dccp/ipv4.c:530
> >  [<ffffffff864838b9>] dccp_v4_do_rcv+0xf9/0x190 net/dccp/ipv4.c:684
> >  [<     inline     >] sk_backlog_rcv include/net/sock.h:872
> >  [<ffffffff858b42c7>] __release_sock+0x127/0x3a0 net/core/sock.c:2058
> >  [<ffffffff858b4599>] release_sock+0x59/0x1c0 net/core/sock.c:2516
> >  [<ffffffff85d19428>] inet_stream_connect+0x78/0xa0 net/ipv4/af_inet.c:662
> >  [<ffffffff858a62ae>] SYSC_connect+0x23e/0x2e0 net/socket.c:1536
> >  [<ffffffff858ab3d4>] SyS_connect+0x24/0x30 net/socket.c:1517
> >  [<ffffffff86a94e00>] entry_SYSCALL_64_fastpath+0x23/0xc1
> > arch/x86/entry/entry_64.S:207
> 
> This is probably a known deadlock for sk backlog recv path,
> at least the comments on tcp_v4_do_rcv() mentioned this:
> 
> 
>  * We have a potential double-lock case here, so even when
>  * doing backlog processing we use the BH locking scheme.
>  * This is because we cannot sleep with the original spinlock
>  * held.
> 
> the ->sk_backlog_rcv() is called in process context, which
> is not supposed to hold bh_lock_sock, but most of its
> implementations are called in BH context too... Interesting...


Very similar to a previous report in TCP stack, fixed
in commit 47dcc20a39d06585bf3cb9fb381f0e81c20002c3
("ipv4: tcp: ip_send_unicast_reply() is not BH safe")

I would try :

diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index 5c7e413a3ae407e67565b48a8bd6f43e3b02de4d..3cdf5b29ce451e7b7c3290ebb231cf5f4e43f202 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -527,10 +527,12 @@ static void dccp_v4_ctl_send_reset(const struct sock *sk, struct sk_buff *rxskb)
 								 rxiph->daddr);
 	skb_dst_set(skb, dst_clone(dst));
 
+	local_bh_disable();
 	bh_lock_sock(ctl_sk);
 	err = ip_build_and_send_pkt(skb, ctl_sk,
 				    rxiph->daddr, rxiph->saddr, NULL);
 	bh_unlock_sock(ctl_sk);
+	local_bh_enable();
 
 	if (net_xmit_eval(err) = 0) {
 		DCCP_INC_STATS(DCCP_MIB_OUTSEGS);


