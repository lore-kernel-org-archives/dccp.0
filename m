From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Thu, 22 Jun 2006 04:51:41 +0000
Subject: Re: Locking validator output on DCCP
Message-Id: <5640c7e00606212151y213c0bfap5e02a77d9363ebb7@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <5640c7e00606201640wa1ad17fl46a32ceb49513867@mail.gmail.com>
In-Reply-To: <5640c7e00606201640wa1ad17fl46a32ceb49513867@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 6/21/06, Arjan van de Ven <arjan@linux.intel.com> wrote:
> On Wed, 2006-06-21 at 10:34 +1000, Herbert Xu wrote:
> > > As I read this it is not a recursive lock as sk_clone is occurring
> > > second and is actually creating a new socket so they are trying to
> > > lock on different sockets.
> > >
> > > Can someone tell me whether I am correct in my thinking or not? If I
> > > am then I will work out how to tell the lock validator not to worry
> > > about it.
> >
> > I agree, this looks bogus.  Ingo, could you please take a look?
>
> Fix is relatively easy:
>
>
> sk_clone creates a new socket, and thus can never deadlock, and in fact
> can be called with the original socket locked. This therefore is a
> legitimate nesting case; mark it as such.
>
> Signed-off-by: Arjan van de Ven <arjan@linux.intel.com>
>
>
> ---
>  net/core/sock.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> Index: linux-2.6.17-rc6-mm2/net/core/sock.c
> =================================> --- linux-2.6.17-rc6-mm2.orig/net/core/sock.c
> +++ linux-2.6.17-rc6-mm2/net/core/sock.c
> @@ -846,7 +846,7 @@ struct sock *sk_clone(const struct sock
>                 /* SANITY */
>                 sk_node_init(&newsk->sk_node);
>                 sock_lock_init(newsk);
> -               bh_lock_sock(newsk);
> +               bh_lock_sock_nested(newsk);
>
>                 atomic_set(&newsk->sk_rmem_alloc, 0);
>                 atomic_set(&newsk->sk_wmem_alloc, 0);
>
>
When I do this it now shifts around. I'll investigate further
(probably tomorrow).

Now get

Jun 22 14:20:48 localhost kernel: [ 1276.424531]
======================Jun 22 14:20:48 localhost kernel: [ 1276.424541] [ INFO: possible
recursive locking detected ]
Jun 22 14:20:48 localhost kernel: [ 1276.424546]
---------------------------------------------
Jun 22 14:20:48 localhost kernel: [ 1276.424553] idle/0 is trying to
acquire lock:
Jun 22 14:20:48 localhost kernel: [ 1276.424559]
(&sk->sk_lock.slock#5/1){-+..}, at: [<c024594e>] sk_clone+0x5f/0x195
Jun 22 14:20:48 localhost kernel: [ 1276.424585]
Jun 22 14:20:48 localhost kernel: [ 1276.424587] but task is already
holding lock:
Jun 22 14:20:48 localhost kernel: [ 1276.424592]
(&sk->sk_lock.slock#5/1){-+..}, at: [<c027cd87>]
tcp_v4_rcv+0x42e/0x9b3
Jun 22 14:20:48 localhost kernel: [ 1276.424616]
Jun 22 14:20:48 localhost kernel: [ 1276.424618] other info that might
help us debug this:
Jun 22 14:20:48 localhost kernel: [ 1276.424624] 2 locks held by idle/0:
Jun 22 14:20:48 localhost kernel: [ 1276.424628]  #0:
(&tp->rx_lock){-+..}, at: [<e0898915>] rtl8139_poll+0x42/0x41c
[8139too]
Jun 22 14:20:48 localhost kernel: [ 1276.424666]  #1:
(&sk->sk_lock.slock#5/1){-+..}, at: [<c027cd87>]
tcp_v4_rcv+0x42e/0x9b3
Jun 22 14:20:48 localhost kernel: [ 1276.424685]
Jun 22 14:20:48 localhost kernel: [ 1276.424686] stack backtrace:
Jun 22 14:20:48 localhost kernel: [ 1276.425002]  [<c0103a2a>]
show_trace_log_lvl+0x53/0xff
Jun 22 14:20:48 localhost kernel: [ 1276.425038]  [<c0104078>]
show_trace+0x16/0x19
Jun 22 14:20:48 localhost kernel: [ 1276.425068]  [<c010411e>]
dump_stack+0x1a/0x1f
Jun 22 14:20:48 localhost kernel: [ 1276.425099]  [<c012d6cb>]
__lock_acquire+0x8e6/0x902
Jun 22 14:20:48 localhost kernel: [ 1276.425311]  [<c012d879>]
lock_acquire+0x4e/0x66
Jun 22 14:20:48 localhost kernel: [ 1276.425510]  [<c02989e1>]
_spin_lock_nested+0x26/0x36
Jun 22 14:20:48 localhost kernel: [ 1276.425726]  [<c024594e>]
sk_clone+0x5f/0x195
Jun 22 14:20:48 localhost kernel: [ 1276.427191]  [<c026d10f>]
inet_csk_clone+0xf/0x67
Jun 22 14:20:48 localhost kernel: [ 1276.428879]  [<c027d3d0>]
tcp_create_openreq_child+0x15/0x32b
Jun 22 14:20:48 localhost kernel: [ 1276.430598]  [<c027b383>]
tcp_v4_syn_recv_sock+0x47/0x29c
Jun 22 14:20:48 localhost kernel: [ 1276.432313]  [<e0fcf440>]
tcp_v6_syn_recv_sock+0x37/0x534 [ipv6]
Jun 22 14:20:48 localhost kernel: [ 1276.432482]  [<c027d886>]
tcp_check_req+0x1a0/0x2db
Jun 22 14:20:48 localhost kernel: [ 1276.434198]  [<c027aecc>]
tcp_v4_do_rcv+0x9f/0x2fe
Jun 22 14:20:48 localhost kernel: [ 1276.435911]  [<c027d28b>]
tcp_v4_rcv+0x932/0x9b3
Jun 22 14:20:48 localhost kernel: [ 1276.437632]  [<c0265980>]
ip_local_deliver+0x159/0x1f1
Jun 22 14:20:48 localhost kernel: [ 1276.439305]  [<c02657fa>]
ip_rcv+0x3e9/0x416
Jun 22 14:20:48 localhost kernel: [ 1276.440977]  [<c024bba4>]
netif_receive_skb+0x287/0x317
Jun 22 14:20:48 localhost kernel: [ 1276.442542]  [<e0898b67>]
rtl8139_poll+0x294/0x41c [8139too]
Jun 22 14:20:48 localhost kernel: [ 1276.442590]  [<c024d585>]
net_rx_action+0x8b/0x17c
Jun 22 14:20:48 localhost kernel: [ 1276.444160]  [<c011adf6>]
__do_softirq+0x54/0xb3
Jun 22 14:20:48 localhost kernel: [ 1276.444335]  [<c011ae84>]
do_softirq+0x2f/0x47
Jun 22 14:20:48 localhost kernel: [ 1276.444460]  [<c011b0a5>]
irq_exit+0x39/0x46
Jun 22 14:20:48 localhost kernel: [ 1276.444585]  [<c0104f73>] do_IRQ+0x77/0x84
Jun 22 14:20:48 localhost kernel: [ 1276.444621]  [<c0103561>]
common_interrupt+0x25/0x2c



-- 
Ian McDonald
Web: http://wand.net.nz/~iam4
Blog: http://imcdnzl.blogspot.com
WAND Network Research Group
Department of Computer Science
University of Waikato
New Zealand
