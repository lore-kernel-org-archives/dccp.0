From: Andrey Konovalov <andreyknvl@google.com>
Date: Wed, 02 Nov 2016 20:47:37 +0000
Subject: net/dccp: null-ptr-deref in dccp_parse_options
Message-Id: <CAAeHK+xyYvvE=bNrJP6OXNMXWy_w_o3Sjw3AfeoUOmky3UG+FQ@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hi,

I've got the following error report while running the syzkaller fuzzer:

kasan: CONFIG_KASAN_INLINE enabled
kasan: GPF could be caused by NULL-ptr deref or user memory access
general protection fault: 0000 [#1] SMP KASAN
Modules linked in:
CPU: 0 PID: 4677 Comm: syz-executor Not tainted 4.9.0-rc3+ #336
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
task: ffff88006ac1d800 task.stack: ffff880067be0000
RIP: 0010:[<ffffffff8389632c>]  [<     inline     >]
ccid_hc_rx_parse_options net/dccp/ccid.h:217
RIP: 0010:[<ffffffff8389632c>]  [<ffffffff8389632c>]
dccp_parse_options+0x9dc/0x1010 net/dccp/options.c:218
RSP: 0018:ffff880067be7368  EFLAGS: 00010246
RAX: ffff88006ac1d800 RBX: ffff880066f5807d RCX: 0000000000000001
RDX: 0000000000000000 RSI: 0000000000000000 RDI: ffff88006bc29bc0
RBP: ffff880067be73f8 R08: 0000000000000000 R09: ffffffff838962fd
R10: ffff88006bc29bc0 R11: 1ffff1000d785474 R12: 0000000000000080
R13: 0000000000000000 R14: dffffc0000000000 R15: ffff880066f5807d
FS:  00007fbc6b0e8700(0000) GS:ffff88006cc00000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 00000000004aca30 CR3: 00000000683fa000 CR4: 00000000000006f0
Stack:
 ffffffff838909f8 0000000000000000 ffff88006bc2a3a8 ffff88006bc2a3b0
 ffffed000d785475 ffff88006abbb900 09ff88006bc2a2f8 ffffffff00000080
 ffff88006abbb8c0 ffff88006bc29bc0 0000000000000000 0000000000000000
Call Trace:
 [<ffffffff838923f0>] dccp_rcv_state_process+0x200/0x15b0 net/dccp/input.c:644
 [<ffffffff838b9cb4>] dccp_v4_do_rcv+0xf4/0x1a0 net/dccp/ipv4.c:681
 [<     inline     >] sk_backlog_rcv ./include/net/sock.h:874
 [<ffffffff82b82082>] __sk_receive_skb+0x252/0xa20 net/core/sock.c:479
 [<ffffffff838bc027>] dccp_v4_rcv+0xdb7/0x1920 net/dccp/ipv4.c:873
 [<ffffffff83069d42>] ip_local_deliver_finish+0x332/0xad0
net/ipv4/ip_input.c:216
 [<     inline     >] NF_HOOK_THRESH ./include/linux/netfilter.h:232
 [<     inline     >] NF_HOOK ./include/linux/netfilter.h:255
 [<ffffffff8306abf2>] ip_local_deliver+0x1c2/0x4b0 net/ipv4/ip_input.c:257
 [<     inline     >] dst_input ./include/net/dst.h:507
 [<ffffffff83068520>] ip_rcv_finish+0x750/0x1c40 net/ipv4/ip_input.c:396
 [<     inline     >] NF_HOOK_THRESH ./include/linux/netfilter.h:232
 [<     inline     >] NF_HOOK ./include/linux/netfilter.h:255
 [<ffffffff8306b84f>] ip_rcv+0x96f/0x12f0 net/ipv4/ip_input.c:487
 [<ffffffff82bd9fd7>] __netif_receive_skb_core+0x1897/0x2a50 net/core/dev.c:4213
 [<ffffffff82bdb1ba>] __netif_receive_skb+0x2a/0x170 net/core/dev.c:4251
 [<ffffffff82bdb4b3>] netif_receive_skb_internal+0x1b3/0x390 net/core/dev.c:4279
 [<ffffffff82bdb6d8>] netif_receive_skb+0x48/0x250 net/core/dev.c:4303
 [<ffffffff8241fc75>] tun_get_user+0xbd5/0x28a0 drivers/net/tun.c:1308
 [<ffffffff82421b5a>] tun_chr_write_iter+0xda/0x190 drivers/net/tun.c:1332
 [<     inline     >] new_sync_write fs/read_write.c:499
 [<ffffffff8151bd44>] __vfs_write+0x334/0x570 fs/read_write.c:512
 [<ffffffff8151f85b>] vfs_write+0x17b/0x500 fs/read_write.c:560
 [<     inline     >] SYSC_write fs/read_write.c:607
 [<ffffffff81523184>] SyS_write+0xd4/0x1a0 fs/read_write.c:599
 [<ffffffff83fc0401>] entry_SYSCALL_64_fastpath+0x1f/0xc2
arch/x86/entry/entry_64.S:209
Code: 49 8d ba e0 07 00 00 49 89 fb 49 c1 eb 03 43 80 3c 33 00 0f 85
59 05 00 00 48 8b 7d b8 4c 8b 87 e0 07 00 00 4c 89 c6 48 c1 ee 03 <42>
80 3c 36 00 0f 85 d5 04 00 00 49 8b 10 48 8d ba 90 00 00 00
RIP  [<     inline     >] ccid_hc_rx_parse_options net/dccp/ccid.h:217
RIP  [<ffffffff8389632c>] dccp_parse_options+0x9dc/0x1010 net/dccp/options.c:218
 RSP <ffff880067be7368>
---[ end trace f4114105e77749ef ]---
Kernel panic - not syncing: Fatal exception in interrupt
Kernel Offset: disabled
---[ end Kernel panic - not syncing: Fatal exception in interrupt

On commit 0c183d92b20b5c84ca655b45ef57b3318b83eb9e (Oct 31).

Thanks!
