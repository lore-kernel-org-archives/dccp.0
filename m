From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 19 Jun 2007 10:29:54 +0000
Subject: [PATCH 0/1]: Current BUGs
Message-Id: <200706191129.55105@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

I received note from Tommi Saviranta with bug information which is copied b=
elow.
One bug we had recently (reported by Florian Westphal), I attach my patch f=
or
it (having observed the same thing at home); now there is a third occurrenc=
e.

I believe we should fix this soon.


1. Write queue not empty=20
------------------------
|   "KERNEL: assertion (skb_queue_empty(&sk->sk_write_queue))
|  failed at net/core/stream.c (276)" in system log.
I observed this also at some time - but with TCP.


2. Out-of-order segments
------------------------
|  At some point I've also had the following line in syslog, possibly
|  related to failing full duplex:
|  =A0 =A0=20
|  =A0 =A0 dccp_check_seqno: DCCP: Step 6 failed for ACK packet,=20
|  =A0 =A0 (LSWL(194687531369580) <=3D P.seqno(194687531369777) <=3D S.SWH(=
194687531369679))=20
|  =A0 =A0 and (P.ackno exists=20
|  =A0 =A0 or LAWL(195643175609843) <=3D P.ackno(195643175713728) <=3D S.AW=
H(195643175713921),=20
|  =A0 =A0 sending SYNC...   =20
Ian observed this in December - the most recent occurrence was the Sync-flo=
od fixes
(which will be resubmitted soon).

3. Memory allocation while in atomic context (the bug)
------------------------------------------------------ =20
|  At worst case scenario, such as when running iperf,
|  =A0 host2% ./iperf --protocol DCCP -l 500 -c 192.168.1.1 -p 5001 -t 60
|  results in kernel panic which totally kills networking:
| =20
|  <snip>
|  CCID: Registered CCID 2 (ccid2)
|  BUG: sleeping function called from invalid context at mm/slab.c:3035
|  in_atomic():1, irqs_disabled():0
|  =A0[<c046ede5>] __kmalloc+0x42/0x7d
|  =A0[<e0ae106b>] ccid2_hc_tx_alloc_seq+0x23/0xa4 [dccp_ccid2]
|  =A0[<e0ae13d8>] ccid2_hc_tx_packet_sent+0x8d/0x13f [dccp_ccid2]
|  =A0[<e0ae134b>] ccid2_hc_tx_packet_sent+0x0/0x13f [dccp_ccid2]
|  =A0[<e0b2f13f>] dccp_write_xmit+0x20e/0x2c4 [dccp]
|  =A0[<c0439d17>] hrtimer_run_queues+0x127/0x141
|  =A0[<e0b2f813>] dccp_write_xmit_timer+0x0/0x51 [dccp]
|  =A0[<e0b2f846>] dccp_write_xmit_timer+0x33/0x51 [dccp]
|  =A0[<c042e51b>] run_timer_softirq+0x101/0x164
|  =A0[<c05c296f>] net_rx_action+0xca/0x185
|  =A0[<c042b7b0>] __do_softirq+0x5d/0xba
|  =A0[<c040615b>] do_softirq+0x59/0xb1
|  =A0[<c0450189>] handle_level_irq+0x0/0xdf
|  =A0[<c0406279>] do_IRQ+0xc6/0xdd
|  =A0[<c04048f3>] common_interrupt+0x23/0x28
|  =A0[<c04200d8>] find_busiest_group+0x1d2/0x4c3
|  =A0[<c05b9aff>] lock_sock_nested+0x20/0xa3
|  =A0[<c04ed070>] copy_from_user+0x3a/0x66
|  =A0[<e0b3083f>] dccp_sendmsg+0x2c/0x156 [dccp]
|  =A0[<c05ff51d>] inet_sendmsg+0x3b/0x45
|  =A0[<c05b74b5>] sock_aio_write+0xf9/0x105
|  =A0[<c04720ad>] do_sync_write+0xc7/0x10a
|  =A0[<c0437725>] autoremove_wake_function+0x0/0x35
|  =A0[<c0472900>] vfs_write+0xbc/0x154
|  =A0[<c0472f07>] sys_write+0x41/0x67
|  =A0[<c0403f64>] syscall_call+0x7/0xb
|  =A0=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D|  </snip>
| =20
This was observed first on http://www.mail-archive.com/dccp@vger.kernel.org=
/msg01811.html
A patch is attached - Arnaldo came up with an independent solution.
