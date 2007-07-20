From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 20 Jul 2007 17:27:37 +0000
Subject: Performance with entirely unpatched 2.6.22 kernel
Message-Id: <200707201827.37769@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

I haven't been able to get to the ground of the problem why the performance=
=20
is currently so bad, but on a clean, unpatched 2.6.22 kernel (from netdev),
I already get packet loss reports on a lossless link (see below).=20

Applying the test-tree patches on top leads to reported loss rates of up to
10 percent. If that happens in the bandwidth-restricted link, then no wonder
the performance drops down.=20

Will investigate further, but DCCP may not be the only corner to look for.
In any case, I find the many negative (late) delays below also suspicious.



Jul 20 18:09:41 gerrit kernel: ccid3_hc_tx_parse_options: client(f484d030),=
 LOSS_EVENT_RATEB94967295
Jul 20 18:09:41 gerrit kernel: ccid3_hc_tx_update_x: X_prevt98324, X_now=14=
996648, X_calc=3D0, X_recv=11887895
Jul 20 18:09:41 gerrit kernel: ccid3_update_send_interval: t_ipi=94, deltaG=
, s=1415, X=14996648
Jul 20 18:09:41 gerrit kernel: ccid3_hc_tx_packet_recv: client(f484d030), R=
TT=1827us (sample=1803us), s=1415, p=3D0, X_calc0, X_recv=11887895, X=14996=
648
Jul 20 18:09:41 gerrit kernel: ccid3_hc_tx_send_packet: delay=3D-19169
Jul 20 18:09:41 gerrit kernel: ccid3_hc_tx_send_packet: delay=3D-19108
Jul 20 18:09:41 gerrit kernel: ccid3_hc_tx_send_packet: delay=3D-19047
Jul 20 18:09:41 gerrit kernel: ccid3_hc_tx_send_packet: delay=3D-18984
Jul 20 18:09:41 gerrit kernel: ccid3_hc_tx_send_packet: delay=3D-18921
Jul 20 18:09:41 gerrit kernel: ccid3_hc_tx_send_packet: delay=3D-18857
Jul 20 18:09:41 gerrit kernel: ccid3_hc_tx_send_packet: delay=3D-18798
Jul 20 18:09:41 gerrit kernel: ccid3_hc_tx_send_packet: delay=3D-18735
Jul 20 18:09:41 gerrit kernel: ccid3_hc_tx_send_packet: delay=3D-18673
Jul 20 18:09:41 gerrit kernel: ccid3_hc_tx_send_packet: delay=3D-18610
Jul 20 18:09:41 gerrit kernel: ccid3_hc_tx_send_packet: delay=3D-18548
Jul 20 18:09:41 gerrit kernel: ccid3_hc_tx_send_packet: delay=3D-18487
Jul 20 18:09:41 gerrit kernel: ccid3_hc_tx_send_packet: delay=3D-18423
Jul 20 18:09:41 gerrit kernel: ccid3_hc_tx_send_packet: delay=3D-18389
Jul 20 18:09:41 gerrit kernel: ccid3_hc_tx_send_packet: delay=3D-18327
Jul 20 18:09:41 gerrit kernel: ccid3_hc_tx_send_packet: delay=3D-18264
Jul 20 18:09:41 gerrit kernel: ccid3_hc_tx_send_packet: delay=3D-18200
Jul 20 18:09:41 gerrit kernel: ccid3_hc_tx_senlay=3D-2887
Jul 20 18:09:41 gerrit kernel: ccid3_hc_tx_send_packet: delay=3D-2659
Jul 20 18:09:41 gerrit kernel: ccid3_hc_tx_send_packet: delay=3D-2455
Jul 20 18:09:41 gerrit kernel: ccid3_hc_tx_send_packet: delay=3D-2255
Jul 20 18:09:41 gerrit kernel: ccid3_hc_tx_send_packet: delay=3D-2050
Jul 20 18:09:41 gerrit kernel: ccid3_hc_tx_send_packet: delay=3D-1844
Jul 20 18:09:41 gerrit kernel: ccid3_hc_tx_parse_options: client(f484d030),=
 RECEIVE_RATE=1420590
Jul 20 18:09:41 gerrit kernel: ccid3_hc_tx_parse_options: client(f484d030),=
 LOSS_EVENT_RATE1
Jul 20 18:09:41 gerrit kernel: ccid3_hc_tx_update_x: X_prevY08095, X_now(41=
180, X_calcU50695, X_recv=1420590
Jul 20 18:09:41 gerrit kernel: ccid3_update_send_interval: t_ipiI8, delta$9=
, s=1415, X(41180
Jul 20 18:09:41 gerrit kernel: ccid3_hc_tx_packet_recv: client(f484d030), R=
TT=1339us (sample 70us), s=1415, p2258, X_c
alcU50695, X_recv=1420590, X(41180
Jul 20 18:09:41 gerrit kernel: ccid3_hc_tx_send_packet: delay=3D-3872
Jul 20 18:09:41 gerrit kernel: ccid3_hc_tx_send_packet: delay=3D-3460
Jul 20 18:09:41 gerrit kernel: ccid3_hc_tx_send_packet: delay=3D-2995
Jul 20 18:09:41 gerrit kernel: ccid3_hc_tx_send_packet: delay=3D-2612
Jul 20 18:09:41 gerrit kernel: ccid3_hc_tx_send_packet: delay=3D-2148
Jul 20 18:09:41 gerrit kernel: ccid3_hc_tx_send_packet: delay=3D-1682
Jul 20 18:09:41 gerrit kernel: ccid3_hc_tx_send_packet: delay=3D-1215
Jul 20 18:09:41 gerrit kernel: ccid3_hc_tx_send_packet: delay=3D-749
Jul 20 18:09:41 gerrit kernel: ccid3_hc_tx_send_packet: delay=3D-2610
