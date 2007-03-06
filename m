From: Andre Noll <maan@systemlinux.org>
Date: Tue, 06 Mar 2007 08:38:59 +0000
Subject: Re: kernel BUG at kernel/timer.c:407!
Message-Id: <20070306083859.GY22572@skl-net.de>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="7kD9y3RnPUgTZee0"
List-Id: <dccp.vger.kernel.org>
References: <20070305143240.GW22572@skl-net.de>
In-Reply-To: <20070305143240.GW22572@skl-net.de>
To: dccp@vger.kernel.org


--7kD9y3RnPUgTZee0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On 19:59, Andre Noll wrote:
> > 2. This is using CCID2, which has not been maintained for a while. Can
> >    you please try CCID 3 also, e.g. by using the following sysctls:
> >   =20
> >    sysctl -w net.dccp.default.rx_ccid=3D3=20
> >    sysctl -w net.dccp.default.tx_ccid=3D3
> >    sysctl -w net.dccp.default.tx_qlen=3D5
> >    sysctl -w net.dccp.default.seq_window=3D100
> >    sysctl -w net.dccp.default.send_ackvec=3D0
>=20
> Will do this today in the evening and report again tomorrow.

There was no sysctl on this system, but

	echo 3 > /proc/net/dccp/default/rx_ccid

should do the same, so I did this (and analogously for the other three
values). The bug remains, but the backtrace is slightly different,
see below.

> > The BUG is caused via the following chain:=20
> >=20
> > 1. dccp_write_xmit(sk, 0) (due to !block)
> > 1. dccp_sendmsg
> > 2. ccid2_hc_tx_send_packet -> with hctx->ccid2hctx_pipe >=3D hctx->ccid=
2hctx_cwnd
> >    (see above, pipe=3Dcwnd=3D1) =3D=3D> returns 1
> > 3. in dccp_write_xmit(sk, 0):
> >    if (!block) {                 /* this is true here */
> > 		sk_reset_timer(sk, &dp->dccps_xmit_timer,
> >    				msecs_to_jiffies(err)+jiffies)
> >    =3D=3D> BUG()
> > |   <7>dccp_set_state: listen(c1580030) LISTEN     -> CLOSED
> > This may be a clue: this socket has not gone past listen state (i.e. no=
t entered server)
>=20
> Yes, the bug happens in para_server just at the moment the first client
> connects. No data is transfered to the client. I'll look into the kernel
> dccp code a bit this evening as well.

Found nothing suspicious. Apparently, dccp_connect() in
net/cddp/output.c is never called as this is the only place where
dp->dccps_xmit_timer.function is set, and the BUG in kernel/timer.c
indicates that this function pointer is NULL.

Regards,
Andre

------------[ cut here ]------------
kernel BUG at kernel/timer.c:407!
invalid opcode: 0000 [#1]
PREEMPT=20
CPU:    0
EIP:    0060:[<c01256a2>]    Not tainted VLI
EFLAGS: 00210246   (2.6.20 #14)
EIP is at mod_timer+0x1d/0x21
eax: df6e473c   ebx: df6e4400   ecx: 00000000   edx: fffc231e
esi: df6e4400   edi: db534c4c   ebp: 000001a1   esp: dce2be0c
ds: 007b   es: 007b   ss: 0068
Process para_server (pid: 1263, ti=3Ddce2a000 task=3Dde089550 task.ti=3Ddce=
2a000)
Stack: c03747b6 db579d80 c0416949 dce2be20 dce2be98 00000000 00000000 c0511=
fc0=20
       df6e4400 dce2be98 dce2bedc c03b5470 000001a1 c0443f20 dce2be98 dcf9b=
800=20
       df788200 c0371128 000001a1 dce2bedc dce2bedc 00000001 dce2bed4 00000=
000=20
Call Trace:
 [<c03747b6>] sk_reset_timer+0xc/0x15
 [<c0416949>] dccp_sendmsg+0x105/0x155
 [<c03b5470>] inet_sendmsg+0x47/0x5f
 [<c0371128>] do_sock_write+0x93/0xa2
 [<c03711ab>] sock_aio_write+0x74/0x8c
 [<c03700ff>] pcibios_setup+0x104/0x3b2
 [<c0397aad>] inet_csk_accept+0x8b/0x163
 [<c015cca0>] do_sync_write+0xc8/0x117
 [<c0295251>] write_chan+0x1a5/0x1e4
 [<c011959d>] __wake_up+0x4b/0x77
 [<c0130990>] autoremove_wake_function+0x0/0x43
 [<c028f384>] tty_ldisc_deref+0x51/0x84
 [<c0254a32>] copy_to_user+0x2b/0x37
 [<c015ce7e>] vfs_write+0x18f/0x194
 [<c015cf2e>] sys_write+0x41/0x6a
 [<c0102ff4>] syscall_call+0x7/0xb
 =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
Code: 5f c3 0f 0b eb fe 5b 5e 5f e9 be aa 2f 00 8b 48 0c 85 c9 74 16 39 50 =
08 74 05 e9 cb fe ff ff 8b 08 85 c9 74 f5 b8 01 00 00 00 c3 <0f> 0b eb fe 8=
3 ec 0c 89 5c 24 04 89 74 24 08 89 c3 8b 00 31 f6=20
EIP: [<c01256a2>] mod_timer+0x1d/0x21 SS:ESP 0068:dce2be0c
=20
--=20
The only person who always got his work done by Friday was Robinson Crusoe

--7kD9y3RnPUgTZee0
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.1 (GNU/Linux)

iD8DBQFF7SijWto1QDEAkw8RAhXoAJ9422UKx+7iK0y17d6iu25GseaLbgCfQBx3
4ScvNtnwGNahYkmFANkaBZI=
=jT2y
-----END PGP SIGNATURE-----

--7kD9y3RnPUgTZee0--
