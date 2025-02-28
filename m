Received: from smtpbguseast1.qq.com (smtpbguseast1.qq.com [54.204.34.129])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7260B7E1;
	Fri, 28 Feb 2025 04:32:27 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=54.204.34.129
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1740717156; cv=none; b=cgzEBWGOHi60Jm6gMoSgfBc61k3/kVjYPXbLF/Gf9cPHYyX2j0NhgGrExUrhhj/R8jckL3N8M+Nm5MGnK40tflFu56PidM6t3GXVVcbCu5PPxQvQagAsM2cPqrk0G4U0i4gmTrDAr+FFwc4SzF6wTuv7TevZtIIYYyeYx1AEc6U=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1740717156; c=relaxed/simple;
	bh=txOEqELD85bfnG+igDKfXfC2WyOnVJNFa1WOji+Znyk=;
	h=From:Content-Type:Mime-Version:Subject:Message-Id:Date:Cc:To; b=Ca0T851633B+MGQZwTe9OPOCBgvXaVEdmi/3defhcFV/XNQDOsNyo5GJeJXhyaE+h/oImhLnM9B80kHxspKj2J2O1pVFwT0lBZE2kxOWivxOEZe0FVFTeNtSrK95uQiT4JBJfVxUp4+P5b9TVmIfVOrxGJ/bqBjy/CgWNHwaKBg=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=m.fudan.edu.cn; spf=pass smtp.mailfrom=m.fudan.edu.cn; dkim=pass (1024-bit key) header.d=m.fudan.edu.cn header.i=@m.fudan.edu.cn header.b=TD01RoFL; arc=none smtp.client-ip=54.204.34.129
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=m.fudan.edu.cn
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=m.fudan.edu.cn
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=m.fudan.edu.cn header.i=@m.fudan.edu.cn header.b="TD01RoFL"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=m.fudan.edu.cn;
	s=sorc2401; t=1740716819;
	bh=txOEqELD85bfnG+igDKfXfC2WyOnVJNFa1WOji+Znyk=;
	h=From:Mime-Version:Subject:Message-Id:Date:To;
	b=TD01RoFLzlA16eTD1ihsGEmxaxK5eqGtagDYpT/kT2HZST7Z/dW7fUEBGP5ajIyPa
	 RN/HD0EzbctFItv08PHhySxP+OtMndWODkGZq783uFLxh33Ly4CZLhUc+Z7o9iyK/N
	 jtwvm/q3rIChod8AY5iup28umoCX+nmX13Q4M71M=
X-QQ-mid: bizesmtpip2t1740716811t3sef5g
X-QQ-Originating-IP: RwF1eU9Q/PewHG7k5q6UbnJXLH0nWI8f1WLINaeK+8E=
Received: from smtpclient.apple ( [localhost])
	by bizesmtp.qq.com (ESMTP) with 
	id ; Fri, 28 Feb 2025 12:26:49 +0800 (CST)
X-QQ-SSF: 0000000000000000000000000000000
X-QQ-GoodBg: 0
X-BIZMAIL-ID: 6570769894400751000
From: Kun Hu <huk23@m.fudan.edu.cn>
Content-Type: text/plain;
	charset=utf-8
Content-Transfer-Encoding: quoted-printable
Precedence: bulk
X-Mailing-List: dccp@vger.kernel.org
List-Id: <dccp.vger.kernel.org>
List-Subscribe: <mailto:dccp+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:dccp+unsubscribe@vger.kernel.org>
Mime-Version: 1.0 (Mac OS X Mail 16.0 \(3818.100.11.1.3\))
Subject: BUG: "hc->tx_t_ipi == NUM" holds (exception!) at
 net/dccp/ccids/ccid3.c:LINE/ccid3_update_send_interval()
Message-Id: <41BC3CDE-E60A-4C3D-97AD-4DE24331ACB7@m.fudan.edu.cn>
Date: Fri, 28 Feb 2025 12:26:39 +0800
Cc: syzkaller@googlegroups.com,
 "jjtan24@m.fudan.edu.cn" <jjtan24@m.fudan.edu.cn>,
 baishuoran@hrbeu.edu.cn,
 dccp@vger.kernel.org,
 netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org
