From: Andrey Konovalov <andreyknvl@google.com>
Date: Wed, 02 Nov 2016 18:44:12 +0000
Subject: net/dccp: null-ptr-deref in dccp_v4_rcv/selinux_socket_sock_rcv_skb
Message-Id: <CAAeHK+yZ4WF2eXATVFQbe_SKM-MFzXypA6VjGxwUxYV3_4xT9g@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hi,

I've got the following error report while running the syzkaller fuzzer:

IPv4: Attempt to release alive inet socket ffff880068e98940
kasan: CONFIG_KASAN_INLINE enabled
kasan: GPF could be caused by NULL-ptr deref or user memory access
general protection fault: 0000 [#1] SMP KASAN
Modules linked in:
CPU: 1 PID: 3905 Comm: a.out Not tainted 4.9.0-rc3+ #333
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
task: ffff88006b9e0000 task.stack: ffff880068770000
RIP: 0010:[<ffffffff819ead5f>]  [<ffffffff819ead5f>]
selinux_socket_sock_rcv_skb+0xff/0x6a0 security/selinux/hooks.c:4639
RSP: 0018:ffff8800687771c8  EFLAGS: 00010202
RAX: ffff88006b9e0000 RBX: 1ffff1000d0eee3f RCX: 1ffff1000d1d312a
RDX: 1ffff1000d1d31a6 RSI: dffffc0000000000 RDI: 0000000000000010
RBP: ffff880068777360 R08: 0000000000000000 R09: 0000000000000002
R10: dffffc0000000000 R11: 0000000000000006 R12: ffff880068e98940
R13: 0000000000000002 R14: ffff880068777338 R15: 0000000000000000
FS:  00007f00ff760700(0000) GS:ffff88006cd00000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 0000000020008000 CR3: 000000006a308000 CR4: 00000000000006e0
Stack:
 ffff8800687771e0 ffffffff812508a5 ffff8800686f3168 0000000000000007
 ffff88006ac8cdfc ffff8800665ea500 0000000041b58ab3 ffffffff847b5480
 ffffffff819eac60 ffff88006b9e0860 ffff88006b9e0868 ffff88006b9e07f0
Call Trace:
 [<ffffffff819c8dd5>] security_sock_rcv_skb+0x75/0xb0 security/security.c:1317
 [<ffffffff82c2a9e7>] sk_filter_trim_cap+0x67/0x10e0 net/core/filter.c:81
 [<ffffffff82b81e60>] __sk_receive_skb+0x30/0xa00 net/core/sock.c:460
 [<ffffffff838bbf12>] dccp_v4_rcv+0xdb2/0x1910 net/dccp/ipv4.c:873
 [<ffffffff83069d22>] ip_local_deliver_finish+0x332/0xad0
net/ipv4/ip_input.c:216
 [<     inline     >] NF_HOOK_THRESH ./include/linux/netfilter.h:232
 [<     inline     >] NF_HOOK ./include/linux/netfilter.h:255
 [<ffffffff8306abd2>] ip_local_deliver+0x1c2/0x4b0 net/ipv4/ip_input.c:257
 [<     inline     >] dst_input ./include/net/dst.h:507
 [<ffffffff83068500>] ip_rcv_finish+0x750/0x1c40 net/ipv4/ip_input.c:396
 [<     inline     >] NF_HOOK_THRESH ./include/linux/netfilter.h:232
 [<     inline     >] NF_HOOK ./include/linux/netfilter.h:255
 [<ffffffff8306b82f>] ip_rcv+0x96f/0x12f0 net/ipv4/ip_input.c:487
 [<ffffffff82bd9fb7>] __netif_receive_skb_core+0x1897/0x2a50 net/core/dev.c:4213
 [<ffffffff82bdb19a>] __netif_receive_skb+0x2a/0x170 net/core/dev.c:4251
 [<ffffffff82bdb493>] netif_receive_skb_internal+0x1b3/0x390 net/core/dev.c:4279
 [<ffffffff82bdb6b8>] netif_receive_skb+0x48/0x250 net/core/dev.c:4303
 [<ffffffff8241fc75>] tun_get_user+0xbd5/0x28a0 drivers/net/tun.c:1308
 [<ffffffff82421b5a>] tun_chr_write_iter+0xda/0x190 drivers/net/tun.c:1332
 [<     inline     >] new_sync_write fs/read_write.c:499
 [<ffffffff8151bd44>] __vfs_write+0x334/0x570 fs/read_write.c:512
 [<ffffffff8151f85b>] vfs_write+0x17b/0x500 fs/read_write.c:560
 [<     inline     >] SYSC_write fs/read_write.c:607
 [<ffffffff81523184>] SyS_write+0xd4/0x1a0 fs/read_write.c:599
 [<ffffffff83fc02c1>] entry_SYSCALL_64_fastpath+0x1f/0xc2
arch/x86/entry/entry_64.S:209
Code: 31 45 84 c0 74 0a 41 80 f8 01 0f 8e 26 04 00 00 49 8d 7f 10 49
ba 00 00 00 00 00 fc ff df 45 0f b7 6c 24 10 49 89 f9 49 c1 e9 03 <47>
0f b6 1c 11 45 84 db 74 0a 41 80 fb 03 0f 8e 01 04 00 00 41
RIP  [<ffffffff819ead5f>] selinux_socket_sock_rcv_skb+0xff/0x6a0
security/selinux/hooks.c:4639
 RSP <ffff8800687771c8>
---[ end trace 6c39677dc406a11b ]---
Kernel panic - not syncing: Fatal exception in interrupt
Kernel Offset: disabled
---[ end Kernel panic - not syncing: Fatal exception in interrupt

On commit 0c183d92b20b5c84ca655b45ef57b3318b83eb9e (Oct 31).

Thanks!
