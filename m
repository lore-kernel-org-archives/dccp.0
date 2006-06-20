From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Tue, 20 Jun 2006 23:40:05 +0000
Subject: Locking validator output on DCCP
Message-Id: <5640c7e00606201640wa1ad17fl46a32ceb49513867@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Folks,

I am getting this when I am using DCCP with 2.6.17-rc6-mm2 with Ingo's
lock dependency patch:

Jun 21 09:38:58 localhost kernel: [  102.068588]
Jun 21 09:38:58 localhost kernel: [  102.068592]
======================Jun 21 09:38:58 localhost kernel: [  102.068602] [ INFO: possible
recursive locking detected ]
Jun 21 09:38:58 localhost kernel: [  102.068608]
---------------------------------------------
Jun 21 09:38:58 localhost kernel: [  102.068615] idle/0 is trying to
acquire lock:
Jun 21 09:38:58 localhost kernel: [  102.068620]
(&sk->sk_lock.slock#3){-+..}, at: [<c0245511>] sk_clone+0x5a/0x190
Jun 21 09:38:58 localhost kernel: [  102.068644]
Jun 21 09:38:58 localhost kernel: [  102.068646] but task is already
holding lock:
Jun 21 09:38:58 localhost kernel: [  102.068651]
(&sk->sk_lock.slock#3){-+..}, at: [<c024650d>]
sk_receive_skb+0xe6/0xfe
Jun 21 09:38:58 localhost kernel: [  102.068668]
Jun 21 09:38:58 localhost kernel: [  102.068670] other info that might
help us debug this:
Jun 21 09:38:58 localhost kernel: [  102.068676] 2 locks held by idle/0:
Jun 21 09:38:58 localhost kernel: [  102.068679]  #0:
(&tp->rx_lock){-+..}, at: [<e087d915>] rtl8139_poll+0x42/0x41c
[8139too]
Jun 21 09:38:58 localhost kernel: [  102.068722]  #1:
(&sk->sk_lock.slock#3){-+..}, at: [<c024650d>]
sk_receive_skb+0xe6/0xfe
Jun 21 09:38:58 localhost kernel: [  102.068739]
Jun 21 09:38:58 localhost kernel: [  102.068741] stack backtrace:
Jun 21 09:38:58 localhost kernel: [  102.069053]  [<c0103a2a>]
show_trace_log_lvl+0x53/0xff
Jun 21 09:38:58 localhost kernel: [  102.069091]  [<c0104078>]
show_trace+0x16/0x19
Jun 21 09:38:58 localhost kernel: [  102.069121]  [<c010411e>]
dump_stack+0x1a/0x1f
Jun 21 09:38:58 localhost kernel: [  102.069151]  [<c012d6cb>]
__lock_acquire+0x8e6/0x902
Jun 21 09:38:58 localhost kernel: [  102.069363]  [<c012d879>]
lock_acquire+0x4e/0x66
Jun 21 09:38:58 localhost kernel: [  102.069562]  [<c029779d>]
_spin_lock+0x24/0x32
Jun 21 09:38:58 localhost kernel: [  102.069777]  [<c0245511>]
sk_clone+0x5a/0x190
Jun 21 09:38:58 localhost kernel: [  102.071244]  [<c026cc93>]
inet_csk_clone+0xf/0x67
Jun 21 09:38:58 localhost kernel: [  102.072932]  [<e0cc7f31>]
dccp_create_openreq_child+0x17/0x2fe [dccp]
Jun 21 09:38:58 localhost kernel: [  102.072993]  [<e0b48c9b>]
dccp_v4_request_recv_sock+0x47/0x260 [dccp_ipv4]
Jun 21 09:38:58 localhost kernel: [  102.073020]  [<e0cc8340>]
dccp_check_req+0x128/0x264 [dccp]
Jun 21 09:38:58 localhost kernel: [  102.073049]  [<e0b48a38>]
dccp_v4_do_rcv+0x74/0x290 [dccp_ipv4]
Jun 21 09:38:58 localhost kernel: [  102.073067]  [<c0246492>]
sk_receive_skb+0x6b/0xfe
Jun 21 09:38:58 localhost kernel: [  102.074607]  [<e0b49e9c>]
dccp_v4_rcv+0x4ea/0x66e [dccp_ipv4]
Jun 21 09:38:58 localhost kernel: [  102.074651]  [<c0265540>]
ip_local_deliver+0x159/0x1f1
Jun 21 09:38:58 localhost kernel: [  102.076322]  [<c02653ba>]
ip_rcv+0x3e9/0x416
Jun 21 09:38:58 localhost kernel: [  102.077995]  [<c024b768>]
netif_receive_skb+0x287/0x317
Jun 21 09:38:58 localhost kernel: [  102.079562]  [<e087db67>]
rtl8139_poll+0x294/0x41c [8139too]
Jun 21 09:38:58 localhost kernel: [  102.079610]  [<c024d149>]
net_rx_action+0x8b/0x17c
Jun 21 09:38:58 localhost kernel: [  102.081181]  [<c011adf6>]
__do_softirq+0x54/0xb3
Jun 21 09:38:58 localhost kernel: [  102.081357]  [<c011ae84>]
do_softirq+0x2f/0x47
Jun 21 09:38:58 localhost kernel: [  102.081482]  [<c011b0a5>]
irq_exit+0x39/0x46
Jun 21 09:38:58 localhost kernel: [  102.081608]  [<c0104f73>] do_IRQ+0x77/0x84
Jun 21 09:38:58 localhost kernel: [  102.081644]  [<c0103561>]
common_interrupt+0x25/0x2c
Jun 21 09:38:58 localhost kernel: [  154.463644] CCID: Registered CCID 3 (ccid3)

The code of sk_clone (net/core/sock.c) is:

struct sock *sk_clone(const struct sock *sk, const gfp_t priority)
{
	struct sock *newsk = sk_alloc(sk->sk_family, priority, sk->sk_prot, 0);

	if (newsk != NULL) {
		struct sk_filter *filter;

		memcpy(newsk, sk, sk->sk_prot->obj_size);

		/* SANITY */
		sk_node_init(&newsk->sk_node);
		sock_lock_init(newsk);

The relevant code is the sock_lock_init

The code of sk_receive_skb (net/core/sock.c) is:

int sk_receive_skb(struct sock *sk, struct sk_buff *skb)
{
	int rc = NET_RX_SUCCESS;

	if (sk_filter(sk, skb, 0))
		goto discard_and_relse;

	skb->dev = NULL;

	bh_lock_sock(sk);

The relevant code is the bh_lock_sock.

As I read this it is not a recursive lock as sk_clone is occurring
second and is actually creating a new socket so they are trying to
lock on different sockets.

Can someone tell me whether I am correct in my thinking or not? If I
am then I will work out how to tell the lock validator not to worry
about it.

Thanks,

Ian
-- 
Ian McDonald
Web: http://wand.net.nz/~iam4
Blog: http://imcdnzl.blogspot.com
WAND Network Research Group
Department of Computer Science
University of Waikato
New Zealand