To: davem@davemloft.net,
 edumazet@google.com,
 kuba@kernel.org,
 pabeni@redhat.com
X-Mailer: Apple Mail (2.3818.100.11.1.3)
X-QQ-SENDSIZE: 520
Feedback-ID: bizesmtpip:m.fudan.edu.cn:qybglogicsvrgz:qybglogicsvrgz8a-1
X-QQ-XMAILINFO: MF55TYR7sMGmbAw/XXsLUOykGYudG/XxSNu1DbbMjync2MLkoIn2Pl7H
	uFS5dBLw4xYcJVE7Kqi54O8N5rf3u0u4WLPzN0ag60/rrQN5iwhvlyj1kxIuM4PQZJYKtwr
	NPv7q/nTbuT1cJFRU+WMciHQhM0z9tabxcvw0SejT/wlfHghJWrNQBuLGY+Je/x4VBjQIUJ
	XZd6u0g4A4FOtpw7tUb51W409WZS5K+b9G2T0A8BwbVoZnsSf15geoZPBxtxsIgRW47J6QA
	JXJiZAbeSmBM8bBE65Wk5qZ6QGYscCztjb2Bp5+E5h8Y6KMcgcCxu85yR6DNNlpQWEYvPUG
	XsMqEWAd9dDIB8ixSykcdbQiiFa89PZjEYbtg5V/fZrhuulw5b6nHa0Q4S/ya90nCqI/isc
	28DUdGySMYC7JjM0X05jcdet7O2D6MJ7CcGRYOODqbM4Jvm90Gf5Rqx6yszQU576/B96NTo
	Xtz58rE1anbTR3DHGDo4xyUppXP+0pOT8czMZtq732+XiI/mRmdjvufQxldk0TY5ulEv9uf
	FQHChQ2tgDx1sX4XH8dVs+k7kE4u8n4pDHQbXtaFeeGso/E7YCl3A3LNDboJqE8sMpgpSRh
	HA14AMkvA7OoEmOrFOpJ8jEzvZzTy2pyKhw9ADDkDDYwyo+fmQkAKarCeI3ePjWwQSIrBxw
	NLteKUrtP9v1pCAs7csvFf65PhdnriiySc2fd72ip3AcoMyKOl5ONZZib3FWq3QmMgWbDER
	8qTs+Sm1Ei7VMFdJB84s2GtZksr8i73H2JXR1iBrFcQycC2fJyLWyJ/Dj1ZgVMiL28v+K/D
	FsYxjYwfLpv8fN7FHcrTsbNpw9cl4wLhTRz6dt07PihSd70N/HfHtM7DnYOQNLy6g0pLCne
	pdgbcLTBNt6Y1YGLabxCWKdIrm3Z90AwDl1jk2OcsPIdcJ/yd2M8xA5iobM9rTDX3N3530q
	mnoI0XwB2jrKLT7FBzKOKDug5W88keXRVB30capmoierMeoPrNPv5sQ7ZgrVmxqr7MUltFN
	eIKN7CSg==
X-QQ-XMRINFO: OD9hHCdaPRBwq3WW+NvGbIU=
X-QQ-RECHKSPAM: 0

Dear Maintainers,

When using our customized Syzkaller to fuzz the latest Linux kernel, the =
following crash (79th)
was triggered.

HEAD commit: d082ecbc71e9e0bf49883ee4afd435a77a5101b6
git tree: upstream
Output: =
https://github.com/pghk13/Kernel-Bug/blob/main/0225_6.14rc2/79-BUG_%20hc-_=
tx_t_ipi%20%3D%3D%20NUM%20holds%20(exception!)%20at%20net_dccp_ccids_ccid3=
.c_LINE_ccid3_update_send_interval()/log0
Kernel config: =
https://github.com/pghk13/Kernel-Bug/blob/main/0225_6.14rc2/config_6.14rc4=
.txt
C reproducer: =
https://github.com/pghk13/Kernel-Bug/blob/main/0225_6.14rc2/79-BUG_%20hc-_=
tx_t_ipi%20%3D%3D%20NUM%20holds%20(exception!)%20at%20net_dccp_ccids_ccid3=
.c_LINE_ccid3_update_send_interval()/repro.cprog
Syzlang reproducer: =
https://github.com/pghk13/Kernel-Bug/blob/main/0225_6.14rc2/79-BUG_%20hc-_=
tx_t_ipi%20%3D%3D%20NUM%20holds%20(exception!)%20at%20net_dccp_ccids_ccid3=
.c_LINE_ccid3_update_send_interval()/repro.prog

