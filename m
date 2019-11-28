From: syzbot <syzbot+554ccde221001ab5479a@syzkaller.appspotmail.com>
Date: Thu, 28 Nov 2019 10:30:00 +0000
Subject: Re: KASAN: use-after-free Read in ccid2_hc_tx_packet_recv
Message-Id: <0000000000007825cd05986598e6@google.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

syzbot has bisected this bug to:

commit 3fa6f616a7a4d0bdf4d877d530456d8a5c3b109b
Author: David Ahern <dsahern@gmail.com>
Date:   Mon Aug 7 15:44:17 2017 +0000

     net: ipv4: add second dif to inet socket lookups

bisection log:  https://syzkaller.appspot.com/x/bisect.txt?x=141e882ae00000
start commit:   b5069438 Merge branch 'stable/for-linus-4.17' of git://git..
git tree:       upstream
final crash:    https://syzkaller.appspot.com/x/report.txt?x=161e882ae00000
console output: https://syzkaller.appspot.com/x/log.txt?x=121e882ae00000
kernel config:  https://syzkaller.appspot.com/x/.config?x=982e2df1b9e60b02
dashboard link: https://syzkaller.appspot.com/bug?extidU4ccde221001ab5479a
syz repro:      https://syzkaller.appspot.com/x/repro.syz?x=1363ccb7800000
C reproducer:   https://syzkaller.appspot.com/x/repro.c?x=1272e2b7800000

Reported-by: syzbot+554ccde221001ab5479a@syzkaller.appspotmail.com
Fixes: 3fa6f616a7a4 ("net: ipv4: add second dif to inet socket lookups")

For information about bisection process see: https://goo.gl/tpsmEJ#bisection
