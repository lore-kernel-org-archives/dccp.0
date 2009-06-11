From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 11 Jun 2009 19:52:46 +0000
Subject: Re: yet another panic on 2.6.30-rc6
Message-Id: <20090611195246.GA29936@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <230029.26412.qm@web30005.mail.mud.yahoo.com>
In-Reply-To: <230029.26412.qm@web30005.mail.mud.yahoo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hi Burak,

it would be good to have more information, how this bug can be triggered:

 * what is the hardware,
 * can it be reproduced in the same manner on other hardware,
 * with which configuration (.config file),
 * does it only happen with CCID 3? Here it is good to know whether
   - Tickless System (CONFIG_NO_HZ) or
   - High-resolution timers (CONFIG_HIGH_RES_TIMERS)
   are enabled,
 * enabling kernel debugging features (below).

Further - are you running DCCP in a virtualised environment?

I checked some of the functions below: "default_spin_lock_flags" is defined
in arch/x86/kernel/paravirt-spinlocks.c. When running a network protocol
that is designed for longer distance networks, some underlying assumptions
may no longer hold in the same way as designed.

| BTW, how to print EIP after the panic?
It needs to be enabled in the kernel configuration. Please enable

 1/ "General setup"  -> "BUG() support"    (CONFIG_BUG=y)
 2/ "Kernel hacking" -> "Kernel debugging" (CONFIG_DEBUG_KERNEL=y)
 3/ "Kernel hacking" (depends on (2) ->
    "Verbose BUG() reporting (adds 70k)"   (CONFIG_DEBUG_BUGVERBOSE=y)
 4/ When enabling (2), it also can not harm to enable the

| The console output of the latest panic is as follows:
|
| [<>] ? ccid3_hc_tx_no_feedback_timer
| [<>] ? default_spin_lock_flags
| [<>] ? elv_queue_empty
| [<>] ? blk_run_queue
| [<>] ? kobject_put
| [<>] ? trace_hardirqs_off_thunk
| [<>] error_code
| [<>] ? __mode_timer
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
