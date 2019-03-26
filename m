From: Greg KH <greg@kroah.com>
Date: Tue, 26 Mar 2019 02:18:54 +0000
Subject: Re: [BACKPORT 4.4.y 00/25] candidates from spreadtrum 4.4 product kernel
Message-Id: <20190326021854.GA19395@kroah.com>
List-Id: <dccp.vger.kernel.org>
References: <20190322154425.3852517-1-arnd@arndb.de>
In-Reply-To: <20190322154425.3852517-1-arnd@arndb.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Fri, Mar 22, 2019 at 04:43:51PM +0100, Arnd Bergmann wrote:
> I took a scripted approach to look at some product kernels for patches
> backported into vendor kernels. This is a set of (mostly) bugfixes I found
> in Spreadtrum's linux-4.4 kernel that are missing in 4.4.176:
> 
> ffedbd2210f2 mmc: pwrseq: constify mmc_pwrseq_ops structures
> c10368897e10 ALSA: compress: add support for 32bit calls in a 64bit kernel
> 64a67d4762ce mmc: pwrseq_simple: Make reset-gpios optional to match doc
> 4ec0ef3a8212 USB: iowarrior: fix oops with malicious USB descriptors
> e5905ff1281f mmc: debugfs: Add a restriction to mmc debugfs clock setting
> 4ec96b4cbde8 mmc: make MAN_BKOPS_EN message a debug
> ed9feec72fc1 mmc: sanitize 'bus width' in debug output
> 10a16a01d8f7 mmc: core: shut up "voltage-ranges unspecified" pr_info()
> 9772b47a4c29 usb: dwc3: gadget: Fix suspend/resume during device mode
> 6afedcd23cfd arm64: mm: Add trace_irqflags annotations to do_debug_exception()
> 437db4c6e798 mmc: mmc: Attempt to flush cache before reset
> e51534c80660 mmc: core: fix using wrong io voltage if mmc_select_hs200 fails
> e4c5800a3991 mm/rmap: replace BUG_ON(anon_vma->degree) with VM_WARN_ON
> 04c080080855 extcon: usb-gpio: Don't miss event during suspend/resume
> 78283edf2c01 kbuild: setlocalversion: print error to STDERR
> c526c62d565e usb: gadget: composite: fix dereference after null check coverify warning
> 511a36d2f357 usb: gadget: Add the gserial port checking in gs_start_tx()
> 1712c9373f98 mmc: core: don't try to switch block size for dual rate mode
> 5ea8ea2cb7f1 tcp/dccp: drop SYN packets if accept queue is full
> e1dc9b08051a serial: sprd: adjust TIMEOUT to a big value
> 81be24d263db Hang/soft lockup in d_invalidate with simultaneous calls
> 6f44a0bacb79 arm64: traps: disable irq in die()
> b7d44c36a6f6 usb: renesas_usbhs: gadget: fix unused-but-set-variable warning
> 4350782570b9 serial: sprd: clear timeout interrupt only rather than all interrupts
> 3f3295709ede lib/int_sqrt: optimize small argument
> 32fd87b3bbf5 USB: core: only clean up what we allocated

All now queued up, except for the exceptions I have responded to.

thanks,

greg k-h
