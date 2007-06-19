From: "Arnaldo Carvalho de Melo" <acme@ghostprotocols.net>
Date: Tue, 19 Jun 2007 13:48:16 +0000
Subject: Re: [PATCH 0/1]: Current BUGs
Message-Id: <39e6f6c70706190648q5669fe2bv9a6ccefc88aedabc@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200706191129.55105@strip-the-willow>
In-Reply-To: <200706191129.55105@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 6/19/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> I received note from Tommi Saviranta with bug information which is copied below.
> One bug we had recently (reported by Florian Westphal), I attach my patch for
> it (having observed the same thing at home); now there is a third occurrence.
>
> I believe we should fix this soon.
>
>
> 1. Write queue not empty
> ------------------------
> |   "KERNEL: assertion (skb_queue_empty(&sk->sk_write_queue))
> |  failed at net/core/stream.c (276)" in system log.
> I observed this also at some time - but with TCP.

Humm, this means that when we call sk_stream_kill_queues, that now is
only called from inet_csk_destroy_sock (the other user is out of the
tree, in LLC patches I never got enough time to polish and submit)
that is called in three places:

-> when we are killing childs that we're almost finishing the
connection setup (in inet_csk_listen_stop, called from dccp_close on
the master socket or in dccp_disconnect)

-> in dccp_close for a client socket

-> in dccp_done, that is when the socket is in TIME_WAIT, finally
having its last remnants released or in error conditions (write error
-> timeout)

The BUG_TRAP basically means that we have packet(s) in the
sk_write_queue, that we should have purged before, ideas?

> 2. Out-of-order segments
> ------------------------
> |  At some point I've also had the following line in syslog, possibly
> |  related to failing full duplex:
> |
> |   dccp_check_seqno: DCCP: Step 6 failed for ACK packet,
> |   (LSWL(194687531369580) <= P.seqno(194687531369777) <= S.SWH(194687531369679))
> |   and (P.ackno exists
> |   or LAWL(195643175609843) <= P.ackno(195643175713728) <= S.AWH(195643175713921),
> |   sending SYNC...
> Ian observed this in December - the most recent occurrence was the Sync-flood fixes
> (which will be resubmitted soon).

OK, try to make it applicable to what we have in net-2.6.23, i.e.
independent of the stuff we have now in the experimental tree.

> 3. Memory allocation while in atomic context (the bug)
> ------------------------------------------------------
> |  At worst case scenario, such as when running iperf,
> |   host2% ./iperf --protocol DCCP -l 500 -c 192.168.1.1 -p 5001 -t 60
> |  results in kernel panic which totally kills networking:
> |
> |  <snip>
> |  CCID: Registered CCID 2 (ccid2)
> |  BUG: sleeping function called from invalid context at mm/slab.c:3035
> |  in_atomic():1, irqs_disabled():0
> |  [<c046ede5>] __kmalloc+0x42/0x7d
> |  [<e0ae106b>] ccid2_hc_tx_alloc_seq+0x23/0xa4 [dccp_ccid2]
> |  [<e0ae13d8>] ccid2_hc_tx_packet_sent+0x8d/0x13f [dccp_ccid2]
> |  [<e0ae134b>] ccid2_hc_tx_packet_sent+0x0/0x13f [dccp_ccid2]
> |  [<e0b2f13f>] dccp_write_xmit+0x20e/0x2c4 [dccp]
> |  [<c0439d17>] hrtimer_run_queues+0x127/0x141
> |  [<e0b2f813>] dccp_write_xmit_timer+0x0/0x51 [dccp]
> |  [<e0b2f846>] dccp_write_xmit_timer+0x33/0x51 [dccp]
> |  [<c042e51b>] run_timer_softirq+0x101/0x164
> |  [<c05c296f>] net_rx_action+0xca/0x185
> |  [<c042b7b0>] __do_softirq+0x5d/0xba
> |  [<c040615b>] do_softirq+0x59/0xb1
> |  [<c0450189>] handle_level_irq+0x0/0xdf
> |  [<c0406279>] do_IRQ+0xc6/0xdd
> |  [<c04048f3>] common_interrupt+0x23/0x28
> |  [<c04200d8>] find_busiest_group+0x1d2/0x4c3
> |  [<c05b9aff>] lock_sock_nested+0x20/0xa3
> |  [<c04ed070>] copy_from_user+0x3a/0x66
> |  [<e0b3083f>] dccp_sendmsg+0x2c/0x156 [dccp]
> |  [<c05ff51d>] inet_sendmsg+0x3b/0x45
> |  [<c05b74b5>] sock_aio_write+0xf9/0x105
> |  [<c04720ad>] do_sync_write+0xc7/0x10a
> |  [<c0437725>] autoremove_wake_function+0x0/0x35
> |  [<c0472900>] vfs_write+0xbc/0x154
> |  [<c0472f07>] sys_write+0x41/0x67
> |  [<c0403f64>] syscall_call+0x7/0xb
> |  ===========> |  </snip>
> |
> This was observed first on http://www.mail-archive.com/dccp@vger.kernel.org/msg01811.html
> A patch is attached - Arnaldo came up with an independent solution.

Doh, I just applied my patch, will be in net-2.6.23 and I'll ask DaveM
to have it in 2.6.22 and the stable@kernel.org guys to get it into
stable as well.

- Arnaldo
