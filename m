From: Andre Noll <maan@systemlinux.org>
Date: Mon, 05 Mar 2007 18:59:07 +0000
Subject: Re: kernel BUG at kernel/timer.c:407!
Message-Id: <20070305185907.GX22572@skl-net.de>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="ga5bsqHr1s/xcZEm"
List-Id: <dccp.vger.kernel.org>
References: <20070305143240.GW22572@skl-net.de>
In-Reply-To: <20070305143240.GW22572@skl-net.de>
To: dccp@vger.kernel.org


--ga5bsqHr1s/xcZEm
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On 16:42, Gerrit Renker wrote:

> I would much rather hunt down this bug than revert this patch, since reve=
rting it
> means that almost twice the work is done per each packet and truly bidire=
ctional
> connections are not currently supported.

Agreed. Let's try to find the bug.

> With initial tests here I could not reproduce the bug and had difficultie=
s=20
> since I have not all required libraries for paraslash.

You only need libssl-dev to reproduce the bug. All the other libraries
are optional and configure should detect what is installed on your
system.

> 1. I see you are using loopback (127.0.0.1) where packets are routed back
>    internally: does the bug persist when CCID2 sender and CCID2 receiver
>    are on different hosts?

Not so easy to find out because I only have one machine and no
internet at home, and no kernel with dccp support at work. I'll see
what I can do.

> 2. This is using CCID2, which has not been maintained for a while. Can
>    you please try CCID 3 also, e.g. by using the following sysctls:
>   =20
>    sysctl -w net.dccp.default.rx_ccid=3D3=20
>    sysctl -w net.dccp.default.tx_ccid=3D3
>    sysctl -w net.dccp.default.tx_qlen=3D5
>    sysctl -w net.dccp.default.seq_window=3D100
>    sysctl -w net.dccp.default.send_ackvec=3D0

Will do this today in the evening and report again tomorrow.
=20
> 3. Caveat: `Server' listens, `Client' connects. I could not build the par=
aslash app
>    due to missing libraries, but found that dccp_recv_open calls connect =
in dccp_recv.c
>    while dccp_open() in dccp_send.c calls listen(). It seems that the rol=
es are reversed,
>    is it possible to swap this in the application and does the problem pe=
rsist?

Well, that's possible, but IMHO does not make much sense: The server
app waits for incoming connections (not neccessary only dccp) and
responds by sending the audio stream to the client. That's how it's
supposed to be, no?

> The BUG is caused via the following chain:=20
>=20
> 1. dccp_write_xmit(sk, 0) (due to !block)
> 1. dccp_sendmsg
> 2. ccid2_hc_tx_send_packet -> with hctx->ccid2hctx_pipe >=3D hctx->ccid2h=
ctx_cwnd
>    (see above, pipe=3Dcwnd=3D1) =3D=3D> returns 1
> 3. in dccp_write_xmit(sk, 0):
>    if (!block) {                 /* this is true here */
> 		sk_reset_timer(sk, &dp->dccps_xmit_timer,
>    				msecs_to_jiffies(err)+jiffies)
>    =3D=3D> BUG()
> |   <7>dccp_set_state: listen(c1580030) LISTEN     -> CLOSED
> This may be a clue: this socket has not gone past listen state (i.e. not =
entered server)

Yes, the bug happens in para_server just at the moment the first client
connects. No data is transfered to the client. I'll look into the kernel
dccp code a bit this evening as well.

Thanks for your help
Andre
--=20
The only person who always got his work done by Friday was Robinson Crusoe

--ga5bsqHr1s/xcZEm
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.1 (GNU/Linux)

iD8DBQFF7Gh7Wto1QDEAkw8RAla/AJ9AHPPI7JIaahLeAepRmNQ/QxgkHwCfTErm
/fa2Zi2SewTV3QZASPqQ/E4=
=4jw6
-----END PGP SIGNATURE-----

--ga5bsqHr1s/xcZEm--
