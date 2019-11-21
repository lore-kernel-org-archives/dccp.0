From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Thu, 21 Nov 2019 20:14:34 +0000
Subject: Re: KASAN: use-after-free Read in ccid_hc_tx_delete
Message-Id: <20191121201433.GD617@kadam>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

On Thu, Nov 21, 2019 at 07:00:00AM -0800, syzbot wrote:
> syzbot has bisected this bug to:
>=20
> commit f04684b4d85d6371126f476d3268ebf6a0bd57cf
> Author: Dan Carpenter <dan.carpenter@oracle.com>
> Date:   Thu Jun 21 08:07:21 2018 +0000
>=20
>     ALSA: lx6464es: Missing error code in snd_lx6464es_create()
>=20
> bisection log:  https://syzkaller.appspot.com/x/bisect.txt?x=10dd11cae000=
00
> start commit:   eb6cf9f8 Merge tag 'arm64-fixes' of git://git.kernel.org/=
p..
> git tree:       upstream
> final crash:    https://syzkaller.appspot.com/x/report.txt?x=12dd11cae000=
00
> console output: https://syzkaller.appspot.com/x/log.txt?x=14dd11cae00000
> kernel config:  https://syzkaller.appspot.com/x/.config?x=C8970c89a0efbb23
> dashboard link: https://syzkaller.appspot.com/bug?extid967c1caf256f4d5aefe
> syz repro:      https://syzkaller.appspot.com/x/repro.syz?x=11022ccd400000
> C reproducer:   https://syzkaller.appspot.com/x/repro.c?x=124581db400000
>=20
> Reported-by: syzbot+3967c1caf256f4d5aefe@syzkaller.appspotmail.com
> Fixes: f04684b4d85d ("ALSA: lx6464es: Missing error code in
> snd_lx6464es_create()")
>=20
> For information about bisection process see: https://goo.gl/tpsmEJ#bisect=
ion

This crash isn't related to my commit, it's seems something specific to
DCCP.

My guess is that the fix is probably something like this.  The old sk
and the new sk re-use the same newdp->dccps_hc_rx/tx_ccid pointers.
The first sk destructor frees it and that causes a use after free when
the second destructor tries to free it.

But I don't know DCCP code at all so I might be totally off and I
haven't tested this at all...  It was just easier to write a patch than
to try to explain in words.  Maybe we should clone the ccid instead of
setting it to NULL.  Or I might be completely wrong.

---
 net/dccp/minisocks.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/dccp/minisocks.c b/net/dccp/minisocks.c
index 25187528c308..4cbfcccbbbbb 100644
--- a/net/dccp/minisocks.c
+++ b/net/dccp/minisocks.c
@@ -98,6 +98,8 @@ struct sock *dccp_create_openreq_child(const struct sock =
*sk,
 		newdp->dccps_timestamp_echo =3D dreq->dreq_timestamp_echo;
 		newdp->dccps_timestamp_time =3D dreq->dreq_timestamp_time;
 		newicsk->icsk_rto	    =3D DCCP_TIMEOUT_INIT;
+		newdp->dccps_hc_rx_ccid     =3D NULL;
+		newdp->dccps_hc_tx_ccid     =3D NULL;
=20
 		INIT_LIST_HEAD(&newdp->dccps_featneg);
 		/*
--=20
2.11.0



