From: Joanne Koong <joannelkoong@gmail.com>
Date: Wed, 27 Jul 2022 23:41:04 +0000
Subject: Re: [net] 03d56978dd: BUG:Bad_page_map_in_process
Message-Id: <CAJnrk1aX6x79AzFPVk1QwU4ivd5AeYwz6Fe2z6HLunBSBA20yg@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: dccp@vger.kernel.org

On Sun, Jul 24, 2022 at 7:05 AM kernel test robot <oliver.sang@intel.com> wrote:
>
>
>
> Greeting,
>
> FYI, we noticed the following commit (built with gcc-11):
>
> commit: 03d56978dd246147e151916e4dc72af7bc24d5c9 ("[PATCH net-next v3 1/3] net: Add a bhash2 table hashed by port + address")
> url: https://github.com/intel-lab-lkp/linux/commits/Joanne-Koong/Add-a-second-bind-table-hashed-by-port-address/20220723-035903
> base: https://git.kernel.org/cgit/linux/kernel/git/davem/net-next.git 949d6b405e6160ae44baea39192d67b39cb7eeac
> patch link: https://lore.kernel.org/netdev/20220722195406.1304948-2-joannelkoong@gmail.com
>
> in testcase: boot
>
> on test machine: qemu-system-x86_64 -enable-kvm -cpu SandyBridge -smp 2 -m 16G
>
> caused below changes (please refer to attached dmesg/kmsg for entire log/backtrace):
>
>
>
> If you fix the issue, kindly add following tag
> Reported-by: kernel test robot <oliver.sang@intel.com>
>
>
> [  103.871133][  T486] BUG: Bad page map in process rsync  pte:ffff92f93b759508 pmd:13fc1e067
> [  103.873143][  T486] addr:00007f9fe52a2000 vm_flags:00000075 anon_vma:0000000000000000 mapping:ffff92f928adcb58 index:1a1
> [  103.875128][  T486] file:libcrypto.so.1.1 fault:filemap_fault mmap:generic_file_mmap read_folio:simple_read_folio
> [  103.877339][  T486] CPU: 0 PID: 486 Comm: rsync Not tainted 5.19.0-rc7-01443-g03d56978dd24 #1
> [  103.879032][  T486] Call Trace:
> [  103.879742][  T486]  <TASK>
> [  103.880329][  T486]  ? simple_write_end+0x140/0x140
> [  103.881338][  T486]  dump_stack_lvl+0x3b/0x53
> [  103.882274][  T486]  ? __filemap_get_folio+0x780/0x780
> [  103.883270][  T486]  print_bad_pte.cold+0x15b/0x1c5
> [  103.884202][  T486]  vm_normal_page+0x65/0x140
> [  103.885062][  T486]  zap_pte_range+0x23b/0x9c0
> [  103.885897][  T486]  unmap_page_range+0x263/0x5c0
> [  103.886846][  T486]  unmap_vmas+0x121/0x200
> [  103.887628][  T486]  exit_mmap+0xb5/0x240
> [  103.888401][  T486]  mmput+0x3b/0x140
> [  103.889134][  T486]  exit_mm+0xff/0x180
> [  103.889877][  T486]  do_exit+0x100/0x400
> [  103.890661][  T486]  do_group_exit+0x3e/0x100
> [  103.891514][  T486]  __x64_sys_exit_group+0x18/0x40
> [  103.892494][  T486]  do_syscall_64+0x5d/0x80
> [  103.893294][  T486]  ? do_user_addr_fault+0x257/0x6c0
> [  103.894238][  T486]  ? lock_release+0x6e/0x100
> [  103.895171][  T486]  ? up_read+0x12/0x40
> [  103.896036][  T486]  ? exc_page_fault+0xb2/0x2c0
> [  103.897021][  T486]  entry_SYSCALL_64_after_hwframe+0x5d/0xc7
> [  103.898243][  T486] RIP: 0033:0x7f9fe5007699
> [  103.899149][  T486] Code: Unable to access opcode bytes at RIP 0x7f9fe500766f.
> [  103.900511][  T486] RSP: 002b:00007fff7e32c3a8 EFLAGS: 00000246 ORIG_RAX: 00000000000000e7
> [  103.902027][  T486] RAX: ffffffffffffffda RBX: 00007f9fe50fc610 RCX: 00007f9fe5007699
> [  103.903477][  T486] RDX: 000000000000003c RSI: 00000000000000e7 RDI: 0000000000000000
> [  103.904943][  T486] RBP: 0000000000000000 R08: ffffffffffffff80 R09: 0000000000000001
> [  103.906384][  T486] R10: 000000000000000b R11: 0000000000000246 R12: 00007f9fe50fc610
> [  103.907823][  T486] R13: 0000000000000001 R14: 00007f9fe50fcae8 R15: 0000000000000000
> [  103.909290][  T486]  </TASK>
> [  103.910423][  T486] Disabling lock debugging due to kernel taint
> [  107.503093][  T508] BUG: Bad page map in process rsync  pte:ffff92f93b7fe508 pmd:13aa1c067
> [  107.504948][  T508] addr:00007fced9aa2000 vm_flags:00000075 anon_vma:0000000000000000 mapping:ffff92f92891ab58 index:9a
> [  107.507070][  T508] file:libzstd.so.1.4.8 fault:filemap_fault mmap:generic_file_mmap read_folio:simple_read_folio
> [  107.508825][  T508] CPU: 0 PID: 508 Comm: rsync Tainted: G    B             5.19.0-rc7-01443-g03d56978dd24 #1
> [  107.510762][  T508] Call Trace:
> [  107.511458][  T508]  <TASK>
> [  107.512058][  T508]  ? simple_write_end+0x140/0x140
> [  107.513072][  T508]  dump_stack_lvl+0x3b/0x53
> [  107.513990][  T508]  ? __filemap_get_folio+0x780/0x780
> [  107.519166][  T508]  print_bad_pte.cold+0x15b/0x1c5
> [  107.520032][  T508]  vm_normal_page+0x65/0x140
> [  107.520802][  T508]  zap_pte_range+0x23b/0x9c0
> [  107.521548][  T508]  unmap_page_range+0x263/0x5c0
> [  107.522355][  T508]  unmap_vmas+0x121/0x200
> [  107.523247][  T508]  exit_mmap+0xb5/0x240
> [  107.524107][  T508]  mmput+0x3b/0x140
> [  107.524908][  T508]  exit_mm+0xff/0x180
> [  107.525716][  T508]  do_exit+0x100/0x400
> [  107.526613][  T508]  do_group_exit+0x3e/0x100
> [  107.527541][  T508]  __x64_sys_exit_group+0x18/0x40
> [  107.528450][  T508]  do_syscall_64+0x5d/0x80
> [  107.529368][  T508]  ? up_read+0x12/0x40
> [  107.530228][  T508]  ? do_user_addr_fault+0x257/0x6c0
> [  107.531121][  T508]  ? rcu_read_lock_sched_held+0x5/0x40
> [  107.532046][  T508]  ? exc_page_fault+0xb2/0x2c0
> [  107.532843][  T508]  entry_SYSCALL_64_after_hwframe+0x5d/0xc7
> [  107.533866][  T508] RIP: 0033:0x7fced95ff699
> [  107.534781][  T508] Code: Unable to access opcode bytes at RIP 0x7fced95ff66f.
> [  107.536225][  T508] RSP: 002b:00007fff162474c8 EFLAGS: 00000246 ORIG_RAX: 00000000000000e7
> [  107.537871][  T508] RAX: ffffffffffffffda RBX: 00007fced96f4610 RCX: 00007fced95ff699
> [  107.539506][  T508] RDX: 000000000000003c RSI: 00000000000000e7 RDI: 0000000000000000
> [  107.541126][  T508] RBP: 0000000000000000 R08: ffffffffffffff80 R09: 0000000000000001
> [  107.542743][  T508] R10: 000000000000000b R11: 0000000000000246 R12: 00007fced96f4610
> [  107.544310][  T508] R13: 0000000000000001 R14: 00007fced96f4ae8 R15: 0000000000000000
> [  107.545881][  T508]  </TASK>
>
>
>
> To reproduce:
>
>         # build kernel
>         cd linux
>         cp config-5.19.0-rc7-01443-g03d56978dd24 .config
>         make HOSTCC=gcc-11 CC=gcc-11 ARCH=x86_64 olddefconfig prepare modules_prepare bzImage modules
>         make HOSTCC=gcc-11 CC=gcc-11 ARCH=x86_64 INSTALL_MOD_PATH=<mod-install-dir> modules_install
>         cd <mod-install-dir>
>         find lib/ | cpio -o -H newc --quiet | gzip > modules.cgz
>
>
>         git clone https://github.com/intel/lkp-tests.git
>         cd lkp-tests
>         bin/lkp qemu -k <bzImage> -m modules.cgz job-script # job-script is attached in this email
>
>         # if come across any failure that blocks the test,
>         # please remove ~/.lkp and /lkp dir to run from a clean state.
>
I ran this in a loop ~20 times but I'm not able to repro the crash.
This is a snippet of what I see (and I can also attach or paste the
entire log if that would be helpful):

