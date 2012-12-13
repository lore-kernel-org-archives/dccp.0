From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 13 Dec 2012 23:38:10 +0000
Subject: Re: [PATCH] Fix: kmemleak in tcp_v4/6_syn_recv_sock and dccp_v4/6_request_recv_sock
Message-Id: <1355441890.10504.4.camel@edumazet-glaptop>
List-Id: <dccp.vger.kernel.org>
References: <1355435363-12766-1-git-send-email-christoph.paasch@uclouvain.be>
In-Reply-To: <1355435363-12766-1-git-send-email-christoph.paasch@uclouvain.be>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Thu, 2012-12-13 at 22:49 +0100, Christoph Paasch wrote:
> If in either of the above functions inet_csk_route_child_sock() or
> __inet_inherit_port() fails, the newsk will not be freed:
> 
> unreferenced object 0xffff88022e8a92c0 (size 1592):
>   comm "softirq", pid 0, jiffies 4294946244 (age 726.160s)
>   hex dump (first 32 bytes):
>     0a 01 01 01 0a 01 01 02 00 00 00 00 a7 cc 16 00  ................
>     02 00 03 01 00 00 00 00 00 00 00 00 00 00 00 00  ................
>   backtrace:
>     [<ffffffff8153d190>] kmemleak_alloc+0x21/0x3e
>     [<ffffffff810ab3e7>] kmem_cache_alloc+0xb5/0xc5
>     [<ffffffff8149b65b>] sk_prot_alloc.isra.53+0x2b/0xcd
>     [<ffffffff8149b784>] sk_clone_lock+0x16/0x21e
>     [<ffffffff814d711a>] inet_csk_clone_lock+0x10/0x7b
>     [<ffffffff814ebbc3>] tcp_create_openreq_child+0x21/0x481
>     [<ffffffff814e8fa5>] tcp_v4_syn_recv_sock+0x3a/0x23b
>     [<ffffffff814ec5ba>] tcp_check_req+0x29f/0x416
>     [<ffffffff814e8e10>] tcp_v4_do_rcv+0x161/0x2bc
>     [<ffffffff814eb917>] tcp_v4_rcv+0x6c9/0x701
>     [<ffffffff814cea9f>] ip_local_deliver_finish+0x70/0xc4
>     [<ffffffff814cec20>] ip_local_deliver+0x4e/0x7f
>     [<ffffffff814ce9f8>] ip_rcv_finish+0x1fc/0x233
>     [<ffffffff814cee68>] ip_rcv+0x217/0x267
>     [<ffffffff814a7bbe>] __netif_receive_skb+0x49e/0x553
>     [<ffffffff814a7cc3>] netif_receive_skb+0x50/0x82
> 
> This happens, because sk_clone_lock initializes sk_refcnt to 2, and thus
> a single sock_put() is not enough to free the memory. Additionally, things
> like xfrm, memcg, cookie_values,... may have been initialized.
> We have to free them properly.
> 
> This is fixed by forcing a call to tcp_done(), ending up in
> inet_csk_destroy_sock, doing the final sock_put(). tcp_done() is necessary,
> because it ends up doing all the cleanup on xfrm, memcg, cookie_values,
> xfrm,...
> 
> Before calling tcp_done, we have to set the socket to SOCK_DEAD, to
> force it entering inet_csk_destroy_sock. To avoid the warning in
> inet_csk_destroy_sock, inet_num has to be set to 0.
> As inet_csk_destroy_sock does a dec on orphan_count, we first have to
> increase it.
> 
> Calling tcp_done() allows us to remove the calls to
> tcp_clear_xmit_timer() and tcp_cleanup_congestion_control().
> 
> A similar approach is taken for dccp by calling dccp_done().
> 
> This probably should be backported to kernels >= 3.0 as it is in the
> kernel since 0e734419923bd (ipv4: Use inet_csk_route_child_sock() in
> DCCP and TCP.).

Are you sure the above commit is the bug origin ?

It looks like bug was bring by transparent proxy in 2.6.37

commit 093d282321daeb19c107e5f1f16d7f68484f3ade
Author: Balazs Scheidler <bazsi@balabit.hu>
Date:   Thu Oct 21 13:06:43 2010 +0200

    tproxy: fix hash locking issue when using port redirection in __inet_inherit_port()
    
    When __inet_inherit_port() is called on a tproxy connection the wrong locks are
    held for the inet_bind_bucket it is added to. __inet_inherit_port() made an
    implicit assumption that the listener's port number (and thus its bind bucket).
    Unfortunately, if you're using the TPROXY target to redirect skbs to a
    transparent proxy that assumption is not true anymore and things break.
    
    This patch adds code to __inet_inherit_port() so that it can handle this case
    by looking up or creating a new bind bucket for the child socket and updates
    callers of __inet_inherit_port() to gracefully handle __inet_inherit_port()
    failing.
    
    Reported by and original patch from Stephen Buck <stephen.buck@exinda.com>.
    See http://marc.info/?t8169268200001&r=1&w=2 for the original discussion.
    
    Signed-off-by: KOVACS Krisztian <hidden@balabit.hu>
    Signed-off-by: Patrick McHardy <kaber@trash.net>





