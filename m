From: Andrey Konovalov <andreyknvl@google.com>
Date: Sat, 29 Oct 2016 17:06:52 +0000
Subject: Re: net/dccp: warning in dccp_feat_clone_sp_val/__might_sleep
Message-Id: <CAAeHK+y9ENvGzJEQtRy_5DEzCfhGEYXR5CPpgwXy_FoOtFUf3Q@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <CAAeHK+z-SAq-YhHarfc94dguyXCJ_tv8n=ZVdLTRsYEy0cK-pQ@mail.gmail.com>
In-Reply-To: <CAAeHK+z-SAq-YhHarfc94dguyXCJ_tv8n=ZVdLTRsYEy0cK-pQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hi Cong,

Tested with your patch, still getting a warning, though it's a little different:

------------[ cut here ]------------
WARNING: CPU: 1 PID: 3876 at kernel/sched/core.c:7724
__might_sleep+0x14c/0x1a0 kernel/sched/core.c:7719
do not call blocking ops when !TASK_RUNNING; state=1 set at
[<ffffffff811f5a5c>] prepare_to_wait+0xbc/0x210
kernel/sched/wait.c:178
Modules linked in:
CPU: 1 PID: 3876 Comm: a.out Not tainted 4.9.0-rc2+ #325
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
 ffff88006c2d7770 ffffffff81b46914 ffff88006c2d77e8 0000000000000000
 ffffffff84052960 0000000000000000 ffff88006c2d77b8 ffffffff81111237
 0000000041b58ab3 ffffffff00001e2c ffffed000d85aef9 ffffffff84052960
Call Trace:
 [<     inline     >] __dump_stack lib/dump_stack.c:15
 [<ffffffff81b46914>] dump_stack+0xb3/0x10f lib/dump_stack.c:51
 [<ffffffff81111237>] __warn+0x1a7/0x1f0 kernel/panic.c:550
 [<ffffffff8111132c>] warn_slowpath_fmt+0xac/0xd0 kernel/panic.c:565
 [<ffffffff811922fc>] __might_sleep+0x14c/0x1a0 kernel/sched/core.c:7719
 [<     inline     >] slab_pre_alloc_hook mm/slab.h:393
 [<     inline     >] slab_alloc_node mm/slub.c:2634
 [<     inline     >] slab_alloc mm/slub.c:2716
 [<ffffffff815054fb>] kmem_cache_alloc_trace+0x1bb/0x270 mm/slub.c:2733
 [<     inline     >] kmalloc ./include/linux/slab.h:490
 [<ffffffff83889e62>] dccp_feat_entry_new+0x182/0x2a0 net/dccp/feat.c:468
 [<ffffffff8388a1ea>] dccp_feat_push_confirm+0x3a/0x270 net/dccp/feat.c:516
 [<     inline     >] dccp_feat_change_recv net/dccp/feat.c:1160
 [<ffffffff8388d587>] dccp_feat_parse_options+0xb37/0x13d0 net/dccp/feat.c:1412
 [<ffffffff83894f61>] dccp_parse_options+0x721/0x1010 net/dccp/options.c:128
 [<ffffffff838912e0>] dccp_rcv_state_process+0x200/0x15b0 net/dccp/input.c:644
 [<ffffffff838b8af4>] dccp_v4_do_rcv+0xf4/0x1a0 net/dccp/ipv4.c:681
 [<     inline     >] sk_backlog_rcv ./include/net/sock.h:872
 [<ffffffff82b7ceb6>] __release_sock+0x126/0x3a0 net/core/sock.c:2044
 [<ffffffff82b7d189>] release_sock+0x59/0x1c0 net/core/sock.c:2502
 [<     inline     >] inet_wait_for_connect net/ipv4/af_inet.c:547
 [<ffffffff8316b2a2>] __inet_stream_connect+0x5d2/0xbb0 net/ipv4/af_inet.c:617
 [<ffffffff8316b8d5>] inet_stream_connect+0x55/0xa0 net/ipv4/af_inet.c:656
 [<ffffffff82b705e4>] SYSC_connect+0x244/0x2f0 net/socket.c:1533
 [<ffffffff82b72dd4>] SyS_connect+0x24/0x30 net/socket.c:1514
 [<ffffffff83fbf781>] entry_SYSCALL_64_fastpath+0x1f/0xc2
