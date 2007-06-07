From: Florian Westphal <fw@strlen.de>
Date: Thu, 07 Jun 2007 19:43:53 +0000
Subject: 'BUG: scheduling while atomic' during dccp transfer
Message-Id: <20070607194353.GA32086@Chamillionaire.breakpoint.cc>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

While transmitting data via dccp (Linux 2.6.21) I encountered this:

BUG: scheduling while atomic: firefox-bin/0x10000100/6792
 [<c02f8f4c>] schedule+0x43c/0x5c0
 [<c029c3af>] skb_checksum+0x4f/0x2a0
 [<c013818a>] handle_level_irq+0x7a/0xc0
 [<c01145d6>] __cond_resched+0x16/0x40
 [<c02f914a>] cond_resched+0x2a/0x40
 [<c0151d8a>] __kmalloc+0x6a/0x80
 [<d079e0ca>] ccid2_hc_tx_alloc_seq+0x4a/0xd0 [dccp_ccid2]
 [<d079e67c>] ccid2_hc_tx_packet_sent+0x13c/0x170 [dccp_ccid2]
 [<d079e540>] ccid2_hc_tx_packet_sent+0x0/0x170 [dccp_ccid2]
 [<d07ab917>] dccp_write_xmit+0x207/0x300 [dccp]
 [<d07ad667>] dccp_write_xmit_timer+0x37/0x40 [dccp]
 [<c011e843>] run_timer_softirq+0x123/0x180
 [<d07ad630>] dccp_write_xmit_timer+0x0/0x40 [dccp]
 [<d07ad630>] dccp_write_xmit_timer+0x0/0x40 [dccp]
 [<c011b522>] __do_softirq+0x42/0x90
 [<c011b596>] do_softirq+0x26/0x30
 [<c011b85a>] irq_exit+0x5a/0x60
 [<c0105ced>] do_IRQ+0x3d/0x70
 [<c011b228>] sys_gettimeofday+0x28/0x80
 [<c01040db>] common_interrupt+0x23/0x28
 [<c02f0000>] km_policy_expired+0x10/0x50
 ===========
Please CC me on replies, i'm not subscribed.
Thanks, Florian.
