From: "S. P. Prasanna" <prasanna@in.ibm.com>
Date: Thu, 07 Jun 2007 04:36:21 +0000
Subject: Re: [PATCH] Kprobes x86_64 fix for mark ro data
Message-Id: <20070607042421.GB9350@in.ibm.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org


This patch fixes the problem of page protection introduced by
CONFIG_DEBUG_RODATA for x86_64 architecture. As per Andi
Kleen's suggestion, the kernel text pages are marked writeable
only for a short duration to insert or remove the breakpoints.

Signed-off-by: Prasanna S P<prasanna@in.ibm.com>
Ack-ed-by: Jim Keniston <jkenisto@us.ibm.com>


 arch/x86_64/kernel/kprobes.c |   26 ++++++++++++++++++++++++++
 arch/x86_64/mm/init.c        |    6 +++++-
 include/asm-x86_64/kprobes.h |   10 ++++++++++
 3 files changed, 41 insertions(+), 1 deletion(-)

diff -puN arch/x86_64/kernel/kprobes.c~kprobes-mark-ro-data-fix-x86_64 arch/x86_64/kernel/kprobes.c
--- linux-2.6.22-rc2/arch/x86_64/kernel/kprobes.c~kprobes-mark-ro-data-fix-x86_64	2007-06-07 09:20:33.000000000 +0530
+++ linux-2.6.22-rc2-prasanna/arch/x86_64/kernel/kprobes.c	2007-06-07 09:20:33.000000000 +0530
@@ -209,16 +209,42 @@ static void __kprobes arch_copy_kprobe(s
 
 void __kprobes arch_arm_kprobe(struct kprobe *p)
 {
+	unsigned long addr = (unsigned long)p->addr;
+	int page_readonly = 0;
+
+	if (kernel_readonly_text(addr)) {
+		change_page_attr_addr(addr, 1, PAGE_KERNEL_EXEC);
+		global_flush_tlb();
+		page_readonly = 1;
+	}
 	*p->addr = BREAKPOINT_INSTRUCTION;
 	flush_icache_range((unsigned long) p->addr,
 			   (unsigned long) p->addr + sizeof(kprobe_opcode_t));
+	if (page_readonly) {
+		change_page_attr_addr(addr, 1, PAGE_KERNEL_RO);
+		global_flush_tlb();
+	}
 }
 
 void __kprobes arch_disarm_kprobe(struct kprobe *p)
 {
+	unsigned long addr = (unsigned long)p->addr;
+	int page_readonly = 0;
+
+	if (kernel_readonly_text(addr)) {
+		change_page_attr_addr(addr, 1, PAGE_KERNEL_EXEC);
+		global_flush_tlb();
+		page_readonly = 1;
+	}
+
 	*p->addr = p->opcode;
 	flush_icache_range((unsigned long) p->addr,
 			   (unsigned long) p->addr + sizeof(kprobe_opcode_t));
+
+	if (page_readonly) {
+		change_page_attr_addr(addr, 1, PAGE_KERNEL_RO);
+		global_flush_tlb();
+	}
 }
 
 void __kprobes arch_remove_kprobe(struct kprobe *p)
diff -puN include/asm-x86_64/kprobes.h~kprobes-mark-ro-data-fix-x86_64 include/asm-x86_64/kprobes.h
--- linux-2.6.22-rc2/include/asm-x86_64/kprobes.h~kprobes-mark-ro-data-fix-x86_64	2007-06-07 09:20:33.000000000 +0530
+++ linux-2.6.22-rc2-prasanna/include/asm-x86_64/kprobes.h	2007-06-07 09:20:33.000000000 +0530
@@ -26,6 +26,7 @@
 #include <linux/types.h>
 #include <linux/ptrace.h>
 #include <linux/percpu.h>
+#include <asm-generic/sections.h>
 
 #define  __ARCH_WANT_KPROBES_INSN_SLOT
 
@@ -88,4 +89,13 @@ extern int kprobe_handler(struct pt_regs
 
 extern int kprobe_exceptions_notify(struct notifier_block *self,
 				    unsigned long val, void *data);
+extern int kernel_text_is_ro;
+static inline int kernel_readonly_text(unsigned long address)
+{
+	if (kernel_text_is_ro && ((address >= (unsigned long)_stext)
+					&& (address < (unsigned long) _etext)))
+		return 1;
+
+	return 0;
+}
 #endif				/* _ASM_KPROBES_H */
diff -puN arch/x86_64/mm/init.c~kprobes-mark-ro-data-fix-x86_64 arch/x86_64/mm/init.c
--- linux-2.6.22-rc2/arch/x86_64/mm/init.c~kprobes-mark-ro-data-fix-x86_64	2007-06-07 09:20:33.000000000 +0530
+++ linux-2.6.22-rc2-prasanna/arch/x86_64/mm/init.c	2007-06-07 09:20:33.000000000 +0530
@@ -48,6 +48,7 @@
 #define Dprintk(x...)
 #endif
 
+int kernel_text_is_ro;
 const struct dma_mapping_ops* dma_ops;
 EXPORT_SYMBOL(dma_ops);
 
@@ -598,10 +599,13 @@ void mark_rodata_ro(void)
 {
 	unsigned long start = (unsigned long)_stext, end;
 
+	kernel_text_is_ro = 1;
 #ifdef CONFIG_HOTPLUG_CPU
 	/* It must still be possible to apply SMP alternatives. */
-	if (num_possible_cpus() > 1)
+	if (num_possible_cpus() > 1) {
 		start = (unsigned long)_etext;
+		kernel_text_is_ro = 0;
+	}
 #endif
 	end = (unsigned long)__end_rodata;
 	start = (start + PAGE_SIZE - 1) & PAGE_MASK;

_
-- 
Prasanna S.P.
Linux Technology Center
India Software Labs, IBM Bangalore
Email: prasanna@in.ibm.com
Ph: 91-80-41776329
