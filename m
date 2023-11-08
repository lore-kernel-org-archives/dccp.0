Received: from lindbergh.monkeyblade.net (lindbergh.monkeyblade.net [23.128.96.19])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id AFF34D505
	for <dccp@vger.kernel.org>; Wed,  8 Nov 2023 08:03:05 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; dkim=none
Received: from mail-oi1-f197.google.com (mail-oi1-f197.google.com [209.85.167.197])
	by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 51DFDAF
	for <dccp@vger.kernel.org>; Wed,  8 Nov 2023 00:03:05 -0800 (PST)
Received: by mail-oi1-f197.google.com with SMTP id 5614622812f47-3b2e4f3defaso9032633b6e.2
        for <dccp@vger.kernel.org>; Wed, 08 Nov 2023 00:03:05 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1699430584; x=1700035384;
        h=to:from:subject:message-id:in-reply-to:date:mime-version
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to;
        bh=wLxkoJ0J2bDcVFhjdD1ByIlE66SDaLG2rCYjwFdMcfw=;
        b=ksk3OBM4P1ftjQ/Sq2+w5f2mM8RyD3ntYGJ1n9A2b6S2UUSZifLyFJ301GsV93VOq9
         9m3iTyLIloMpcWwkEwlkVVVMsFYZ9DLcalOlkzC+6y8Ppo35ijhefXlNOGUKE/jBsx6Y
         OjBnfc6QN/vJS37RlkPz4h0LAFhAZpKSqItlzrRCWqqOT8ZmXWwS26Hp433i4tEXLyeE
         Zc/y24/6dz8u6eSAWb21V3TPt4kjQLai0otT4VplEGkH1oV99sjsX1W4Akvbsethxkvi
         K2hKoJKXfVEkoX4+tYzVezm4zEn0Ojv3FNdiwK3/T1vN2A6N2cBDIB+QUZpUmJXGshfU
         F6YQ==
X-Gm-Message-State: AOJu0YyGPWM/3r4Z8M5JFzBWufLayuc1qb8QF+Y7rMt/d6tyGdjRzTv4
	yiMukkEoAJ8zCatE5l78eyqFaeYZuhtAbfkSoHHvHBne2GKN
X-Google-Smtp-Source: AGHT+IFaX5LC4+c28UiyOy/nAi3zs6InloFZr1OolB/cB0NXkbGGJtuSl1zjrihF1453Xy0W+gcaNotbRS9cwtvEwE4TbRPga8XM
Precedence: bulk
X-Mailing-List: dccp@vger.kernel.org
List-Id: <dccp.vger.kernel.org>
List-Subscribe: <mailto:dccp+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:dccp+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-Received: by 2002:a05:6808:201d:b0:3ae:61f:335e with SMTP id
 q29-20020a056808201d00b003ae061f335emr581414oiw.5.1699430584749; Wed, 08 Nov
 2023 00:03:04 -0800 (PST)
Date: Wed, 08 Nov 2023 00:03:04 -0800
In-Reply-To: <0000000000009e122006088a2b8d@google.com>
X-Google-Appengine-App-Id: s~syzkaller
X-Google-Appengine-App-Id-Alias: syzkaller
Message-ID: <00000000000053135d06099f84a3@google.com>
Subject: Re: [syzbot] [dccp?] general protection fault in dccp_write_xmit (2)
From: syzbot <syzbot+c71bc336c5061153b502@syzkaller.appspotmail.com>
To: bragathemanick0908@gmail.com, davem@davemloft.net, dccp@vger.kernel.org, 
	edumazet@google.com, kuba@kernel.org, linux-kernel@vger.kernel.org, 
	netdev@vger.kernel.org, pabeni@redhat.com, syzkaller-bugs@googlegroups.com
Content-Type: text/plain; charset="UTF-8"

syzbot has bisected this issue to:

commit 419ce133ab928ab5efd7b50b2ef36ddfd4eadbd2
Author: Paolo Abeni <pabeni@redhat.com>
Date:   Wed Oct 11 07:20:55 2023 +0000

    tcp: allow again tcp_disconnect() when threads are waiting

bisection log:  https://syzkaller.appspot.com/x/bisect.txt?x=142a647b680000
start commit:   ff269e2cd5ad Merge tag 'net-next-6.7-followup' of git://gi..
git tree:       net-next
final oops:     https://syzkaller.appspot.com/x/report.txt?x=162a647b680000
console output: https://syzkaller.appspot.com/x/log.txt?x=122a647b680000
kernel config:  https://syzkaller.appspot.com/x/.config?x=53cdcbf124ea14aa
dashboard link: https://syzkaller.appspot.com/bug?extid=c71bc336c5061153b502
syz repro:      https://syzkaller.appspot.com/x/repro.syz?x=142bff40e80000
C reproducer:   https://syzkaller.appspot.com/x/repro.c?x=1559f190e80000

Reported-by: syzbot+c71bc336c5061153b502@syzkaller.appspotmail.com
Fixes: 419ce133ab92 ("tcp: allow again tcp_disconnect() when threads are waiting")

For information about bisection process see: https://goo.gl/tpsmEJ#bisection
