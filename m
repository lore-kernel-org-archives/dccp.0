From: Wei Chen <harperchen1110@gmail.com>
Date: Mon, 21 Nov 2022 15:19:13 +0000
Subject: WARNING in inet_csk_destroy_sock
Message-Id: <CAO4mrfc0_uMu0VQhxKqp6o5=wVtj5jDTwCmraLivZOo+ma1Qyg@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Dear Linux Developer,

Recently when using our tool to fuzz kernel, the following crash was triggered.

HEAD commit: 094226ad94f4 Linux v6.1-rc5
git tree: upstream
compiler: clang 12.0.1
console output:
https://drive.google.com/file/d/1YNhDIWBLrPbRas3gr13hh2zCSgMVMxt5/view?usp=share_link
syz reproducer:
https://drive.google.com/file/d/1cJrq3EeNsqGiOws-3xmY3IlfByhFWQVE/view?usp=share_link
C reproducer: https://drive.google.com/file/d/1fjh4zHZp-z9ucvQahJsJp0KV9DlAFCOj/view?usp=share_link
kernel config: https://drive.google.com/file/d/1TdPsg_5Zon8S2hEFpLBWjb8Tnd2KA5WJ/view?usp=share_link

IMPORTANT: if you fix the bug, please add the following tag to the commit:
Reported-by: Wei Chen <harperchen1110@gmail.com>

------------[ cut here ]------------
WARNING: CPU: 0 PID: 2829 at net/ipv4/inet_connection_sock.c:1155
inet_csk_destroy_sock+0x325/0x390
Modules linked in:
CPU: 0 PID: 2829 Comm: syz-executor.0 Not tainted 6.1.0-rc5 #40
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS
1.13.0-1ubuntu1.1 04/01/2014
RIP: 0010:inet_csk_destroy_sock+0x325/0x390 net/ipv4/inet_connection_sock.c:1155
Code: 3c 23 00 74 08 48 89 ef e8 48 04 1e f9 48 c7 45 00 00 00 00 00
43 80 3c 26 00 0f 85 be fe ff ff e9 c1 fe ff ff e8 db 47 cd f8 <0f> 0b
e9 ea fd ff ff e8 cf 47 cd f8 4c 89 f7 be 03 00 00 00 48 83
RSP: 0018:ffffc90005a2fba0 EFLAGS: 00010293
RAX: ffffffff88b9f795 RBX: ffff8880433ab198 RCX: ffff8880137bc800
RDX: 0000000000000000 RSI: 00000000000095d2 RDI: 0000000000000000
RBP: dffffc0000000000 R08: ffffffff88b9f550 R09: ffffed100867556d
R10: ffffed100867556d R11: 0000000000000000 R12: ffff8880433aab98
R13: dffffc0000000000 R14: ffff8880433aab00 R15: ffff8880433aab00
FS:  0000555555a3e940(0000) GS:ffff88802cc00000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 0000001b32d21000 CR3: 0000000049629000 CR4: 0000000000750ef0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
PKRU: 55555554
Call Trace:
 <TASK>
 dccp_close+0xc84/0xfc0 net/dccp/proto.c:1060
 inet_release+0x16e/0x1f0 net/ipv4/af_inet.c:428
 __sock_release net/socket.c:650 [inline]
 sock_close+0xd7/0x260 net/socket.c:1365
 __fput+0x3f7/0x8c0 fs/file_table.c:320
 task_work_run+0x243/0x300 kernel/task_work.c:179
 resume_user_mode_work include/linux/resume_user_mode.h:49 [inline]
 exit_to_user_mode_loop kernel/entry/common.c:171 [inline]
 exit_to_user_mode_prepare+0x1f2/0x210 kernel/entry/common.c:203
 __syscall_exit_to_user_mode_work kernel/entry/common.c:285 [inline]
 syscall_exit_to_user_mode+0x26/0x60 kernel/entry/common.c:296
 do_syscall_64+0x4c/0x90 arch/x86/entry/common.c:86
 entry_SYSCALL_64_after_hwframe+0x63/0xcd
RIP: 0033:0x7f4376c3ba8b
Code: 03 00 00 00 0f 05 48 3d 00 f0 ff ff 77 41 c3 48 83 ec 18 89 7c
24 0c e8 63 fc ff ff 8b 7c 24 0c 41 89 c0 b8 03 00 00 00 0f 05 <48> 3d
00 f0 ff ff 77 2f 44 89 c7 89 44 24 0c e8 a1 fc ff ff 8b 44
RSP: 002b:00007ffe0965dd60 EFLAGS: 00000293 ORIG_RAX: 0000000000000003
RAX: 0000000000000000 RBX: 0000000000000001 RCX: 00007f4376c3ba8b
RDX: 0000001b32d20000 RSI: ffffffff81adb419 RDI: 0000000000000003
RBP: 0000000000000004 R08: 0000000000000000 R09: 00000000000014c0
R10: 00000000a70694c4 R11: 0000000000000293 R12: 00007f4376d39500
R13: 00007f4376db0458 R14: 00007f4376db0460 R15: 00000000002c238f
 </TASK>

Best,
Wei
