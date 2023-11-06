Received: from lindbergh.monkeyblade.net (lindbergh.monkeyblade.net [23.128.96.19])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 727C7DF51
	for <dccp@vger.kernel.org>; Mon,  6 Nov 2023 22:52:30 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; dkim=none
Received: from mail-oo1-f80.google.com (mail-oo1-f80.google.com [209.85.161.80])
	by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 0B67BD71
	for <dccp@vger.kernel.org>; Mon,  6 Nov 2023 14:52:29 -0800 (PST)
Received: by mail-oo1-f80.google.com with SMTP id 006d021491bc7-581ff5ab8d3so6934210eaf.1
        for <dccp@vger.kernel.org>; Mon, 06 Nov 2023 14:52:29 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1699311148; x=1699915948;
        h=to:from:subject:message-id:in-reply-to:date:mime-version
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to;
        bh=gVjrZIYw052So8S0TQsLIpyybr5BKhUBF66hcLzozOo=;
        b=SXDE4PODWW5kd8yb3jqrHJiLgV7bU02YjB/skcM8H8C4/P7yDDkpmzZ4g+5y28HDrY
         8VyhSwNb2yr6D1QB9V9monKNH3SWvX58Y+abzTPGadf/MPPxdVZiwi8sZD1MQsuIpYJZ
         zDo+5L9ngTCIFyIfdYfVcQcHXCIgsz60jkg1+FfEZsu4o9Je9sdb3QkbNseH5FCmkeOk
         3YqPLr054pHlYRUwyR5WuibhENb1xPr4wOj8/tbmrQNuKOBeYnd0xi1mAkLnCDfK3tMp
         k/TfuOtDwb1KUWTlj3dKtCGnzb64ZPH2GTc8FT5JLPM8voa3ZUBpjNyLh6jC4VLUJ+a8
         7rkQ==
X-Gm-Message-State: AOJu0YywvIE161OUq/YrLFDs/RjvBCyDywvuSmSTZ4qF5hOutEXXCvRA
	cEM23XKMuDuLDx3rDiD5bz3I3jDupTJooaMOLWin+4ptT0ZR
X-Google-Smtp-Source: AGHT+IFB7j58wbrZ2aBYzqpaJqnn8TcbxJBmQW57UZjeYHqs+Co2g/njg3yP6/NN5ZjiNKR3Rt7IBifrhZbtUHazgg/BLO34ilyq
Precedence: bulk
X-Mailing-List: dccp@vger.kernel.org
List-Id: <dccp.vger.kernel.org>
List-Subscribe: <mailto:dccp+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:dccp+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-Received: by 2002:a05:6870:2199:b0:1e9:668b:7ba0 with SMTP id
 l25-20020a056870219900b001e9668b7ba0mr374170oae.4.1699311148403; Mon, 06 Nov
 2023 14:52:28 -0800 (PST)
Date: Mon, 06 Nov 2023 14:52:28 -0800
In-Reply-To: <0000000000009e122006088a2b8d@google.com>
X-Google-Appengine-App-Id: s~syzkaller
X-Google-Appengine-App-Id-Alias: syzkaller
Message-ID: <0000000000005d11b8060983b5b7@google.com>
Subject: Re: [syzbot] [dccp?] general protection fault in dccp_write_xmit (2)
From: syzbot <syzbot+c71bc336c5061153b502@syzkaller.appspotmail.com>
To: bragathemanick0908@gmail.com, davem@davemloft.net, dccp@vger.kernel.org, 
	edumazet@google.com, kuba@kernel.org, linux-kernel@vger.kernel.org, 
	netdev@vger.kernel.org, pabeni@redhat.com, syzkaller-bugs@googlegroups.com
Content-Type: text/plain; charset="UTF-8"

syzbot has found a reproducer for the following issue on:

