From: "S. P. Prasanna" <prasanna@in.ibm.com>
Date: Thu, 07 Jun 2007 04:34:29 +0000
Subject: Re: [PATCH] Kprobes i386 fix for mark ro data
Message-Id: <20070607042229.GA9350@in.ibm.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

On Thu, Jun 07, 2007 at 11:12:32AM +1200, Ian McDonald wrote:
> On 6/7/07, Chuck Ebbert <cebbert@redhat.com> wrote:
> >On 06/06/2007 04:47 PM, Ian McDonald wrote:
> >> Hi there,
> >>
> >> We've seen a report of a problem with dccp_probe as shown below. The
> >> user has also verified that it occurs in tcp_probe as well. This is on
> >> Dave Miller's tree but that currently tracks Linus' tree quite
> >> closely. I do note that it is around 2.6.22-rc2 timeframe so there is
> >> a possibility fixes may have gone in since.
> >>
> >
> >It faulted when it tried to write the breakpoint instruction into the
> >running kernel's executable code. Apparently the kernel code is now mark=
ed
> >read-only?
> >
> >
> Yes it would appear to be the case as user has CONFIG_DEBUG_RODATA
> set. Patrick - can you turn this off and retest? It's under Kernel
> Hacking, Write protect kernel read only data structures.
>=20
> The list of commits that I see around this are at:
> http://git.kernel.org/?p=3Dlinux%2Fkernel%2Fgit%2Ftorvalds%2Flinux-2.6.gi=
t&a=3Dsearch&h=3DHEAD&st=3Dcommit&s=DEBUG_RODATA
>=20
> I suspect it's probably one of the latter ones giving the timing.
>=20
> I guess there are a couple of solutions here - either make kprobes
> conflict with CONFIG_DEBUG_RODATA so you can do one or the other, or
> look into more detail what access kprobes need.
>=20
> Ian

Ian,

Please find the fix as suggested by Andi Kleen=20
for the above stated problem.

Thanks
Prasanna


This patch fixes the problem of page protection introduced by
CONFIG_DEBUG_RODATA. CONFIG_DEBUG_RODATA marks the text pages as
read-only, hence kprobes is unable to insert breakpoints in the
kernel text. This patch overrides the page protection when adding
or removing a probe for the i386 architecture.

Signed-off-by: Prasanna S P<prasanna@in.ibm.com>
Ack-ed-by: Jim Keniston <jkenisto@us.ibm.com>



 arch/i386/kernel/kprobes.c |   26 ++++++++++++++++++++++++++
 arch/i386/mm/init.c        |    2 ++
 include/asm-i386/kprobes.h |   12 ++++++++++++
 include/asm-i386/pgtable.h |    2 ++
 4 files changed, 42 insertions(+)

