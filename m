From: syzbot  <syzbot+79de6f09efc55fec084b706de3c91e9457433ac5@syzkaller.appspotmail.c
Date: Thu, 07 Nov 2019 13:42:04 +0000
Subject: Re: suspicious RCU usage at ./include/net/inet_sock.h:LINE
Message-Id: <000000000000ac3e9d0596c1d4fe@google.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

syzbot suspects this bug was fixed by commit:

commit 3f32d0be6c16b902b687453c962d17eea5b8ea19
Author: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
Date:   Tue Sep 25 20:09:10 2018 +0000

     tipc: lock wakeup & inputq at tipc_link_reset()

bisection log:  https://syzkaller.appspot.com/x/bisect.txt?x=1368cfa2600000
start commit:   464e1d5f
git tree:       upstream
kernel config:  https://syzkaller.appspot.com/x/.config?x=BAce9f7ec244b823
dashboard link: =20
https://syzkaller.appspot.com/bug?extidyde6f09efc55fec084b706de3c91e9457433=
ac5
syz repro:      https://syzkaller.appspot.com/x/repro.syz?x=126079e1800000
C reproducer:   https://syzkaller.appspot.com/x/repro.c?x=101499e1800000

If the result looks correct, please mark the bug fixed by replying with:

#syz fix: tipc: lock wakeup & inputq at tipc_link_reset()

For information about bisection process see: https://goo.gl/tpsmEJ#bisection