HEAD commit:    d2f51b3516da Merge tag 'rtc-6.7' of git://git.kernel.org/p..
git tree:       upstream
console output: https://syzkaller.appspot.com/x/log.txt?x=16675f40e80000
kernel config:  https://syzkaller.appspot.com/x/.config?x=cd456c5e6582895e
dashboard link: https://syzkaller.appspot.com/bug?extid=c71bc336c5061153b502
compiler:       gcc (Debian 12.2.0-14) 12.2.0, GNU ld (GNU Binutils for Debian) 2.40
syz repro:      https://syzkaller.appspot.com/x/repro.syz?x=167ac787680000
C reproducer:   https://syzkaller.appspot.com/x/repro.c?x=1799f190e80000

Downloadable assets:
disk image (non-bootable): https://storage.googleapis.com/syzbot-assets/7bc7510fe41f/non_bootable_disk-d2f51b35.raw.xz
vmlinux: https://storage.googleapis.com/syzbot-assets/d678011e498e/vmlinux-d2f51b35.xz
kernel image: https://storage.googleapis.com/syzbot-assets/4f6ed772923d/bzImage-d2f51b35.xz

IMPORTANT: if you fix the issue, please add the following tag to the commit:
Reported-by: syzbot+c71bc336c5061153b502@syzkaller.appspotmail.com

