From: Dmitry Vyukov <dvyukov@google.com>
Date: Fri, 03 Mar 2017 15:06:40 +0000
Subject: Re: net/dccp: use-after-free in dccp_feat_activate_values
Message-Id: <CACT4Y+Z6t_jGoh3Gm3Sxuu_ugF5kQ3QJ37LVdqoEK_ab52tQMA@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <CAM_iQpUVusW6YJqSgXSo2hAA2dCZGYxw4h+A1_iBpaiYMsXDMA@mail.gmail.com>
In-Reply-To: <CAM_iQpUVusW6YJqSgXSo2hAA2dCZGYxw4h+A1_iBpaiYMsXDMA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Fri, Mar 3, 2017 at 3:48 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Fri, 2017-03-03 at 06:32 -0800, Eric Dumazet wrote:
>> On Fri, 2017-03-03 at 15:11 +0100, Dmitry Vyukov wrote:
>> > On Mon, Feb 13, 2017 at 11:29 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
>> > > On Mon, Feb 13, 2017 at 11:19 AM, Andrey Konovalov
>> > > <andreyknvl@google.com> wrote:
>> > >> Hi,
>> > >>
>> > >> I've got the following error report while fuzzing the kernel with syzkaller.
>> > >>
>> > >> On commit 926af6273fc683cd98cd0ce7bf0d04a02eed6742.
>> > >>
>> > >> A reproducer and .config are attached.
>> > >> Note, that it takes quite some time to trigger the bug (up to 10 minutes).
>> > >>
>> > >> BUG: KASAN: use-after-free in dccp_feat_activate_values+0x967/0xab0
>> > >> net/dccp/feat.c:1541 at addr ffff88003713be68
>> > >> Read of size 8 by task syz-executor2/8457
>> > >> CPU: 2 PID: 8457 Comm: syz-executor2 Not tainted 4.10.0-rc7+ #127
>> > >> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
>> > >> Call Trace:
>> > >>  <IRQ>
>> > >>  __dump_stack lib/dump_stack.c:15 [inline]
>> > >>  dump_stack+0x292/0x398 lib/dump_stack.c:51
>> > >>  kasan_object_err+0x1c/0x70 mm/kasan/report.c:162
>> > >>  print_address_description mm/kasan/report.c:200 [inline]
>> > >>  kasan_report_error mm/kasan/report.c:289 [inline]
>> > >>  kasan_report.part.1+0x20e/0x4e0 mm/kasan/report.c:311
>> > >>  kasan_report mm/kasan/report.c:332 [inline]
>> > >>  __asan_report_load8_noabort+0x29/0x30 mm/kasan/report.c:332
>> > >>  dccp_feat_activate_values+0x967/0xab0 net/dccp/feat.c:1541
>> > >>  dccp_create_openreq_child+0x464/0x610 net/dccp/minisocks.c:121
>> > >>  dccp_v6_request_recv_sock+0x1f6/0x1960 net/dccp/ipv6.c:457
>> > >>  dccp_check_req+0x335/0x5a0 net/dccp/minisocks.c:186
>> > >>  dccp_v6_rcv+0x69e/0x1d00 net/dccp/ipv6.c:711
>> > >>  ip6_input_finish+0x46d/0x17a0 net/ipv6/ip6_input.c:279
>> > >>  NF_HOOK include/linux/netfilter.h:257 [inline]
>> > >>  ip6_input+0xdb/0x590 net/ipv6/ip6_input.c:322
>> > >>  dst_input include/net/dst.h:507 [inline]
>> > >>  ip6_rcv_finish+0x289/0x890 net/ipv6/ip6_input.c:69
>> > >>  NF_HOOK include/linux/netfilter.h:257 [inline]
>> > >>  ipv6_rcv+0x12ec/0x23d0 net/ipv6/ip6_input.c:203
>> > >>  __netif_receive_skb_core+0x1ae5/0x3400 net/core/dev.c:4190
>> > >>  __netif_receive_skb+0x2a/0x170 net/core/dev.c:4228
>> > >>  process_backlog+0xe5/0x6c0 net/core/dev.c:4839
>> > >>  napi_poll net/core/dev.c:5202 [inline]
>> > >>  net_rx_action+0xe70/0x1900 net/core/dev.c:5267
>> > >>  __do_softirq+0x2fb/0xb7d kernel/softirq.c:284
>> > >>  do_softirq_own_stack+0x1c/0x30 arch/x86/entry/entry_64.S:902
>> > >
>> > >
>> > > Seems there is a race condition between iterating dccp_feat_entry
>> > > and freeing it, bh_lock_sock() seems not held in this path.
>> >
>> >
>> >
>> > Cong, where exactly do we need to add bh_lock_sock()?
>> >
>> > I am still seeing this on 4977ab6e92e267afe9d8f78438c3db330ca8434c
>>
>>
>> I would try :
>
> Or something that would compile. I will take a deeper look after my
> commute.


Something that compiles is definitely better :)
Reapplied.


> diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
> index 409d0cfd34474812c3bf74f26cd423a3d65ee441..56f883b301ccd610fc24efeac4fb47d3c2f95ecf 100644
> --- a/net/dccp/ipv4.c
> +++ b/net/dccp/ipv4.c
> @@ -482,7 +482,11 @@ static int dccp_v4_send_response(const struct sock *sk, struct request_sock *req
>         if (dst = NULL)
>                 goto out;
>
> +       /* DCCP is not ready yet for lockless SYN processing */
> +       bh_lock_sock((struct sock *)sk);
>         skb = dccp_make_response(sk, dst, req);
> +       bh_unlock_sock((struct sock *)sk);
> +
>         if (skb != NULL) {
>                 const struct inet_request_sock *ireq = inet_rsk(req);
>                 struct dccp_hdr *dh = dccp_hdr(skb);
> diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
> index 233b57367758c64c09ed40f7359cb8fcb1918d93..673f45f85b7c755c8165c6274ffb6b1fe5660683 100644
> --- a/net/dccp/ipv6.c
> +++ b/net/dccp/ipv6.c
> @@ -214,7 +214,11 @@ static int dccp_v6_send_response(const struct sock *sk, struct request_sock *req
>                 goto done;
>         }
>
> +       /* DCCP is not ready yet for lockless SYN processing */
> +       bh_lock_sock((struct sock *)sk);
>         skb = dccp_make_response(sk, dst, req);
> +       bh_unlock_sock((struct sock *)sk);
> +
>         if (skb != NULL) {
>                 struct dccp_hdr *dh = dccp_hdr(skb);
>                 struct ipv6_txoptions *opt;
>
>