diff -puN arch/i386/kernel/kprobes.c~kprobes-mark-ro-data-fix-i386 arch/i38=
6/kernel/kprobes.c
--- linux-2.6.22-rc2/arch/i386/kernel/kprobes.c~kprobes-mark-ro-data-fix-i3=
86	2007-06-07 09:19:26.000000000 +0530
+++ linux-2.6.22-rc2-prasanna/arch/i386/kernel/kprobes.c	2007-06-07 09:19:2=
6.000000000 +0530
@@ -169,16 +169,42 @@ int __kprobes arch_prepare_kprobe(struct
=20
 void __kprobes arch_arm_kprobe(struct kprobe *p)
 {
+	unsigned long addr =3D (unsigned long) p->addr;
+	int page_readonly =3D 0;
+
+	if (kernel_readonly_text(addr)) {
+		page_readonly =3D 1;
+		change_page_attr(virt_to_page(addr), 1, PAGE_KERNEL_RWX);
+		global_flush_tlb();
+	}
+
 	*p->addr =3D BREAKPOINT_INSTRUCTION;
 	flush_icache_range((unsigned long) p->addr,
 			   (unsigned long) p->addr + sizeof(kprobe_opcode_t));
+
+	if (page_readonly) {
+		change_page_attr(virt_to_page(addr), 1, PAGE_KERNEL_RX);
+		global_flush_tlb();
+	}
 }
=20
 void __kprobes arch_disarm_kprobe(struct kprobe *p)
 {
+	unsigned long addr =3D (unsigned long) p->addr;
+	int page_readonly =3D 0;
+
+	if (kernel_readonly_text(addr)) {
+		page_readonly =3D 1;
+		change_page_attr(virt_to_page(addr), 1, PAGE_KERNEL_RWX);
+		global_flush_tlb();
+	}
 	*p->addr =3D p->opcode;
 	flush_icache_range((unsigned long) p->addr,
 			   (unsigned long) p->addr + sizeof(kprobe_opcode_t));
+	if (page_readonly) {
+		change_page_attr(virt_to_page(addr), 1, PAGE_KERNEL_RX);
+		global_flush_tlb();
+	}
 }
=20
 void __kprobes arch_remove_kprobe(struct kprobe *p)
diff -puN include/asm-i386/kprobes.h~kprobes-mark-ro-data-fix-i386 include/=
asm-i386/kprobes.h
--- linux-2.6.22-rc2/include/asm-i386/kprobes.h~kprobes-mark-ro-data-fix-i3=
86	2007-06-07 09:19:26.000000000 +0530
+++ linux-2.6.22-rc2-prasanna/include/asm-i386/kprobes.h	2007-06-07 09:19:2=
6.000000000 +0530
@@ -26,6 +26,8 @@
  */
 #include <linux/types.h>
 #include <linux/ptrace.h>
+#include <linux/pfn.h>
+#include <asm-generic/sections.h>
=20
 #define  __ARCH_WANT_KPROBES_INSN_SLOT
=20
@@ -90,4 +92,14 @@ static inline void restore_interrupts(st
=20
 extern int kprobe_exceptions_notify(struct notifier_block *self,
 				    unsigned long val, void *data);
+extern int kernel_text_is_ro;
+static inline int kernel_readonly_text(unsigned long address)
+{
+
+	if (kernel_text_is_ro && ((address >=3D PFN_ALIGN(_text))
+				&& (address < PFN_ALIGN(_etext))))
+		return 1;
+
+	return 0;
+}
 #endif				/* _ASM_KPROBES_H */
diff -puN include/asm-i386/pgtable.h~kprobes-mark-ro-data-fix-i386 include/=
asm-i386/pgtable.h
--- linux-2.6.22-rc2/include/asm-i386/pgtable.h~kprobes-mark-ro-data-fix-i3=
86	2007-06-07 09:19:26.000000000 +0530
+++ linux-2.6.22-rc2-prasanna/include/asm-i386/pgtable.h	2007-06-07 09:19:2=
6.000000000 +0530
@@ -159,6 +159,7 @@ void paging_init(void);
 extern unsigned long long __PAGE_KERNEL, __PAGE_KERNEL_EXEC;
 #define __PAGE_KERNEL_RO		(__PAGE_KERNEL & ~_PAGE_RW)
 #define __PAGE_KERNEL_RX		(__PAGE_KERNEL_EXEC & ~_PAGE_RW)
+#define __PAGE_KERNEL_RWX		(__PAGE_KERNEL_EXEC | _PAGE_RW)
 #define __PAGE_KERNEL_NOCACHE		(__PAGE_KERNEL | _PAGE_PCD)
 #define __PAGE_KERNEL_LARGE		(__PAGE_KERNEL | _PAGE_PSE)
 #define __PAGE_KERNEL_LARGE_EXEC	(__PAGE_KERNEL_EXEC | _PAGE_PSE)
@@ -167,6 +168,7 @@ extern unsigned long long __PAGE_KERNEL,
 #define PAGE_KERNEL_RO		__pgprot(__PAGE_KERNEL_RO)
 #define PAGE_KERNEL_EXEC	__pgprot(__PAGE_KERNEL_EXEC)
 #define PAGE_KERNEL_RX		__pgprot(__PAGE_KERNEL_RX)
+#define PAGE_KERNEL_RWX		__pgprot(__PAGE_KERNEL_RWX)
 #define PAGE_KERNEL_NOCACHE	__pgprot(__PAGE_KERNEL_NOCACHE)
 #define PAGE_KERNEL_LARGE	__pgprot(__PAGE_KERNEL_LARGE)
 #define PAGE_KERNEL_LARGE_EXEC	__pgprot(__PAGE_KERNEL_LARGE_EXEC)
diff -puN arch/i386/mm/init.c~kprobes-mark-ro-data-fix-i386 arch/i386/mm/in=
it.c
--- linux-2.6.22-rc2/arch/i386/mm/init.c~kprobes-mark-ro-data-fix-i386	2007=
-06-07 09:19:26.000000000 +0530
+++ linux-2.6.22-rc2-prasanna/arch/i386/mm/init.c	2007-06-07 09:19:26.00000=
0000 +0530
@@ -45,6 +45,7 @@
 #include <asm/sections.h>
 #include <asm/paravirt.h>
=20
+int kernel_text_is_ro;
 unsigned int __VMALLOC_RESERVE =3D 128 << 20;
=20
 DEFINE_PER_CPU(struct mmu_gather, mmu_gathers);
@@ -807,6 +808,7 @@ void mark_rodata_ro(void)
 		change_page_attr(virt_to_page(start),
 		                 size >> PAGE_SHIFT, PAGE_KERNEL_RX);
 		printk("Write protecting the kernel text: %luk\n", size >> 10);
+		kernel_text_is_ro =3D 1;
 	}
=20
 	start +=3D size;

_
