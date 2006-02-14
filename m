From: Ian McDonald <imcdnzl@gmail.com>
Date: Tue, 14 Feb 2006 00:06:47 +0000
Subject: [BUG] Problem with feature negotiation
Message-Id: <cbec11ac0602131606r3db89cbcp2fba640d61b92447@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

Arnaldo/Andrea,

When I do this:
./ttcp_acme -c -l500 -r

I get a null pointer dereference in net/dccp/feat.c on line 427 which
is list_for_each_entry_safe.

Did some more testing and found it was because I had only CCID3
compiled as module and not CCID2. (i.e. bug occurs when
CONFIG_IP_DCCP_ACKVEC and CONFIG_IP_DCCP_CCID2 are not set).

If either of you too can fix that it'd be cool otherwise I'll add it
to my list of rainy day bugs....

void dccp_feat_clean(struct sock *sk)
{
	struct dccp_sock *dp =3D dccp_sk(sk);
	struct dccp_opt_pend *opt, *next;

	list_for_each_entry_safe(opt, next, &dp->dccps_options.dccpo_pending,
				 dccpop_node) {


Feb 14 11:12:19 localhost kernel: Unable to handle kernel NULL pointer
dereference at virtual address 00000000
Feb 14 11:12:19 localhost kernel:  printing eip:
Feb 14 11:12:19 localhost kernel: e0b9bac0
Feb 14 11:12:19 localhost kernel: *pde =3D 00000000
Feb 14 11:12:19 localhost kernel: Oops: 0000 [#1]
Feb 14 11:12:19 localhost kernel: PREEMPT
Feb 14 11:12:19 localhost kernel: Modules linked in: dccp lp af_packet
mousedev ide_generic usbhid snd_seq_dummy snd_seq_oss snd_seq_midi
snd_seq_midi_event snd_seq snd_mpu401 psmouse floppy parport_pc
parport pcspkr snd_via82xx snd_ac97_codec snd_ac97_bus rtc snd_pcm_oss
snd_mixer_oss 8139cp snd_pcm snd_timer snd_page_alloc snd_mpu401_uart
snd_rawmidi snd_seq_device snd soundcore i2c_viapro via_agp agpgart
i2c_core 8139too mii uhci_hcd usbcore ide_cd cdrom unix
Feb 14 11:12:19 localhost kernel: CPU:    0
Feb 14 11:12:19 localhost kernel: EIP:  =20
0060:[pg0+545561280/1070253056]    Not tainted VLI
Feb 14 11:12:19 localhost kernel: EFLAGS: 00010246   (2.6.16-rc2iandccp #1)
Feb 14 11:12:19 localhost kernel: EIP is at dccp_feat_clean+0xf/0xaa [dccp]
Feb 14 11:12:19 localhost kernel: eax: 00000000   ebx: 00000000   ecx:
dae16bb4   edx: 00000000
Feb 14 11:12:19 localhost kernel: esi: dae16808   edi: dae16808   ebp:
dacd3edc   esp: dacd3ed0
Feb 14 11:12:19 localhost kernel: ds: 007b   es: 007b   ss: 0068
Feb 14 11:12:19 localhost kernel: Process ttcp_acme (pid: 3726,
threadinfo=DAcd2000 task=DCa94ab0)
Feb 14 11:12:19 localhost kernel: Stack: <0>dae16808 dae16808 fffffff4
dacd3efc e0b9d679 dae16808 00000000 dae16808
Feb 14 11:12:19 localhost kernel:        00000000 dae16808 dae16808
dacd3f10 c02218d0 dae16808 dae16808 dae16808
Feb 14 11:12:19 localhost kernel:        dacd3f30 c025d29e dae16808
00044544 00000001 00000002 db10f96c 00000006
Feb 14 11:12:19 localhost kernel: Call Trace:
Feb 14 11:12:19 localhost kernel:  [show_stack_log_lvl+170/181]
show_stack_log_lvl+0xaa/0xb5
Feb 14 11:12:19 localhost kernel:  [show_registers+295/397]
show_registers+0x127/0x18d
Feb 14 11:12:19 localhost kernel:  [die+321/441] die+0x141/0x1b9
Feb 14 11:12:19 localhost kernel:  [do_page_fault+915/1229]
do_page_fault+0x393/0x4cd
Feb 14 11:12:19 localhost kernel:  [error_code+79/84] error_code+0x4f/0x54
Feb 14 11:12:19 localhost kernel:  [pg0+545568377/1070253056]
dccp_v4_destroy_sock+0xe7/0xee [dccp]
Feb 14 11:12:19 localhost kernel:  [sk_common_release+21/147]
sk_common_release+0x15/0x93
Feb 14 11:12:19 localhost kernel:  [inet_create+606/641] inet_create+0x25e/=
0x281
Feb 14 11:12:19 localhost kernel:  [__sock_create+295/533]
__sock_create+0x127/0x215
Feb 14 11:12:19 localhost kernel:  [sys_socket+23/63] sys_socket+0x17/0x3f
Feb 14 11:12:19 localhost kernel:  [sys_socketcall+86/363]
sys_socketcall+0x56/0x16b
Feb 14 11:12:19 localhost kernel:  [syscall_call+7/11] syscall_call+0x7/0xb
Feb 14 11:12:19 localhost kernel: Code: 68 31 2e ba e0 68 95 39 ba e0
e8 69 b5 57 df 83 c4 10 8d 65 f4 31 c0 5b 5e 5f 5d c3 55 89 e5 57 8b
7d 08 56 53 8b 9f 78 03 00 00 <8b> 33 eb 46 8b 43 0c 85 c0 75 08 0f 0b
ad 01 dd 37 ba e0 50 e8


--
Ian McDonald
http://wand.net.nz/~iam4
WAND Network Research Group
Department of Computer Science
University of Waikato
New Zealand
