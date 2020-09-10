From: Ilya Dryomov <idryomov@gmail.com>
Date: Thu, 10 Sep 2020 09:24:26 +0000
Subject: Re: [trivial PATCH] treewide: Convert switch/case fallthrough; to break;
Message-Id: <CAOi1vP-v77pj3G5Ez94CDYVs2jSO828c4uV_wzNi6sRKp=Yvyg@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <e6387578c75736d61b2fe70d9783d91329a97eb4.camel@perches.com>
In-Reply-To: <e6387578c75736d61b2fe70d9783d91329a97eb4.camel@perches.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Wed, Sep 9, 2020 at 10:10 PM Joe Perches <joe@perches.com> wrote:
>
> fallthrough to a separate case/default label break; isn't very readable.
>
> Convert pseudo-keyword fallthrough; statements to a simple break; when
> the next label is case or default and the only statement in the next
> label block is break;
>
> Found using:
>
> $ grep-2.5.4 -rP --include=*.[ch] -n "fallthrough;(\s*(case\s+\w+|default)\s*:\s*){1,7}break;" *
>
> Miscellanea:
>
> o Move or coalesce a couple label blocks above a default: block.
>
> Signed-off-by: Joe Perches <joe@perches.com>
> ---
>
> Compiled allyesconfig x86-64 only.
> A few files for other arches were not compiled.
>
>  arch/arm/mach-mmp/pm-pxa910.c                             |  2 +-
>  arch/arm64/kvm/handle_exit.c                              |  2 +-
>  arch/mips/kernel/cpu-probe.c                              |  2 +-
>  arch/mips/math-emu/cp1emu.c                               |  2 +-
>  arch/s390/pci/pci.c                                       |  2 +-
>  crypto/tcrypt.c                                           |  4 ++--
>  drivers/ata/sata_mv.c                                     |  2 +-
>  drivers/atm/lanai.c                                       |  2 +-
>  drivers/gpu/drm/i915/display/intel_sprite.c               |  2 +-
>  drivers/gpu/drm/nouveau/nvkm/engine/disp/hdmi.c           |  2 +-
>  drivers/hid/wacom_wac.c                                   |  2 +-
>  drivers/i2c/busses/i2c-i801.c                             |  2 +-
>  drivers/infiniband/ulp/rtrs/rtrs-clt.c                    | 14 +++++++-------
>  drivers/infiniband/ulp/rtrs/rtrs-srv.c                    |  6 +++---
>  drivers/iommu/arm/arm-smmu-v3/arm-smmu-v3.c               |  2 +-
>  drivers/irqchip/irq-vic.c                                 |  4 ++--
>  drivers/md/dm.c                                           |  2 +-
>  drivers/media/dvb-frontends/drxd_hard.c                   |  2 +-
>  drivers/media/i2c/ov5640.c                                |  2 +-
>  drivers/media/i2c/ov6650.c                                |  5 ++---
>  drivers/media/i2c/smiapp/smiapp-core.c                    |  2 +-
>  drivers/media/i2c/tvp5150.c                               |  2 +-
>  drivers/media/pci/ddbridge/ddbridge-core.c                |  2 +-
>  drivers/media/usb/cpia2/cpia2_core.c                      |  2 +-
>  drivers/mfd/iqs62x.c                                      |  3 +--
>  drivers/mmc/host/atmel-mci.c                              |  2 +-
>  drivers/mtd/nand/raw/nandsim.c                            |  2 +-
>  drivers/net/ethernet/intel/e1000e/phy.c                   |  2 +-
>  drivers/net/ethernet/intel/fm10k/fm10k_pf.c               |  2 +-
>  drivers/net/ethernet/intel/i40e/i40e_adminq.c             |  2 +-
>  drivers/net/ethernet/intel/i40e/i40e_txrx.c               |  2 +-
>  drivers/net/ethernet/intel/iavf/iavf_txrx.c               |  2 +-
>  drivers/net/ethernet/intel/igb/e1000_phy.c                |  2 +-
>  drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c            |  2 +-
>  drivers/net/ethernet/intel/ixgbe/ixgbe_main.c             |  2 +-
>  drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c            |  2 +-
>  drivers/net/ethernet/intel/ixgbevf/vf.c                   |  2 +-
>  drivers/net/ethernet/netronome/nfp/nfpcore/nfp6000_pcie.c |  2 +-
>  drivers/net/ethernet/qlogic/qed/qed_mcp.c                 |  2 +-
>  drivers/net/ethernet/sfc/falcon/farch.c                   |  2 +-
>  drivers/net/ethernet/sfc/farch.c                          |  2 +-
>  drivers/net/phy/adin.c                                    |  3 +--
>  drivers/net/usb/pegasus.c                                 |  4 ++--
>  drivers/net/usb/usbnet.c                                  |  2 +-
>  drivers/net/wireless/ath/ath5k/eeprom.c                   |  2 +-
>  drivers/net/wireless/mediatek/mt7601u/dma.c               |  8 ++++----
>  drivers/nvme/host/core.c                                  | 12 ++++++------
>  drivers/pcmcia/db1xxx_ss.c                                |  4 ++--
>  drivers/power/supply/abx500_chargalg.c                    |  2 +-
>  drivers/power/supply/charger-manager.c                    |  2 +-
>  drivers/rtc/rtc-pcf85063.c                                |  2 +-
>  drivers/s390/scsi/zfcp_fsf.c                              |  2 +-
>  drivers/scsi/aic7xxx/aic79xx_core.c                       |  4 ++--
>  drivers/scsi/aic94xx/aic94xx_tmf.c                        |  2 +-
>  drivers/scsi/lpfc/lpfc_sli.c                              |  2 +-
>  drivers/scsi/smartpqi/smartpqi_init.c                     |  2 +-
>  drivers/scsi/sr.c                                         |  2 +-
>  drivers/tty/serial/sunsu.c                                |  2 +-
>  drivers/tty/serial/sunzilog.c                             |  2 +-
>  drivers/tty/vt/vt_ioctl.c                                 |  2 +-
>  drivers/usb/dwc3/core.c                                   |  2 +-
>  drivers/usb/gadget/legacy/inode.c                         |  2 +-
>  drivers/usb/gadget/udc/pxa25x_udc.c                       |  4 ++--
>  drivers/usb/host/ohci-hcd.c                               |  2 +-
>  drivers/usb/isp1760/isp1760-hcd.c                         |  2 +-
>  drivers/usb/musb/cppi_dma.c                               |  2 +-
>  drivers/usb/phy/phy-fsl-usb.c                             |  2 +-
>  drivers/video/fbdev/stifb.c                               |  2 +-
>  fs/afs/yfsclient.c                                        |  8 ++++----
>  fs/ceph/dir.c                                             |  2 +-

For ceph:

Acked-by: Ilya Dryomov <idryomov@gmail.com>

Thanks,

                Ilya