The problem is caused by an invalid calculation of the send interval =
(hc->tx_t_ipi) in the DCCP CCID3 congestion control module, where =
hc->tx_t_ipi =3D 0 violates the protocol logic. The problem is triggered =
(possibly) by the interaction of the following parameters in the system =
call sequence:

1.One possibility is that the initial packet is too large (sendto$inet, =
len=3D0xffc3)
This updates hc->tx_s to a larger value via ccid3_hc_tx_update_s, but =
subsequent small packets (e.g., sendmsg$inet with len=3D1) reduce =
hc->tx_s exponentially via the EWMA filter.

2.Another possibility is an unusually high send rate (hc->tx_x)
setsockopt or initial network conditions (e.g., RTT close to zero) may =
configure an excessively large hc->tx_x, causing scaled_div32((tx_s << =
6), tx_x) to truncate to zero. The problem can be reliably reproduced =
using the provided system call sequence. We suspect that validation of =
tx_s or tx_x lower bounds is missing from the TFRC rate calculation.

Our knowledge of the kernel is somewhat limited, and we'd appreciate it =
if you could determine if there is such an issue. If this issue doesn't =
have an impact, please ignore it =E2=98=BA.

If you fix this issue, please add the following tag to the commit:
Reported-by: Kun Hu <huk23@m.fudan.edu.cn>, Jiaji Qin =
<jjtan24@m.fudan.edu.cn>, Shuoran Bai <baishuoran@hrbeu.edu.cn>

=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
BUG: "hc->tx_t_ipi =3D=3D 0" holds (exception!) at =
net/dccp/ccids/ccid3.c:90/ccid3_update_send_interval()
CPU: 1 UID: 0 PID: 9488 Comm: syz-executor236 Not tainted 6.14.0-rc4 #1
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS =
1.13.0-1ubuntu1.1 04/01/2014
Call Trace:
 <TASK>
 dump_stack_lvl+0x180/0x1b0
 ccid3_update_send_interval+0x188/0x1c0
 ccid3_hc_tx_packet_sent+0x132/0x190
 dccp_xmit_packet+0x278/0x710
 dccp_write_xmit+0x174/0x1d0
 dccp_sendmsg+0xadd/0xcb0
 inet_sendmsg+0x121/0x150
 __sock_sendmsg+0x1c3/0x2a0
 ____sys_sendmsg+0x74c/0xa30
 ___sys_sendmsg+0x11d/0x1c0
 __sys_sendmsg+0x151/0x200
 do_syscall_64+0xcf/0x250
 entry_SYSCALL_64_after_hwframe+0x77/0x7f
RIP: 0033:0x7fe5a5d9bb7d
Code: c3 e8 37 2a 00 00 0f 1f 80 00 00 00 00 f3 0f 1e fa 48 89 f8 48 89 =
f7 48 89 d6 48 89 ca 4d 89 c2 4d 89 c8 4c 8b 4c 24 08 0f 05 <48> 3d 01 =
f0 ff ff 73 01 c3 48 c7 c1 c0 ff ff ff f7 d8 64 89 01 48
RSP: 002b:00007ffc6a60bfd8 EFLAGS: 00000246 ORIG_RAX: 000000000000002e
RAX: ffffffffffffffda RBX: 000000000000000b RCX: 00007fe5a5d9bb7d
RDX: 0000000000000000 RSI: 00000000200004c0 RDI: 0000000000000004
RBP: 0000000000000000 R08: 00000000a5d54bd0 R09: 00000000a5d54bd0
R10: 00000000a5d54bd0 R11: 0000000000000246 R12: 00007ffc6a60bfe4
R13: 0000000000000000 R14: 0000000000000000 R15: 0000000000000000
 </TASK>
---------------
thanks,
Kun Hu=
