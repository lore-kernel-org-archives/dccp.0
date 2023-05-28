From: kernel test robot <lkp@intel.com>
Date: Sun, 28 May 2023 18:05:23 +0000
Subject: Re: [PATCH net-next v3] net: ioctl: Use kernel memory on protocol ioctl callbacks
Message-Id: <202305290107.hs8sbfYc-lkp@intel.com>
List-Id: <dccp.vger.kernel.org>
References: <20230525125503.400797-1-leitao@debian.org>
In-Reply-To: <20230525125503.400797-1-leitao@debian.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hi Breno,

kernel test robot noticed the following build errors:

[auto build test ERROR on net-next/main]

url:    https://github.com/intel-lab-lkp/linux/commits/Breno-Leitao/net-ioctl-Use-kernel-memory-on-protocol-ioctl-callbacks/20230525-205741
base:   net-next/main
patch link:    https://lore.kernel.org/r/20230525125503.400797-1-leitao%40debian.org
patch subject: [PATCH net-next v3] net: ioctl: Use kernel memory on protocol ioctl callbacks
config: i386-randconfig-i061-20230525 (https://download.01.org/0day-ci/archive/20230529/202305290107.hs8sbfYc-lkp@intel.com/config)
compiler: clang version 14.0.6 (https://github.com/llvm/llvm-project f28c006a5895fc0e329fe15fead81e37457cb1d1)
reproduce (this is a W=1 build):
        mkdir -p ~/bin
        wget https://raw.githubusercontent.com/intel/lkp-tests/master/sbin/make.cross -O ~/bin/make.cross
        chmod +x ~/bin/make.cross
        # https://github.com/intel-lab-lkp/linux/commit/dbeb44f8503d11da0219fc6ef8a56c28cfde1511
        git remote add linux-review https://github.com/intel-lab-lkp/linux
        git fetch --no-tags linux-review Breno-Leitao/net-ioctl-Use-kernel-memory-on-protocol-ioctl-callbacks/20230525-205741
        git checkout dbeb44f8503d11da0219fc6ef8a56c28cfde1511
        # save the config file
        mkdir build_dir && cp config build_dir/.config
        COMPILER_INSTALL_PATH=$HOME/0day COMPILER=clang ~/bin/make.cross W=1 O=build_dir ARCH=i386 olddefconfig
        COMPILER_INSTALL_PATH=$HOME/0day COMPILER=clang ~/bin/make.cross W=1 O=build_dir ARCH=i386 SHELL=/bin/bash net/phonet/

If you fix the issue, kindly add following tag where applicable
| Reported-by: kernel test robot <lkp@intel.com>
| Closes: https://lore.kernel.org/oe-kbuild-all/202305290107.hs8sbfYc-lkp@intel.com/

All errors (new ones prefixed by >>):

>> net/phonet/af_phonet.c:43:5: error: redefinition of 'phonet_sk_ioctl'
   int phonet_sk_ioctl(struct sock *sk, unsigned int cmd, void __user *arg)
       ^
   include/net/phonet/phonet.h:125:19: note: previous definition is here
   static inline int phonet_sk_ioctl(struct sock *sk, unsigned int cmd, void __user *arg)
                     ^
   1 error generated.


vim +/phonet_sk_ioctl +43 net/phonet/af_phonet.c

    42	
  > 43	int phonet_sk_ioctl(struct sock *sk, unsigned int cmd, void __user *arg)
    44	{
    45		int karg;
    46	
    47		switch (cmd) {
    48		case SIOCPNADDRESOURCE:
    49		case SIOCPNDELRESOURCE:
    50			if (get_user(karg, (int __user *)arg))
    51				return -EFAULT;
    52	
    53			return sk->sk_prot->ioctl(sk, cmd, &karg);
    54		}
    55		/* A positive return value means that the ioctl was not processed */
    56		return 1;
    57	}
    58	

-- 
0-DAY CI Kernel Test Service
https://github.com/intel/lkp-tests/wiki
