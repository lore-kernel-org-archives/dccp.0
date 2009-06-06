From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sat, 06 Jun 2009 18:01:53 +0000
Subject: Re: yet another panic on 2.6.30-rc6
Message-Id: <20090606180153.GA10697@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <230029.26412.qm@web30005.mail.mud.yahoo.com>
In-Reply-To: <230029.26412.qm@web30005.mail.mud.yahoo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hi Burak,

thank you for raising this. We need to isolate the cause of the problem.

The dccp test tree is based on the netdev-2.6 tree maintained by Dave
Miller, which itself contains other trees (I think the total number of
kernel trees is ~130).

I am testing this tree myself, though mostly with audio streaming over
WiFi links, using the paraslash streamer.

From looking through the trace it looks as though this is a timer
problem. Any chance of getting the EIP value to see where it 

Regarding reproducability -- unfortunately I had just put in a new
revision onto eden-feed. Can you please consider pulling again from

	git://eden-feed.erg.abdn.ac.uk/dccp_exp [subtrees dccp/ccid4]

If this problem persists, it would be good to CC: netdev@vger as well.

It is quite possible that the problem may have cleared itself as a
result of using more recent sources. The dccp test tree gets a fresh
base at least every week, to avoid transient problems.

Thanks in advance
Gerrit


Quoting Burak Gorkemli:
|
| The console output for this one is as follows:
|
| [<>] do_trap
| [<>] ? do_invalid_op
| [<>] do_invalid_op
| [<>] ? ccid3_hc_tx_no_feedback_timer
| [<>] ? e1000_clean_rx_irq
| [<>] ? trace_hardirqs_off_thunk
| [<>] error_code
| [<>] ? __mod_timer
| [<>] ? do_invalid_op
| [<>] ? ccid3_hc_tx_no_feedback_timer
| [<>] run_timer_softirq
| [<>] ? ccid3_hc_tx_no_feedback_timer
| [<>] ? ccid3_hc_tx_no_feedback_timer
| [<>] __do_softirq
| [<>] ? __do_softirq
| <IRQ> [<>] ? irq_exit
| [<>] ? smp_apic_timer_interrupt
| [<>] ? apic_timer_interrupt
| [<>] ? native_safe_halt
| [<>] ? default_idle
| [<>] ? cpu_idle
| [<>] ? rest_init
| [<>] ? start_kernel
| [<>] ? i386_start_kernel
|
|  --
| Burak
|
|
|
| ----- Original Message ----
| > From: Burak Gorkemli 
| > To: dccp@vger.kernel.org
| > Sent: Saturday, June 6, 2009 1:58:59 AM
| > Subject: panic on 2.6.30-rc6
| >
| >
| > Hi,
| >
| > I am having kernel panic while doing video streaming tests with ccid3, using
| > kernel version 2.6.30-rc6, pulled from Gerrit's
| > tree. The crash happens on the receiver node (there is a sender node and a
| > receiver node, both Linux boxes running 2.6.30-rc6) and it is quite
| > reproducible. The console output is as follows:
| >
| > [<>] ? do_invalid_op
| > [<>] do_invalid_op
| > [<>] ? ccid3_hc_tx_no_feedback_timer
| > [<>] ? __wake_up
| > [<>] ? __kfree_skb
| > [<>] ? trace_hardirqs_off_thunk
| > [<>] error_code
| > [<>] ? __mod_timer
| > [<>] ? do_invalid_op
| > [<>] ? ccid3_hc_tx_no_feedback_timer
| > [<>] run_timer_softirq
| > [<>] ? ccid3_hc_tx_no_feedback_timer
| > [<>] ? ccid3_hc_tx_no_feedback_timer
| > [<>] __do_softirq
| > [<>] ? __do_softirq
| > [<>] ? irq_exit
| > [<>] ? smp_apic_timer_interrupt
| > [<>] ? apic_timer_interrupt
| > [<>] ? native_safe_halt
| > [<>] ? default_idle
| > [<>] ? cpu_idle
| > [<>] ? rest_init
| > [<>] ? start_kernel
| > [<>] ? i386_start_kernel
| >
| > Any comments?