[  OK  ] Created slice system-getty.slice.
[  OK  ] Created slice system-modprobe.slice.
[  OK  ] Created slice User and Session Slice.
[  OK  ] Started Dispatch Password …ts to Console Directory Watch.
[  OK  ] Started Forward Password R…uests to Wall Directory Watch.
[UNSUPP] Starting of Arbitrary Exec…Automount Point not supported.
[  OK  ] Reached target Local Encrypted Volumes.
[  OK  ] Reached target Paths.
[  OK  ] Reached target Slices.
[  OK  ] Reached target Swap.
[  OK  ] Listening on RPCbind Server Activation Socket.
[  OK  ] Listening on Syslog Socket.
[  OK  ] Listening on initctl Compatibility Named Pipe.
[  OK  ] Listening on Journal Socket (/dev/log).
[  OK  ] Listening on Journal Socket.
[  OK  ] Listening on udev Control Socket.
[  OK  ] Listening on udev Kernel Socket.
         Mounting RPC Pipe File System...
         Mounting Kernel Debug File System...
         Mounting Kernel Trace File System...
         Starting Load Kernel Module configfs...
         Starting Load Kernel Module drm...
         Starting Load Kernel Module fuse...
         Starting Journal Service...
         Starting Load Kernel Modules...
         Starting Remount Root and Kernel File Systems...
         Starting Coldplug All udev Devices...