general protection fault, probably for non-canonical address 0xdffffc0000000000: 0000 [#1] PREEMPT SMP KASAN
KASAN: null-ptr-deref in range [0x0000000000000000-0x0000000000000007]
CPU: 3 PID: 5345 Comm: syz-executor785 Not tainted 6.6.0-syzkaller-14651-gd2f51b3516da #0
Hardware name: QEMU Standard PC (Q35 + ICH9, 2009), BIOS 1.16.2-debian-1.16.2-1 04/01/2014
RIP: 0010:ccid_hc_tx_send_packet net/dccp/ccid.h:166 [inline]
RIP: 0010:dccp_write_xmit+0x66/0x1d0 net/dccp/output.c:356
Code: 00 48 85 c0 49 89 c4 0f 84 03 01 00 00 e8 82 5f cd f7 41 80 3e 00 0f 85 45 01 00 00 48 8b 9d f8 08 00 00 48 89 d8 48 c1 e8 03 <42> 80 3c 28 00 0f 85 1f 01 00 00 48 8b 1b 48 8d bb b0 00 00 00 48
RSP: 0018:ffffc90003797870 EFLAGS: 00010246
RAX: 0000000000000000 RBX: 0000000000000000 RCX: 0000000000000000
RDX: ffff88802a2bd000 RSI: ffffffff89ba330e RDI: ffff88802d7d9540
RBP: ffff88802d7d9540 R08: 0000000000000001 R09: fffffbfff23e11e9
R10: ffffffff91f08f4f R11: ffffffff915e5030 R12: ffff8880186c9cc0
R13: dffffc0000000000 R14: ffffed1005afb3c7 R15: ffff88802d7d9e38
FS:  00007f263ceef6c0(0000) GS:ffff88806b900000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 0000000020002980 CR3: 000000001b2ab000 CR4: 0000000000350ef0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
Call Trace:
 <TASK>
 dccp_sendmsg+0x968/0xcc0 net/dccp/proto.c:801
 inet_sendmsg+0x9d/0xe0 net/ipv4/af_inet.c:847
 sock_sendmsg_nosec net/socket.c:730 [inline]
 __sock_sendmsg+0xd5/0x180 net/socket.c:745
 ____sys_sendmsg+0x2ac/0x940 net/socket.c:2588
 ___sys_sendmsg+0x135/0x1d0 net/socket.c:2642
 __sys_sendmmsg+0x1a1/0x450 net/socket.c:2728
 __do_sys_sendmmsg net/socket.c:2757 [inline]
 __se_sys_sendmmsg net/socket.c:2754 [inline]
 __x64_sys_sendmmsg+0x9c/0x100 net/socket.c:2754
 do_syscall_x64 arch/x86/entry/common.c:51 [inline]
 do_syscall_64+0x3f/0x110 arch/x86/entry/common.c:82
 entry_SYSCALL_64_after_hwframe+0x63/0x6b
RIP: 0033:0x7f263cf53559
Code: 28 00 00 00 75 05 48 83 c4 28 c3 e8 61 1a 00 00 90 48 89 f8 48 89 f7 48 89 d6 48 89 ca 4d 89 c2 4d 89 c8 4c 8b 4c 24 08 0f 05 <48> 3d 01 f0 ff ff 73 01 c3 48 c7 c1 b0 ff ff ff f7 d8 64 89 01 48
RSP: 002b:00007f263ceef218 EFLAGS: 00000246 ORIG_RAX: 0000000000000133
RAX: ffffffffffffffda RBX: 00007f263cfdd438 RCX: 00007f263cf53559
RDX: 0400000000000239 RSI: 0000000020002980 RDI: 0000000000000006
RBP: 00007f263cfdd430 R08: 00007fff5b335167 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000246 R12: 00007f263cfdd43c
R13: 00007f263cfaa504 R14: 0400000000000239 R15: 00007fff5b335168
 </TASK>
Modules linked in:
---[ end trace 0000000000000000 ]---
RIP: 0010:ccid_hc_tx_send_packet net/dccp/ccid.h:166 [inline]
RIP: 0010:dccp_write_xmit+0x66/0x1d0 net/dccp/output.c:356
Code: 00 48 85 c0 49 89 c4 0f 84 03 01 00 00 e8 82 5f cd f7 41 80 3e 00 0f 85 45 01 00 00 48 8b 9d f8 08 00 00 48 89 d8 48 c1 e8 03 <42> 80 3c 28 00 0f 85 1f 01 00 00 48 8b 1b 48 8d bb b0 00 00 00 48
RSP: 0018:ffffc90003797870 EFLAGS: 00010246
RAX: 0000000000000000 RBX: 0000000000000000 RCX: 0000000000000000
RDX: ffff88802a2bd000 RSI: ffffffff89ba330e RDI: ffff88802d7d9540
RBP: ffff88802d7d9540 R08: 0000000000000001 R09: fffffbfff23e11e9
R10: ffffffff91f08f4f R11: ffffffff915e5030 R12: ffff8880186c9cc0
R13: dffffc0000000000 R14: ffffed1005afb3c7 R15: ffff88802d7d9e38
FS:  00007f263ceef6c0(0000) GS:ffff88806b900000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 0000000020002980 CR3: 000000001b2ab000 CR4: 0000000000350ef0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
----------------
Code disassembly (best guess):
   0:	00 48 85             	add    %cl,-0x7b(%rax)
   3:	c0 49 89 c4          	rorb   $0xc4,-0x77(%rcx)
   7:	0f 84 03 01 00 00    	je     0x110
   d:	e8 82 5f cd f7       	call   0xf7cd5f94
  12:	41 80 3e 00          	cmpb   $0x0,(%r14)
  16:	0f 85 45 01 00 00    	jne    0x161
  1c:	48 8b 9d f8 08 00 00 	mov    0x8f8(%rbp),%rbx
  23:	48 89 d8             	mov    %rbx,%rax
  26:	48 c1 e8 03          	shr    $0x3,%rax
* 2a:	42 80 3c 28 00       	cmpb   $0x0,(%rax,%r13,1) <-- trapping instruction
  2f:	0f 85 1f 01 00 00    	jne    0x154
  35:	48 8b 1b             	mov    (%rbx),%rbx
  38:	48 8d bb b0 00 00 00 	lea    0xb0(%rbx),%rdi
  3f:	48                   	rex.W


---
If you want syzbot to run the reproducer, reply with:
#syz test: git://repo/address.git branch-or-commit-hash
If you attach or paste a git patch, syzbot will apply it before testing.
