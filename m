From: devzero@web.de
Date: Tue, 08 Jan 2008 22:06:25 +0000
Subject: FW:  ccid2/ccid3 oopses
Message-Id: <93680347@web.de>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

Hello !

as suggested by Ian McDonald, i`m forwarding this to dccp and netdev mailin=
g lists.


> hi !
>
> i know dccp_ccid2 and ccid3 modules are considered experimental, but i`m =
unsure if i probably triggered a bug inside or outside that modules here (i=
`m no kernel developer)
>
> apparently, i got crashes when loading/unloading other driver modules jus=
t after ccid2 or ccid3 had been loaded/unloaded _once_ (have not used them =
at all, just modprobe module;modprobe -r module)
>
> this was detected during some hardcore module load/unload testing session=
 and apparently these modules seem to be the root cause of other modules cr=
ashing, so they seem to leave the system in an inconsistent state after loa=
d/unload.
>
> this can be reproduced with recent 2.6.24rc6 kernel which was mostly buil=
t with allmodconfig.
> i could not reproduce this with a more minimalistic configuration, e.g. t=
he suse kernel of the day runs fine.
>
> the easiest way to reproduce is:
>
> while true;do modprobe dccp_ccid2/3;modprobe -r dccp_ccid2/3;done
> after short time, the kernel oopses (messages below)
>
> i`m not sure if this is worth to be filed at kernel bugzilla, so i`m cont=
acting you personally first.
>
> i`d happily assist in helping debug this or provide more input (.config e=
tc) if you want to take a look.
>
> regards
> Roland=20
>
>
> [ 2322.177054] CCID: Unregistered CCID 2 (ccid2)
> [ 2322.377927] CCID: Registered CCID 2 (ccid2)
>
> [ 2322.413793] BUG: unable to handle kernel paging request at virtual add=
ress 40000864
> [ 2322.425066] printing eip: c01792e1 *pde =3D 00000000
> [ 2322.431523] Oops: 0000 [#1] SMP
> [ 2322.435249] Modules linked in: dccp_ccid2 dccp edd iptable_filter ip_t=
ables ip6table_filter ip6_tables x_tables ipv6 microcode firmware_class fus=
e loop dm_mod ide_cd cdrom pata_acpi ata_piix ahci parport_pc floppy ata_ge=
neric parport pcnet32 rtc_cmos libata rtc_core rtc_lib mii pcspkr container=
 thermal piix generic i2c_piix4 processor button ac i2c_core power_supply s=
hpchp ide_core intel_agp pci_hotplug agpgart mousedev evdev sg ext3 jbd mbc=
ache sd_mod mptspi mptscsih mptbase scsi_transport_spi ehci_hcd uhci_hcd sc=
si_mod usbcore
> [ 2322.489115]
> [ 2322.491535] Pid: 1730, comm: kjournald Not tainted (2.6.24-rc6 #4)
> [ 2322.497266] EIP: 0060:[<c01792e1>] EFLAGS: 00010002 CPU: 0
> [ 2322.503205] EIP is at kmem_cache_alloc+0x5d/0xa6
> [ 2322.508789] EAX: 00000000 EBX: 00000282 ECX: c03750a0 EDX: 40000864
> [ 2322.514864] ESI: c1408314 EDI: 40000864 EBP: c03750a0 ESP: df9cfe94
> [ 2322.521110]  DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0068
> [ 2322.527346] Process kjournald (pid: 1730, ti=DF9ce000 task=DEaf31a0 ta=
sk.ti=DF9ce000)
> [ 2322.535722] Stack: c016094d c1408314 40000864 00011200 df4032a0 df408e=
40 def45000 0000000f
> [ 2322.545350]        00011210 c016094d 00000010 e08cb15f 00000000 dead9c=
00 df161ab8 00000004
> [ 2322.556833]        00000000 def45000 0000000f 00000000 c019acdf 000000=
00 df402940 00000010
> [ 2322.565168] Call Trace:
> [ 2322.568637]  [<c016094d>] mempool_alloc+0x24/0xc2
> [ 2322.573169]  [<c016094d>] mempool_alloc+0x24/0xc2
> [ 2322.577175]  [<e08cb15f>] __journal_file_buffer+0x9b/0x11c [jbd]
> [ 2322.585033]  [<c019acdf>] bio_alloc_bioset+0x8c/0xe6
> [ 2322.589301]  [<c019ad44>] bio_alloc+0xb/0x17
> [ 2322.593309]  [<c0197688>] submit_bh+0x6e/0xf8
> [ 2322.597358]  [<e08ccdba>] journal_commit_transaction+0x6de/0xbe8 [jbd]
> [ 2322.605109]  [<c013095c>] lock_timer_base+0x19/0x35
> [ 2322.610478]  [<e08cf9e6>] kjournald+0xae/0x1dd [jbd]
> [ 2322.616182]  [<c0139985>] autoremove_wake_function+0x0/0x33
> [ 2322.621341]  [<e08cf938>] kjournald+0x0/0x1dd [jbd]
> [ 2322.628588]  [<c01398bc>] kthread+0x38/0x60
> [ 2322.633306]  [<c0139884>] kthread+0x0/0x60
> [ 2322.637365]  [<c0107beb>] kernel_thread_helper+0x7/0x10
> [ 2322.645002]  =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D> [ 2322.649049] Code: 3=
e 85 ff 89 7c 24 08 75 1b 89 14 24 8b 54 24 0c 83 c9 ff 89 e8 89 74 24 04 e=
8 2b fb ff ff 89 44 24 08 eb 0c 8b 54 24 08 8b 46 0c <8b> 04 82 89 06 89 d8=
 50 9d 0f 1f 84 00 00 00 00 00 66 83 7c 24
> [ 2322.673340] EIP: [<c01792e1>] kmem_cache_alloc+0x5d/0xa6 SS:ESP 0068:d=
f9cfe94
> [ 2322.681327] ---[ end trace 35dbcab07ee48cc5 ]---
> [ 2322.737700] ------------[ cut here ]------------
> [ 2322.748822] Kernel BUG at c0199e6d [verbose debug info unavailable]
> [ 2322.755960] invalid opcode: 0000 [#2] SMP
> [ 2322.760773] Modules linked in: dccp_ccid2 dccp edd iptable_filter ip_t=
ables ip6table_filter ip6_tables x_tables ipv6 microcode firmware_class fus=
e loop dm_mod ide_cd cdrom pata_acpi ata_piix ahci parport_pc floppy ata_ge=
neric parport pcnet32 rtc_cmos libata rtc_core rtc_lib mii pcspkr container=
 thermal piix generic i2c_piix4 processor button ac i2c_core power_supply s=
hpchp ide_core intel_agp pci_hotplug agpgart mousedev evdev sg ext3 jbd mbc=
ache sd_mod mptspi mptscsih mptbase scsi_transport_spi ehci_hcd uhci_hcd sc=
si_mod usbcore
> [ 2322.813338]
> [ 2322.817134] Pid: 3125, comm: klogd Tainted: G      D (2.6.24-rc6 #4)
> [ 2322.821416] EIP: 0060:[<c0199e6d>] EFLAGS: 00010246 CPU: 0
> [ 2322.828832] EIP is at end_buffer_async_write+0x6f/0xfd
> [ 2322.833341] EAX: 00000000 EBX: df1d2268 ECX: df1d2268 EDX: 00000001
> [ 2322.839963] ESI: def45080 EDI: df77c0c0 EBP: c13a9d40 ESP: dee9be6c
> [ 2322.845409]  DS: 007b ES: 007b FS: 00d8 GS: 0033 SS: 0068
> [ 2322.851864] Process klogd (pid: 3125, ti=DEe9a000 task=DF474bc0 task.t=
i=DEe9a000)
> [ 2322.859787] Stack: dfa61000 00000015 ffffffff e088db79 c0107a5c ffffff=
ff 00000202 00000200
> [ 2322.868770]        e088db79 dfa61000 def45080 def45080 df77c0c0 000010=
00 c01994fd c01994dc
> [ 2322.877370]        c019a99d 00001000 c01d919a 00000000 dee9bedc c02d8c=
44 dee9bfa0 dee9bedc
> [ 2322.887755] Call Trace:
> [ 2322.889427]  [<e088db79>] mptscsih_io_done+0x0/0xa52 [mptscsih]
> [ 2322.896192]  [<c0107a5c>] apic_timer_interrupt+0x28/0x30
> [ 2322.901439]  [<e088db79>] mptscsih_io_done+0x0/0xa52 [mptscsih]
> [ 2322.909389]  [<c01994fd>] end_bio_bh_io_sync+0x21/0x29
> [ 2322.915672]  [<c01994dc>] end_bio_bh_io_sync+0x0/0x29
> [ 2322.921404]  [<c019a99d>] bio_endio+0x27/0x29
> [ 2322.928198]  [<c01d919a>] __end_that_request_first+0x192/0x33d
> [ 2322.933405]  [<e0816a93>] scsi_end_request+0x1a/0xa8 [scsi_mod]
> [ 2322.940634]  [<e081761b>] scsi_io_completion+0x14c/0x2fb [scsi_mod]
> [ 2322.947318]  [<c01db7e1>] blk_done_softirq+0x5b/0x67
> [ 2322.953414]  [<c012cfae>] __do_softirq+0x75/0xe1
> [ 2322.957435]  [<c012d05f>] do_softirq+0x45/0x53
> [ 2322.962434]  [<c012d2c3>] irq_exit+0x38/0x6b
> [ 2322.966576]  [<c0109843>] do_IRQ+0x5c/0x71
> [ 2322.971256]  [<c012d2de>] irq_exit+0x53/0x6b
> [ 2322.975864]  [<c011a12a>] smp_apic_timer_interrupt+0x71/0x7d
> [ 2322.981461]  [<c010799f>] common_interrupt+0x23/0x28
> [ 2322.989075]  =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D> [ 2322.995502] Code: 2=
4 16 7b 31 c0 e8 59 f4 f8 ff 8b 45 10 90 0f ba 68 3c 15 90 0f ba 2b 0b 90 0=
f ba 33 00 90 0f ba 6d 00 01 8b 45 00 f6 c4 08 75 04 <0f> 0b eb fe 8b 75 0c=
 9c 58 0f 1f 84 00 00 00 00 00 89 c7 fa 0f
> [ 2323.023538] EIP: [<c0199e6d>] end_buffer_async_write+0x6f/0xfd SS:ESP =
0068:dee9be6c
> [ 2323.033481] Kernel panic - not syncing: Fatal exception in interrupt
>
>
>
>
> [  306.079477] CCID: Unregistered CCID 3 (ccid3)
> [  306.143890] BUG: unable to handle kernel paging request at virtual add=
ress 40001864
> [  306.152506] printing eip: c01792e1 *pde =3D 00000000
> [  306.156682] Oops: 0000 [#1] SMP
> [  306.160469] Modules linked in: dccp_tfrc_lib dccp edd iptable_filter i=
p_tables ip6table_filter ip6_tables x_tables ipv6 microcode firmware_class =
fuse loop dm_mod ide_cd cdrom pata_acpi ata_piix ahci ata_generic libata fl=
oppy parport_pc rtc_cmos parport pcnet32 rtc_core mii i2c_piix4 rtc_lib i2c=
_core pcspkr piix generic ac thermal container ide_core power_supply button=
 shpchp intel_agp processor pci_hotplug agpgart mousedev evdev sg ext3 jbd =
mbcache sd_mod mptspi mptscsih mptbase scsi_transport_spi uhci_hcd ehci_hcd=
 scsi_mod usbcore
> [  306.220412]
> [  306.222927] Pid: 136, comm: pdflush Not tainted (2.6.24-rc6 #4)
> [  306.228691] EIP: 0060:[<c01792e1>] EFLAGS: 00010002 CPU: 0
> [  306.238499] EIP is at kmem_cache_alloc+0x5d/0xa6
> [  306.242756] EAX: 00000000 EBX: 00000282 ECX: c03750a0 EDX: 40001864
> [  306.248712] ESI: c1408314 EDI: 40001864 EBP: c03750a0 ESP: dead3d54
> [  306.254538]  DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0068
> [  306.258526] Process pdflush (pid: 136, ti=DEad2000 task=DF49e5e0 task.=
ti=DEad2000)
> [  306.264717] Stack: c016094d c1408314 40001864 00011200 de5fb000 df4460=
80 de65e680 00000000
> [  306.276685]        00011210 c016094d 00000010 00000000 00000003 de6bc3=
78 00000003 de6bcde0
> [  306.284594]        00000000 de65e680 00000000 00000000 c019acdf 000000=
00 df402a20 00000010
> [  306.296711] Call Trace:
> [  306.298976]  [<c016094d>] mempool_alloc+0x24/0xc2
> [  306.304602]  [<c016094d>] mempool_alloc+0x24/0xc2
> [  306.308722]  [<c019acdf>] bio_alloc_bioset+0x8c/0xe6
> [  306.314133]  [<c019ad44>] bio_alloc+0xb/0x17
> [  306.318609]  [<c0197688>] submit_bh+0x6e/0xf8
> [  306.324696]  [<c0199265>] __block_write_full_page+0x222/0x30f
> [  306.330100]  [<c019c810>] blkdev_get_block+0x0/0x43
> [  306.334949]  [<c0199420>] block_write_full_page+0xce/0xd6
> [  306.340733]  [<c019c810>] blkdev_get_block+0x0/0x43
> [  306.348460]  [<c0163588>] __writepage+0x8/0x21
> [  306.352736]  [<c0163a1e>] write_cache_pages+0x15b/0x273
> [  306.362425]  [<c0163580>] __writepage+0x0/0x21
> [  306.369968]  [<c0163b36>] generic_writepages+0x0/0x26
> [  306.375911]  [<c0163b55>] generic_writepages+0x1f/0x26
> [  306.380734]  [<c0163b7c>] do_writepages+0x20/0x30
> [  306.386999]  [<c019423b>] __writeback_single_inode+0x17c/0x2a0
> [  306.394198]  [<c012d2de>] irq_exit+0x53/0x6b
> [  306.398880]  [<c011a12a>] smp_apic_timer_interrupt+0x71/0x7d
> [  306.403016]  [<c0194650>] sync_sb_inodes+0x18a/0x240
> [  306.410354]  [<c01948a4>] writeback_inodes+0x5a/0x9c
> [  306.414853]  [<c01643d1>] wb_kupdate+0x7c/0xde
> [  306.419014]  [<c01648b8>] pdflush+0x130/0x1d0
> [  306.424730]  [<c0164355>] wb_kupdate+0x0/0xde
> [  306.430029]  [<c0164788>] pdflush+0x0/0x1d0
> [  306.435018]  [<c01398bc>] kthread+0x38/0x60
> [  306.439003]  [<c0139884>] kthread+0x0/0x60
> [  306.442884]  [<c0107beb>] kernel_thread_helper+0x7/0x10
> [  306.448467]  =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D> [  306.451998] Code: 3=
e 85 ff 89 7c 24 08 75 1b 89 14 24 8b 54 24 0c 83 c9 ff 89 e8 89 74 24 04 e=
8 2b fb ff ff 89 44 24 08 eb 0c 8b 54 24 08 8b 46 0c <8b> 04 82 89 06 89 d8=
 50 9d 0f 1f 84 00 00 00 00 00 66 83 7c 24
> [  306.478944] EIP: [<c01792e1>] kmem_cache_alloc+0x5d/0xa6 SS:ESP 0068:d=
ead3d54
> [  306.486157] ---[ end trace 0170fd34e372695a ]---
> [  306.511450] sd 0:0:0:0: [sda] Result: hostbyte=3DDID_OK driverbyte=3DD=
RIVER_SENSE,SUGGEST_OK
> [  306.532261] sd 0:0:0:0: [sda] Sense Key : Hardware Error [current]
> [  306.551315] sd 0:0:0:0: [sda] Add. Sense: Data phase error
> [  306.563451] end_request: I/O error, dev sda, sector 4437024
> [  306.575308] Buffer I/O error on device sda2, logical block 426108
> [  306.587177] lost page write due to I/O error on sda2
> [  306.596911] Buffer I/O error on device sda2, logical block 426109
> [  306.608804] lost page write due to I/O error on sda2
> [  306.617992] Buffer I/O error on device sda2, logical block 426110
> [  306.628005] lost page write due to I/O error on sda2
> [  306.636004] Buffer I/O error on device sda2, logical block 426111
> [  306.644813] lost page write due to I/O error on sda2
> [  306.652236] Buffer I/O error on device sda2, logical block 426112
> [  306.662203] lost page write due to I/O error on sda2
> [  306.671197] Buffer I/O error on device sda2, logical block 426113
> [  306.679141] lost page write due to I/O error on sda2
> [  306.699255] BUG: unable to handle kernel paging request at virtual add=
ress 100d4a84
> [  306.715348] printing eip: c0139945 *pde =3D 00000000
> [  306.724664] Oops: 0000 [#2] SMP
> [  306.730582] Modules linked in: dccp_tfrc_lib dccp edd iptable_filter i=
p_tables ip6table_filter ip6_tables x_tables ipv6 microcode firmware_class =
fuse loop dm_mod ide_cd cdrom pata_acpi ata_piix ahci ata_generic libata fl=
oppy parport_pc rtc_cmos parport pcnet32 rtc_core mii i2c_piix4 rtc_lib i2c=
_core pcspkr piix generic ac thermal container ide_core power_supply button=
 shpchp intel_agp processor pci_hotplug agpgart mousedev evdev sg ext3 jbd =
mbcache sd_mod mptspi mptscsih mptbase scsi_transport_spi uhci_hcd ehci_hcd=
 scsi_mod usbcore
> [  306.788046]
> [  306.788569] Pid: 136, comm: pdflush Tainted: G      D (2.6.24-rc6 #4)
> [  306.800851] EIP: 0060:[<c0139945>] EFLAGS: 00010296 CPU: 0
> [  306.806474] EIP is at __wake_up_bit+0x9/0x33
> [  306.814710] EAX: 100d4a84 EBX: 100d4a80 ECX: 0000000c EDX: c13670e0
> [  306.818605] ESI: df39a8f8 EDI: 00000202 EBP: c13670e0 ESP: dead3acc
> [  306.835065]  DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0068
> [  306.837951] Process pdflush (pid: 136, ti=DEad2000 task=DF49e5e0 task.=
ti=DEad2000)
> [  306.844247] Stack: 00000202 c13670e0 c015e5c5 df39a8f8 c0199ee0 c0317b=
16 dead3ae8 32616473
> [  306.855168]        00000200 c0160924 00000000 df446000 de65ef80 df4e00=
c0 00004000 de65e200
> [  306.864865]        de65e200 df4e00c0 00003000 c01994fd c01994dc c019a9=
9d 00001000 c01d919a
> [  306.874768] Call Trace:
> [  306.876862]  [<c015e5c5>] end_page_writeback+0x2f/0x3c
> [  306.883188]  [<c0199ee0>] end_buffer_async_write+0xe2/0xfd
> [  306.892703]  [<c0160924>] mempool_free+0x6a/0x6f
> [  306.896859]  [<c01994fd>] end_bio_bh_io_sync+0x21/0x29
> [  306.903132]  [<c01994dc>] end_bio_bh_io_sync+0x0/0x29
> [  306.908307]  [<c019a99d>] bio_endio+0x27/0x29
> [  306.912352]  [<c01d919a>] __end_that_request_first+0x192/0x33d
> [  306.919035]  [<e0816a93>] scsi_end_request+0x1a/0xa8 [scsi_mod]
> [  306.926526]  [<e08177c2>] scsi_io_completion+0x2f3/0x2fb [scsi_mod]
> [  306.932877]  [<c01db7e1>] blk_done_softirq+0x5b/0x67
> [  306.938996]  [<c012cfae>] __do_softirq+0x75/0xe1
> [  306.944407]  [<c012d05f>] do_softirq+0x45/0x53
> [  306.948536]  [<c012d2c3>] irq_exit+0x38/0x6b
> [  306.952574]  [<c011a12a>] smp_apic_timer_interrupt+0x71/0x7d
> [  306.958088]  [<c0107a5c>] apic_timer_interrupt+0x28/0x30
> [  306.963199]  [<c014ce77>] acct_collect+0x152/0x15b
> [  306.968109]  [<c012b710>] do_exit+0x1b9/0x68c
> [  306.972841]  [<c01292c0>] printk+0x1b/0x1f
> [  306.976869]  [<c0108417>] die+0x21d/0x224
> [  306.980899]  [<c0120397>] do_page_fault+0x4b6/0x593
> [  306.986648]  [<c01d9793>] generic_make_request+0x3be/0x3ec
> [  306.991209]  [<c01d9793>] generic_make_request+0x3be/0x3ec
> [  306.996429]  [<c011fee1>] do_page_fault+0x0/0x593
> [  307.000875]  [<c02c2c3a>] error_code+0x72/0x78
> [  307.004889]  [<c01792e1>] kmem_cache_alloc+0x5d/0xa6
> [  307.008678]  [<c016094d>] mempool_alloc+0x24/0xc2
> [  307.011091]  [<c016094d>] mempool_alloc+0x24/0xc2
> [  307.026957]  [<c019acdf>] bio_alloc_bioset+0x8c/0xe6
> [  307.032287]  [<c019ad44>] bio_alloc+0xb/0x17
> [  307.035254]  [<c0197688>] submit_bh+0x6e/0xf8
> [  307.040911]  [<c0199265>] __block_write_full_page+0x222/0x30f
> [  307.048908]  [<c019c810>] blkdev_get_block+0x0/0x43
> [  307.055251]  [<c0199420>] block_write_full_page+0xce/0xd6
> [  307.062257]  [<c019c810>] blkdev_get_block+0x0/0x43
> [  307.067258]  [<c0163588>] __writepage+0x8/0x21
> [  307.072534]  [<c0163a1e>] write_cache_pages+0x15b/0x273
> [  307.076626]  [<c0163580>] __writepage+0x0/0x21
> [  307.078707]  [<c0163b36>] generic_writepages+0x0/0x26
> [  307.084487]  [<c0163b55>] generic_writepages+0x1f/0x26
> [  307.091273]  [<c0163b7c>] do_writepages+0x20/0x30
> [  307.096249]  [<c019423b>] __writeback_single_inode+0x17c/0x2a0
> [  307.102496]  [<c012d2de>] irq_exit+0x53/0x6b
> [  307.107266]  [<c011a12a>] smp_apic_timer_interrupt+0x71/0x7d
> [  307.112929]  [<c0194650>] sync_sb_inodes+0x18a/0x240
> [  307.119285]  [<c01948a4>] writeback_inodes+0x5a/0x9c
> [  307.124927]  [<c01643d1>] wb_kupdate+0x7c/0xde
> [  307.132149]  [<c01648b8>] pdflush+0x130/0x1d0
> [  307.136540]  [<c0164355>] wb_kupdate+0x0/0xde
> [  307.140336]  [<c0164788>] pdflush+0x0/0x1d0
> [  307.144942]  [<c01398bc>] kthread+0x38/0x60
> [  307.150390]  [<c0139884>] kthread+0x0/0x60
> [  307.155285]  [<c0107beb>] kernel_thread_helper+0x7/0x10
> [  307.162728]  =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D> [  307.164944] Code: c=
1 eb 1e 69 db 80 07 00 00 81 c3 80 49 35 c0 2b 8b 08 07 00 00 d3 e8 6b c0 0=
c 03 83 00 07 00 00 5b c3 53 89 c3 83 ec 0c 8d 40 04 <39> 43 04 89 54 24 04=
 89 4c 24 08 74 18 8d 44 24 04 b9 01 00 00
> [  307.188954] EIP: [<c0139945>] __wake_up_bit+0x9/0x33 SS:ESP 0068:dead3=
acc
> [  307.199560] Kernel panic - not syncing: Fatal exception in interrupt



_______________________________________________________________________
Jetzt neu! Sch=FCtzen Sie Ihren PC mit McAfee und WEB.DE. 30 Tage
kostenlos testen. http://www.pc-sicherheit.web.de/startseite/?mc=022220