[FAILED] Failed to mount RPC Pipe File System.
See 'systemctl status run-rpc_pipefs.mount' for details.
[DEPEND] Dependency failed for RPC …curity service for NFS server.
[DEPEND] Dependency failed for RPC …ice for NFS client and server.
[  OK  ] Mounted Kernel Debug File System.
[  OK  ] Mounted Kernel Trace File System.
[  OK  ] Finished Load Kernel Module configfs.
[  OK  ] Finished Load Kernel Module drm.
[  OK  ] Finished Load Kernel Module fuse.
[  OK  ] Finished Load Kernel Modules.
[  OK  ] Finished Remount Root and Kernel File Systems.
[  OK  ] Reached target NFS client services.
         Mounting Kernel Configuration File System...
         Starting Load/Save Random Seed...
         Starting Apply Kernel Variables...
         Starting Create System Users...
[  OK  ] Mounted Kernel Configuration File System.
[  OK  ] Finished Load/Save Random Seed.
[FAILED] Failed to start Apply Kernel Variables.
See 'systemctl status systemd-sysctl.service' for details.
[  OK  ] Finished Create System Users.
         Starting Create Static Device Nodes in /dev...
[  OK  ] Finished Create Static Device Nodes in /dev.
[  OK  ] Reached target Local File Systems (Pre).
[  OK  ] Reached target Local File Systems.
         Starting Preprocess NFS configuration...
         Starting Rule-based Manage…for Device Events and Files...
[  OK  ] Finished Preprocess NFS configuration.
[  OK  ] Started Journal Service.
         Starting Flush Journal to Persistent Storage...
[  OK  ] Started Rule-based Manager for Device Events and Files.
[  OK  ] Finished Flush Journal to Persistent Storage.
         Starting Create Volatile Files and Directories...
