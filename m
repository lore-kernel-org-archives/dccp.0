From: "Arnaldo Carvalho de Melo" <acme@ghostprotocols.net>
Date: Tue, 28 Feb 2006 23:52:30 +0000
Subject: Re: [BUG] DCCP : Suspected race in ackvec code
Message-Id: <39e6f6c70602281552yaff71d8sef1394e904303a5d@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <cbec11ac0602281518uc14fe5fl73eda47b211a7d9f@mail.gmail.com>
In-Reply-To: <cbec11ac0602281518uc14fe5fl73eda47b211a7d9f@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 2/28/06, Arnaldo Carvalho de Melo <acme@ghostprotocols.net> wrote:
> On 2/28/06, Ian McDonald <imcdnzl@gmail.com> wrote:
> > When send_ackvec sysctl is on DCCP locks the machine. Unfortunately it
> > doesn't send any output to the kernel.
>
> I'm getting below results by just stopping the syslog daemon and setting
> printk log level to 9:
>
> [root@qemu ~]# service syslog stop
> [root@qemu ~]# echo 9 > /proc/sys/kernel/printk
>
> With this the printk messages goes to the console, allowing us to see the
> dccp_pr_debug messages till the very moment when a soft lockup happens
> at dccp_ackvec_parse.
>
> [root@qemu ~]# modprobe dccp dccp_debug=1
> [root@qemu ~]# echo 3 > /proc/sys/net/dccp/default/rx_ccid
> [root@qemu ~]# echo 3 > /proc/sys/net/dccp/default/tx_ccid
>
> Oh well, not reproducing it right now, try with these settings to see you
> reproduce it in your setup.

Ok, here it is, I guess the problem is some leak or bad handling of OOM in
the ackvec code, as it is more easily triggered when I boot qemu using
only 16M:

