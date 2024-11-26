Received: from forward100b.mail.yandex.net (forward100b.mail.yandex.net [178.154.239.147])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9B5F8BE46;
	Tue, 26 Nov 2024 14:40:00 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=178.154.239.147
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1732632006; cv=none; b=d6Fe5Jc6ayzPNgRhd2XdKJ44zYcHUBFj683+G7y0RjgCXffnPr1tPLvmLyD4fKZSVSUh72I7lgEwswiud63zreoF9UIP5o0gVnbKQuulf2vbdVkoXI0E3Xs9JhAQPe9jvwaH+gAMonzfojJousz5V/nnyfxlQf7PICNs9Z/gUhc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1732632006; c=relaxed/simple;
	bh=yikF7kDbrV5x7L7GHYppYPciTmDd9SbAXb12mkWlqdk=;
	h=From:To:Cc:Subject:Date:Message-Id:MIME-Version; b=s9HMT0bDFblvv6kmDObfV0gcqPmhh+j7iFHq8Evz1hbn12+EfqTeYAQ9PpdNzwn/A1f7jbgMbe5VImLK61WwDuKMZgocpB+BIXeNKb1J9i5enKpH8egk6/jgj9SR4EnruoWyWbqBTs7pbIgZHLLuNKRBJ/gGLOBHCsgxDDEdyTQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=phystech.edu; spf=pass smtp.mailfrom=phystech.edu; dkim=pass (1024-bit key) header.d=phystech.edu header.i=@phystech.edu header.b=iAAEpzpu; arc=none smtp.client-ip=178.154.239.147
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=phystech.edu
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=phystech.edu
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=phystech.edu header.i=@phystech.edu header.b="iAAEpzpu"
Received: from mail-nwsmtp-smtp-production-main-60.sas.yp-c.yandex.net (mail-nwsmtp-smtp-production-main-60.sas.yp-c.yandex.net [IPv6:2a02:6b8:c11:1115:0:640:1385:0])
	by forward100b.mail.yandex.net (Yandex) with ESMTPS id 1882060ACA;
	Tue, 26 Nov 2024 17:39:53 +0300 (MSK)
Received: by mail-nwsmtp-smtp-production-main-60.sas.yp-c.yandex.net (smtp/Yandex) with ESMTPSA id odZN6rrOoqM0-FYZpU16s;
	Tue, 26 Nov 2024 17:39:52 +0300
X-Yandex-Fwd: 1
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=phystech.edu;
	s=mail; t=1732631992;
	bh=sWbOWgPnngA9bg4tFHVDZp41fDMdXRzdyRs2pPUtJjo=;
	h=Message-Id:Date:Cc:Subject:To:From;
	b=iAAEpzpuu06SriXeW4OY+FJjsJBr0B5+J16iYVVCuz4ULeF80RPTkVp2SP1KRF6qW
	 P8YJWZEyh+mkg9/NrKJ4PRGZC0Itf1ZCkkgg/NbeaNFd55JWkQqabEtH4QrEbHpqfx
	 Sp3XAZpYudRLh+fimcerBQqlB1tjqw957y7klCZc=
Authentication-Results: mail-nwsmtp-smtp-production-main-60.sas.yp-c.yandex.net; dkim=pass header.i=@phystech.edu
From: Ivan Solodovnikov <solodovnikov.ia@phystech.edu>
To: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Cc: Ivan Solodovnikov <solodovnikov.ia@phystech.edu>,
	"David S. Miller" <davem@davemloft.net>,
	Jakub Kicinski <kuba@kernel.org>,
	dccp@vger.kernel.org,
	netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	lvc-project@linuxtesting.org
Subject: [PATCH net] dccp: Fix memory leak in dccp_feat_change_recv
Date: Tue, 26 Nov 2024 17:39:02 +0300
Message-Id: <20241126143902.190853-1-solodovnikov.ia@phystech.edu>
X-Mailer: git-send-email 2.34.1
Precedence: bulk
X-Mailing-List: dccp@vger.kernel.org
List-Id: <dccp.vger.kernel.org>
List-Subscribe: <mailto:dccp+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:dccp+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