[  OK  ] Finished Create Volatile Files and Directories.
         Starting RPC bind portmap service...
         Starting Update UTMP about System Boot/Shutdown...
[  OK  ] Started RPC bind portmap service.
[  OK  ] Reached target Remote File Systems (Pre).
[  OK  ] Reached target Remote File Systems.
[  OK  ] Reached target RPC Port Mapper.
[FAILED] Failed to start Update UTMP about System Boot/Shutdown.
See 'systemctl status systemd-update-utmp.service' for details.
[DEPEND] Dependency failed for Upda…about System Runlevel Changes.
[  OK  ] Finished Coldplug All udev Devices.
[  OK  ] Reached target System Initialization.
[  OK  ] Started Daily apt download activities.
[  OK  ] Started Daily apt upgrade and clean activities.
[  OK  ] Started Periodic ext4 Onli…ata Check for All Filesystems.
[  OK  ] Started Discard unused blocks once a week.
[  OK  ] Started Daily rotation of log files.
[  OK  ] Started Daily Cleanup of Temporary Directories.
[  OK  ] Reached target Timers.
[  OK  ] Listening on D-Bus System Message Bus Socket.
[  OK  ] Reached target Sockets.
[  OK  ] Reached target Basic System.
[  OK  ] Started Regular background program processing daemon.
[  OK  ] Started D-Bus System Message Bus.
         Starting Remove Stale Onli…t4 Metadata Check Snapshots...
         Starting Helper to synchronize boot up for ifupdown...
         Starting LSB: Execute the …-e command to reboot system...
         Starting LSB: OpenIPMI Driver init script...
         Starting System Logging Service...
         Starting User Login Management...
[  OK  ] Finished Remove Stale Onli…ext4 Metadata Check Snapshots.
[  OK  ] Started System Logging Service.
[  OK  ] Finished Helper to synchronize boot up for ifupdown.
[   15.478773][  T244] systemctl (244) used greatest stack depth:
12824 bytes left
[  OK  ] Started LSB: Execute the k…c -e command to reboot system.
         Starting LSB: Load kernel image with kexec...
         Starting Raise network interfaces...
[FAILED] Failed to start LSB: OpenIPMI Driver init script.
See 'systemctl status openipmi.service' for details.
[  OK  ] Started LSB: Load kernel image with kexec.
[  OK  ] Started User Login Management.
[  OK  ] Finished Raise network interfaces.
[  OK  ] Reached target Network.
         Starting LKP bootstrap...
         Starting /etc/rc.local Compatibility...
         Starting OpenBSD Secure Shell server...
[   15.720065] rc.local[294]: mkdir: cannot create directory
‘/var/lock/lkp-bootstrap.lock’: File exists
         Starting Permit User Sessions...
[  OK  ] Started LKP bootstrap.
[  OK  ] Finished Permit User Sessions.
[  OK  ] Started OpenBSD Secure Shell server.
LKP: ttyS0: 298: Kernel tests: Boot OK!
LKP: ttyS0: 298: HOSTNAME vm-snb, MAC 52:54:00:12:34:56, kernel
5.19.0-rc7-01445-ga151972cddb3 901
LKP: ttyS0: 298:  /lkp/lkp/src/bin/run-lkp
/lkp/jobs/scheduled/vm-meta-162/boot-1-debian-11.1-x86_64-20220510.cgz-03d56978dd246147e151916e4dc72af7bc24d5c9-20220724-47452-y7oq44-5.yaml
LKP: ttyS0: 298: LKP: rebooting forcely
[   24.038119][  T298] sysrq: Emergency Sync
[   24.038784][   T25] Emergency Sync complete
[   24.039170][  T298] sysrq: Resetting

I examined more closely the changes between v2 and v3 and I don't see
anything that would lead to this error either (I'm assuming  v2 is
okay because this report wasn't generated for it). Looking at the
stack trace too, I'm not seeing anything that sticks out (eg this
looks like a memory mapping failure and bhash2 didn't modify mapping
or paging code).

I don't think this bug report is related to the bhash2 changes. But
please let me know if you disagree.

Thanks,
Joanne

>
>
> --
> 0-DAY CI Kernel Test Service
> https://01.org/lkp
>
>
