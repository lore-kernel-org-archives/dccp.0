From: kernel test robot <lkp@intel.com>
Date: Thu, 01 Jun 2023 03:27:43 +0000
Subject: Re: [PATCH net-next v4] net: ioctl: Use kernel memory on protocol ioctl callbacks
Message-Id: <202306011128.2sM3vsBl-lkp@intel.com>
List-Id: <dccp.vger.kernel.org>
References: <20230530175403.2434218-1-leitao@debian.org>
In-Reply-To: <20230530175403.2434218-1-leitao@debian.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hi Breno,

kernel test robot noticed the following build errors:

[auto build test ERROR on net-next/main]

url:    https://github.com/intel-lab-lkp/linux/commits/Breno-Leitao/net-ioctl-Use-kernel-memory-on-protocol-ioctl-callbacks/20230531-015554
base:   net-next/main
patch link:    https://lore.kernel.org/r/20230530175403.2434218-1-leitao%40debian.org
patch subject: [PATCH net-next v4] net: ioctl: Use kernel memory on protocol ioctl callbacks
config: mips-allmodconfig (https://download.01.org/0day-ci/archive/20230601/202306011128.2sM3vsBl-lkp@intel.com/config)
compiler: mips-linux-gcc (GCC) 12.3.0
reproduce (this is a W=1 build):
        mkdir -p ~/bin
        wget https://raw.githubusercontent.com/intel/lkp-tests/master/sbin/make.cross -O ~/bin/make.cross
        chmod +x ~/bin/make.cross
        # https://github.com/intel-lab-lkp/linux/commit/f97a3206f5ae59ecb0c7105225c5230b343c6c54
        git remote add linux-review https://github.com/intel-lab-lkp/linux
        git fetch --no-tags linux-review Breno-Leitao/net-ioctl-Use-kernel-memory-on-protocol-ioctl-callbacks/20230531-015554
        git checkout f97a3206f5ae59ecb0c7105225c5230b343c6c54
        # save the config file
        mkdir build_dir && cp config build_dir/.config
        COMPILER_INSTALL_PATH=$HOME/0day COMPILER=gcc-12.3.0 ~/bin/make.cross W=1 O=build_dir ARCH=mips olddefconfig
        COMPILER_INSTALL_PATH=$HOME/0day COMPILER=gcc-12.3.0 ~/bin/make.cross W=1 O=build_dir ARCH=mips SHELL=/bin/bash

If you fix the issue, kindly add following tag where applicable
| Reported-by: kernel test robot <lkp@intel.com>
| Closes: https://lore.kernel.org/oe-kbuild-all/202306011128.2sM3vsBl-lkp@intel.com/

All errors (new ones prefixed by >>):

   mips-linux-ld: net/core/sock.o: in function `sk_ioctl':
>> sock.c:(.text.sk_ioctl+0x12c): undefined reference to `ip6mr_sk_ioctl'

-- 
0-DAY CI Kernel Test Service
https://github.com/intel/lkp-tests/wiki