If dccp_feat_push_confirm() fails after new value for SP feature was accepted
without reconciliation ('entry == NULL' branch), memory allocated for that value
with dccp_feat_clone_sp_val() is never freed.

Here is the kmemleak stack for this:

unreferenced object 0xffff88801d4ab488 (size 8):
  comm "syz-executor310", pid 1127, jiffies 4295085598 (age 41.666s)
  hex dump (first 8 bytes):
    01 b4 4a 1d 80 88 ff ff                          ..J.....
  backtrace:
    [<00000000db7cabfe>] kmemdup+0x23/0x50 mm/util.c:128
    [<0000000019b38405>] kmemdup include/linux/string.h:465 [inline]
    [<0000000019b38405>] dccp_feat_clone_sp_val net/dccp/feat.c:371 [inline]
    [<0000000019b38405>] dccp_feat_clone_sp_val net/dccp/feat.c:367 [inline]
    [<0000000019b38405>] dccp_feat_change_recv net/dccp/feat.c:1145 [inline]
    [<0000000019b38405>] dccp_feat_parse_options+0x1196/0x2180 net/dccp/feat.c:1416
    [<00000000b1f6d94a>] dccp_parse_options+0xa2a/0x1260 net/dccp/options.c:125
    [<0000000030d7b621>] dccp_rcv_state_process+0x197/0x13d0 net/dccp/input.c:650
    [<000000001f74c72e>] dccp_v4_do_rcv+0xf9/0x1a0 net/dccp/ipv4.c:688
    [<00000000a6c24128>] sk_backlog_rcv include/net/sock.h:1041 [inline]
    [<00000000a6c24128>] __release_sock+0x139/0x3b0 net/core/sock.c:2570
    [<00000000cf1f3a53>] release_sock+0x54/0x1b0 net/core/sock.c:3111
    [<000000008422fa23>] inet_wait_for_connect net/ipv4/af_inet.c:603 [inline]
    [<000000008422fa23>] __inet_stream_connect+0x5d0/0xf70 net/ipv4/af_inet.c:696
    [<0000000015b6f64d>] inet_stream_connect+0x53/0xa0 net/ipv4/af_inet.c:735
    [<0000000010122488>] __sys_connect_file+0x15c/0x1a0 net/socket.c:1865
    [<00000000b4b70023>] __sys_connect+0x165/0x1a0 net/socket.c:1882
    [<00000000f4cb3815>] __do_sys_connect net/socket.c:1892 [inline]
    [<00000000f4cb3815>] __se_sys_connect net/socket.c:1889 [inline]
    [<00000000f4cb3815>] __x64_sys_connect+0x6e/0xb0 net/socket.c:1889
    [<00000000e7b1e839>] do_syscall_64+0x33/0x40 arch/x86/entry/common.c:46
    [<0000000055e91434>] entry_SYSCALL_64_after_hwframe+0x67/0xd1

Clean up the allocated memory in case of dccp_feat_push_confirm() failure
and bail out with an error reset code.

Found by Linux Verification Center (linuxtesting.org) with Syzkaller.

Fixes: e77b8363b2ea ("dccp: Process incoming Change feature-negotiation options")
Signed-off-by: Ivan Solodovnikov <solodovnikov.ia@phystech.edu>
---
 net/dccp/feat.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/net/dccp/feat.c b/net/dccp/feat.c
index 788dd629c420..e9cc7415ba48 100644
--- a/net/dccp/feat.c
+++ b/net/dccp/feat.c
@@ -1160,8 +1160,12 @@ static u8 dccp_feat_change_recv(struct list_head *fn, u8 is_mandatory, u8 opt,
 			goto not_valid_or_not_known;
 		}
 
-		return dccp_feat_push_confirm(fn, feat, local, &fval);
+		if (dccp_feat_push_confirm(fn, feat, local, &fval)) {
+			kfree(fval.sp.vec);
+			return DCCP_RESET_CODE_TOO_BUSY;
+		}
 
+		return 0;
 	} else if (entry->state == FEAT_UNSTABLE) {	/* 6.6.2 */
 		return 0;
 	}
-- 
2.34.1