[42949433.470000] dccp_ackvec_add: <7>dccp_insert_option_elapsed_time:
CLIENT TX opt: ELAPSED_TIME12265, len=6, seqnoX78985321
[42949433.480000] dccp_insert_option_ackvec: CLIENT tx: ACK Vector 0,
len=1, ack_seqnoX78985321, ack_acknoX29316757
[42949433.480000] dccp_v4_rcv:  DATAACK src7.0.0.1@3408 
dst7.0.0.1@5001  seqX78985321, ackX29316757
[42949433.480000] dccp_parse_options: server rx opt: ELAPSED_TIME12265
[42949433.480000] dccp_ackvec_add: <7>dccp_insert_option_elapsed_time:
CLIENT TX opt: ELAPSED_TIME13363, len=6, seqnoX78985322
[42949433.490000] dccp_insert_option_ackvec: CLIENT tx: ACK Vector 0,
len=1, ack_seqnoX78985322, ack_acknoX29316757
[42949433.490000] dccp_v4_rcv:  DATAACK src7.0.0.1@3408 
dst7.0.0.1@5001  seqX78985322, ackX29316757
[42949433.490000] dccp_parse_options: server rx opt: ELAPSED_TIME13363
[42949433.490000] dccp_ackvec_add: <7>dccp_insert_option_elapsed_time:
CLIENT TX opt: ELAPSED_TIME14216, len=6, seqnoX78985323
[42949433.500000] dccp_insert_option_ackvec: CLIENT tx: ACK Vector 0,
len=1, ack_seqnoX78985323, ack_acknoX29316757
[42949433.500000] dccp_v4_rcv:  DATAACK src7.0.0.1@3408 
dst7.0.0.1@5001  seqX78985323, ackX29316757
[42949433.500000] dccp_parse_options: server rx opt: ELAPSED_TIME14216
[42949433.500000] dccp_ackvec_add: <7>dccp_insert_option_elapsed_time:
CLIENT TX opt: ELAPSED_TIME15700, len=6, seqnoX78985324
[42949433.510000] dccp_insert_option_ackvec: CLIENT tx: ACK Vector 0,
len=1, ack_seqnoX78985324, ack_acknoX29316757
[42949433.510000] dccp_v4_rcv:  DATAACK src7.0.0.1@3408 
dst7.0.0.1@5001  seqX78985324, ackX29316757
[42949433.510000] dccp_parse_options: server rx opt: ELAPSED_TIME15700
[42949433.510000] dccp_ackvec_add: <7>dccp_insert_option_elapsed_time:
CLIENT TX opt: ELAPSED_TIME16233, len=6, seqnoX78985325
[42949433.520000] dccp_insert_option_ackvec: CLIENT tx: ACK Vector 0,
len=1, ack_seqnoX78985325, ack_acknoX29316757
[42949433.520000] dccp_v4_rcv:  DATAACK src7.0.0.1@3408 
dst7.0.0.1@5001  seqX78985325, ackX29316757
[42949433.520000] dccp_parse_options: server rx opt: ELAPSED_TIME16233
[42949433.520000] dccp_ackvec_add: ttcp-t: 256000 bytes in 10.81 real
seconds = 23.14 KB/sec +++
ttcp-t: 1000 I/O calls, msec/call = 11.06, calls/sec = 92.54
ttcp-t: 0.0user 0.5sys 0:10real 5% 0i+0d 0maxrss 0+1pf 1011+40csw
<7>dccp_set_state: client(c0858380) OPEN       -> CLOSING
[42949433.530000] dccp_insert_option_elapsed_time: CLIENT TX opt:
ELAPSED_TIME17569, len=6, seqnoX78985326
[42949433.530000] dccp_insert_option_ackvec: CLIENT tx: ACK Vector 0,
len=1, ack_seqnoX78985326, ack_acknoX29316757
[42949433.530000] dccp_v4_rcv:    CLOSE src7.0.0.1@3408 
dst7.0.0.1@5001  seqX78985326, ackX29316757
[42949433.530000] dccp_parse_options: server rx opt: ELAPSED_TIME17569
[42949433.530000] dccp_ackvec_add: <7>dccp_insert_option_elapsed_time:
server TX opt: ELAPSED_TIME"0, len=4, seqnoX29316758
[42949433.530000] dccp_insert_option_ackvec: server tx: ACK Vector 0,
len, ack_seqnoX29316758, ack_acknoX78985326
[42949433.530000] dccp_set_state: server(c0858040) OPEN       -> CLOSED
[42949433.540000] dccp_v4_rcv:    RESET src7.0.0.1@5001 
dst7.0.0.1@3408  seqX29316758, ackX78985326
[42949433.540000] dccp_ackvec_check_rcv_ackvector: CLIENT rx ack: ACK
vector 0, len, ack_seqnoX78985326, ack_acknoX29316757, ACKED!
[42949442.920000] BUG: soft lockup detected on CPU#0!
[42949442.920000]
[42949442.920000] Pid: 576, comm:                 ttcp
[42949442.920000] EIP: 0060:[<c1827582>] CPU: 0
[42949442.920000] EIP is at dccp_ackvec_parse+0x1b2/0x270 [dccp]
[42949442.920000]  EFLAGS: 00000286    Not tainted  (2.6.16-rc4acme #1)
[42949442.920000] EAX: ffc30000 EBX: 00015e6a ECX: 326e0000 EDX: ffffffff
[42949442.920000] ESI: 32310000 EDI: 00015e6a EBP: c06a52c0 DS: 007b ES: 007b
[42949442.920000] CR0: 8005003b CR2: b7e84039 CR3: 0064c000 CR4: 00000690
[42949442.920000]  [<c18235dd>] dccp_parse_options+0x43d/0x770 [dccp]
[42949442.920000]  [<c0113935>] local_bh_enable+0x75/0x80
[42949442.920000]  [<c1821d1c>] dccp_rcv_state_process+0x7c/0x760 [dccp]
[42949442.920000]  [<c02142c2>] ip_queue_xmit+0x192/0x4a0
[42949442.920000]  [<c010f968>] vprintk+0x258/0x2d0
[42949442.920000]  [<c182f389>] dccp_v4_do_rcv+0x49/0x290 [dccp_ipv4]
[42949442.920000]  [<c18244dc>] dccp_transmit_skb+0x27c/0x410 [dccp]
[42949442.920000]  [<c01f2e59>] release_sock+0x59/0xa0
[42949442.920000]  [<c1825baf>] dccp_close+0xaf/0x200 [dccp]
[42949442.920000]  [<c02366bf>] inet_release+0x3f/0x70
[42949442.920000]  [<c01f0cef>] sock_release+0x1f/0x90
[42949442.920000]  [<c01f0d91>] sock_close+0x31/0x50
[42949442.920000]  [<c01448fd>] __fput+0x9d/0x150
[42949442.920000]  [<c0141972>] filp_close+0x52/0x90
[42949442.920000]  [<c010feeb>] put_files_struct+0x7b/0xd0
[42949442.920000]  [<c0110ea4>] do_exit+0x104/0x7b0
[42949442.920000]  [<c02c4ba4>] pcibios_fixup_bus+0xc4/0x120
[42949442.920000]  [<c02c4ba0>] pcibios_fixup_bus+0xc0/0x120
[42949442.920000]  [<c02c4bd0>] pcibios_fixup_bus+0xf0/0x120
[42949442.920000]  [<c0111584>] do_group_exit+0x34/0x70
[42949442.920000]  [<c0102755>] syscall_call+0x7/0xb