arch/x86/entry/entry_64.S:209
---[ end trace c7e036cf4dc54077 ]---

Thanks!

On Sat, Oct 29, 2016 at 8:10 AM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> On Fri, Oct 28, 2016 at 5:40 PM, Andrey Konovalov <andreyknvl@google.com> wrote:
>> Hi,
>>
>> I've got the following error report while running the syzkaller fuzzer:
>>
>> ------------[ cut here ]------------
>> WARNING: CPU: 0 PID: 4608 at kernel/sched/core.c:7724
>> __might_sleep+0x14c/0x1a0 kernel/sched/core.c:7719
>> do not call blocking ops when !TASK_RUNNING; state=1 set at
>> [<ffffffff811f5a5c>] prepare_to_wait+0xbc/0x210
>> kernel/sched/wait.c:178
>> Modules linked in:
>> CPU: 0 PID: 4608 Comm: syz-executor Not tainted 4.9.0-rc2+ #320
>> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
>>  ffff88006625f7a0 ffffffff81b46914 ffff88006625f818 0000000000000000
>>  ffffffff84052960 0000000000000000 ffff88006625f7e8 ffffffff81111237
>>  ffff88006aceac00 ffffffff00001e2c ffffed000cc4beff ffffffff84052960
>> Call Trace:
>>  [<     inline     >] __dump_stack lib/dump_stack.c:15
>>  [<ffffffff81b46914>] dump_stack+0xb3/0x10f lib/dump_stack.c:51
>>  [<ffffffff81111237>] __warn+0x1a7/0x1f0 kernel/panic.c:550
>>  [<ffffffff8111132c>] warn_slowpath_fmt+0xac/0xd0 kernel/panic.c:565
>>  [<ffffffff811922fc>] __might_sleep+0x14c/0x1a0 kernel/sched/core.c:7719
>>  [<     inline     >] slab_pre_alloc_hook mm/slab.h:393
>>  [<     inline     >] slab_alloc_node mm/slub.c:2634
>>  [<     inline     >] slab_alloc mm/slub.c:2716
>>  [<ffffffff81508da0>] __kmalloc_track_caller+0x150/0x2a0 mm/slub.c:4240
>>  [<ffffffff8146be14>] kmemdup+0x24/0x50 mm/util.c:113
>>  [<ffffffff8388b2cf>] dccp_feat_clone_sp_val.part.5+0x4f/0xe0
>> net/dccp/feat.c:374
>>  [<     inline     >] dccp_feat_clone_sp_val net/dccp/feat.c:1141
>>  [<     inline     >] dccp_feat_change_recv net/dccp/feat.c:1141
>>  [<ffffffff8388d491>] dccp_feat_parse_options+0xaa1/0x13d0 net/dccp/feat.c:1411
>>  [<ffffffff83894f01>] dccp_parse_options+0x721/0x1010 net/dccp/options.c:128
>>  [<ffffffff83891280>] dccp_rcv_state_process+0x200/0x15b0 net/dccp/input.c:644
>>  [<ffffffff838b8a94>] dccp_v4_do_rcv+0xf4/0x1a0 net/dccp/ipv4.c:681
>>  [<     inline     >] sk_backlog_rcv ./include/net/sock.h:872
>>  [<ffffffff82b7ceb6>] __release_sock+0x126/0x3a0 net/core/sock.c:2044
>>  [<ffffffff82b7d189>] release_sock+0x59/0x1c0 net/core/sock.c:2502
>>  [<     inline     >] inet_wait_for_connect net/ipv4/af_inet.c:547
>>  [<ffffffff8316b2a2>] __inet_stream_connect+0x5d2/0xbb0 net/ipv4/af_inet.c:617
>>  [<ffffffff8316b8d5>] inet_stream_connect+0x55/0xa0 net/ipv4/af_inet.c:656
>>  [<ffffffff82b705e4>] SYSC_connect+0x244/0x2f0 net/socket.c:1533
>>  [<ffffffff82b72dd4>] SyS_connect+0x24/0x30 net/socket.c:1514
>>  [<ffffffff83fbf701>] entry_SYSCALL_64_fastpath+0x1f/0xc2
>> arch/x86/entry/entry_64.S:209
>
> Should be fixed the attached patch. I will verify it with your
> reproducer tomorrow.
>
> Thanks!
