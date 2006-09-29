From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 29 Sep 2006 17:24:55 +0000
Subject: Oops in DCCPv6
Message-Id: <200609291824.55831@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

While looking at DCCPv6 connections, I encountered the following oops:

Sep 29 17:38:30 gerrit kernel: BUG: unable to handle kernel paging request =
at virtual address 00300084
Sep 29 17:38:30 gerrit kernel:  printing eip:
Sep 29 17:38:30 gerrit kernel: c03bb4ac
Sep 29 17:38:30 gerrit kernel: *pde =3D 00000000
Sep 29 17:38:30 gerrit kernel: Oops: 0000 [#1]
Sep 29 17:38:30 gerrit kernel: Modules linked in: usbhid sd_mod
Sep 29 17:38:30 gerrit kernel: CPU:    0
Sep 29 17:38:30 gerrit kernel: EIP:    0060:[kfree_skb+9/46]    Not tainted=
 VLI
Sep 29 17:38:30 gerrit kernel: EFLAGS: 00010206   (2.6.18UDP-Lite-g9937f971=
-dirty #3)
Sep 29 17:38:31 gerrit kernel: EIP is at kfree_skb+0x9/0x2e
Sep 29 17:38:31 gerrit kernel: eax: 00300000   ebx: f2de2818   ecx: f60663e=
0   edx: 00300000
Sep 29 17:38:31 gerrit kernel: esi: f60663f8   edi: f6066000   ebp: f479fd2=
4   esp: f479fd24
Sep 29 17:38:32 gerrit kernel: ds: 007b   es: 007b   ss: 0068
Sep 29 17:38:32 gerrit kernel: Process ttcp_dccp (pid: 5743, ti=F479e000 ta=
sk=F4660ab0 task.ti=F479e000)
Sep 29 17:38:33 gerrit kernel: Stack: f479fd2c c045be46 f479fd58 c03b9070 c=
0121085 00000292 f7b0b02c f7b0b02c=20
Sep 29 17:38:33 gerrit kernel:        000000f8 f60663e0 f7b0b02c f7b0b02c f=
7b0b02c f479fd88 c03df571 00000002=20
Sep 29 17:38:33 gerrit kernel:        c046301a f479fd94 00000246 c041847d 0=
0000000 00000246 f7b0b02c f7b0b02c=20
Sep 29 17:38:33 gerrit kernel: Call Trace:
Sep 29 17:38:33 gerrit kernel:  [dccp_v6_reqsk_destructor+20/22] dccp_v6_re=
qsk_destructor+0x14/0x16
Sep 29 17:38:34 gerrit kernel:  [reqsk_queue_destroy+101/197] reqsk_queue_d=
estroy+0x65/0xc5
Sep 29 17:38:34 gerrit kernel:  [inet_csk_listen_stop+46/378] inet_csk_list=
en_stop+0x2e/0x17a
Sep 29 17:38:34 gerrit kernel:  [dccp_close+383/522] dccp_close+0x17f/0x20a
Sep 29 17:38:34 gerrit kernel:  [inet_release+47/76] inet_release+0x2f/0x4c
Sep 29 17:38:35 gerrit kernel:  [inet6_release+40/44] inet6_release+0x28/0x=
2c
Sep 29 17:38:35 gerrit kernel:  [sock_release+23/115] sock_release+0x17/0x73
Sep 29 17:38:35 gerrit kernel:  [sock_close+33/61] sock_close+0x21/0x3d
Sep 29 17:38:35 gerrit kernel:  [__fput+187/368] __fput+0xbb/0x170
Sep 29 17:38:35 gerrit kernel:  [fput+24/36] fput+0x18/0x24
Sep 29 17:38:35 gerrit kernel:  [filp_close+65/103] filp_close+0x41/0x67
Sep 29 17:38:35 gerrit kernel:  [put_files_struct+126/198] put_files_struct=
+0x7e/0xc6
Sep 29 17:38:35 gerrit kernel:  [do_exit+382/2251] do_exit+0x17e/0x8cb
Sep 29 17:38:35 gerrit kernel:  [do_group_exit+43/123] do_group_exit+0x2b/0=
x7b
Sep 29 17:38:35 gerrit kernel:  [get_signal_to_deliver+799/1053] get_signal=
_to_deliver+0x31f/0x41d
Sep 29 17:38:35 gerrit kernel:  [do_notify_resume+1007/1780] do_notify_resu=
me+0x3ef/0x6f4
Sep 29 17:38:35 gerrit kernel:  [work_notifysig+19/26] work_notifysig+0x13/=
0x1a
Sep 29 17:38:35 gerrit kernel:  [phys_startup_32+-1210107764/-1073741824] 0=
xb7ef388c
Sep 29 17:38:35 gerrit kernel:  =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3DSep 29 17:=
38:35 gerrit kernel: Code: 9a 00 00 00 c7 44 24 04 e8 ba 4f c0 c7 04 24 06 =
ae 49 c0 e8 1c e2 d5 ff e8 b6 8c d4 ff e9 59 ff ff ff 55 89 e5 89 c2 85 c0 =
74 12 <8b> 80 84 00 00 00 83 e8 01 75 09 89 d0 e8 26 ff ff ff 5d c3 ff=20
Sep 29 17:38:35 gerrit kernel: EIP: [kfree_skb+9/46] kfree_skb+0x9/0x2e SS:=
ESP 0068:f479fd24
Sep 29 17:38:35 gerrit kernel:  <1>Fixing recursive fault but reboot is nee=
ded!

-----------------------------------------
CONFIGURATION
 * all DCCP modules built into the kernel
 * latest davem-2.6 tree (DCCP part corresponds to acme-2.6.19)

HOW TO REPRODUCE
 * Oops was encountered on host with listening socket
 * let tccp listen to AF_UNSPEC socket (i.e. both v4/v6)
 * connect from other host to the IPv4 address (but don't actually transfer=
 data)
 * kill listening client on host =3D=3D> OOPS

I could not find out the exact cause, but the following may be helpful
 * while the oops happened, a lock was held by dccp_close:
   sk_lock-AF_INET6  dccp_close+0x12/0x20a
 * the above suggests the following trace:
    --dccp_close calls inet_csk_listen_stop(sk);
    --inet_csk_listen_stop calls reqsk_queue_destroy
    --the destructor dccp_v6_reqsk_destructor is called later in inet_csk_l=
isten_stop,
      in the while loop, which calls inet_csk_destroy_sock
    --inet_csk_destroy_sock calls sk->sk_prot->destroy(sk), which goes to d=
ccp_v6_reqsk_destructor

Sorry, I can't offer more explanation.

Gerrit

