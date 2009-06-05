From: Burak Gorkemli <burakgmail-dccp@yahoo.com>
Date: Fri, 05 Jun 2009 23:13:41 +0000
Subject: yet another panic on 2.6.30-rc6
Message-Id: <230029.26412.qm@web30005.mail.mud.yahoo.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org


The console output for this one is as follows:

[<>] do_trap
[<>] ? do_invalid_op
[<>] do_invalid_op
[<>] ? ccid3_hc_tx_no_feedback_timer
[<>] ? e1000_clean_rx_irq
[<>] ? trace_hardirqs_off_thunk
[<>] error_code
[<>] ? __mod_timer
[<>] ? do_invalid_op
[<>] ? ccid3_hc_tx_no_feedback_timer
[<>] run_timer_softirq
[<>] ? ccid3_hc_tx_no_feedback_timer
[<>] ? ccid3_hc_tx_no_feedback_timer
[<>] __do_softirq
[<>] ? __do_softirq
<IRQ> [<>] ? irq_exit
[<>] ? smp_apic_timer_interrupt
[<>] ? apic_timer_interrupt
[<>] ? native_safe_halt
[<>] ? default_idle
[<>] ? cpu_idle
[<>] ? rest_init
[<>] ? start_kernel
[<>] ? i386_start_kernel

 --
Burak



----- Original Message ----
> From: Burak Gorkemli <burakgmail-dccp@yahoo.com>
> To: dccp@vger.kernel.org
> Sent: Saturday, June 6, 2009 1:58:59 AM
> Subject: panic on 2.6.30-rc6
> 
> 
> Hi,
> 
> I am having kernel panic while doing video streaming tests with ccid3, using 
> kernel version 2.6.30-rc6, pulled from Gerrit's
> tree. The crash happens on the receiver node (there is a sender node and a 
> receiver node, both Linux boxes running 2.6.30-rc6) and it is quite 
> reproducible. The console output is as follows:
> 
> [<>] ? do_invalid_op
> [<>] do_invalid_op
> [<>] ? ccid3_hc_tx_no_feedback_timer
> [<>] ? __wake_up
> [<>] ? __kfree_skb
> [<>] ? trace_hardirqs_off_thunk
> [<>] error_code
> [<>] ? __mod_timer
> [<>] ? do_invalid_op
> [<>] ? ccid3_hc_tx_no_feedback_timer
> [<>] run_timer_softirq
> [<>] ? ccid3_hc_tx_no_feedback_timer
> [<>] ? ccid3_hc_tx_no_feedback_timer
> [<>] __do_softirq
> [<>] ? __do_softirq 
> [<>] ? irq_exit
> [<>] ? smp_apic_timer_interrupt
> [<>] ? apic_timer_interrupt
> [<>] ? native_safe_halt
> [<>] ? default_idle
> [<>] ? cpu_idle
> [<>] ? rest_init
> [<>] ? start_kernel
> [<>] ? i386_start_kernel
> 
> Any comments?
> 
> Thanks.
> 
> --
> Burak
> 

