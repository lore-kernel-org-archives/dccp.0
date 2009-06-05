From: Burak Gorkemli <burakgmail-dccp@yahoo.com>
Date: Fri, 05 Jun 2009 22:58:59 +0000
Subject: panic on 2.6.30-rc6
Message-Id: <295033.28246.qm@web30002.mail.mud.yahoo.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org


Hi,

I am having kernel panic while doing video streaming tests with ccid3, using kernel version 2.6.30-rc6, pulled from Gerrit's
tree. The crash happens on the receiver node (there is a sender node and a receiver node, both Linux boxes running 2.6.30-rc6) and it is quite reproducible. The console output is as follows:

[<>] ? do_invalid_op
[<>] do_invalid_op
[<>] ? ccid3_hc_tx_no_feedback_timer
[<>] ? __wake_up
[<>] ? __kfree_skb
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

Any comments?

Thanks.

 --
Burak

