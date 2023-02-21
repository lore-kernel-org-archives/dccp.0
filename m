From: kernel test robot <lkp@intel.com>
Date: Tue, 21 Feb 2023 14:35:48 +0000
Subject: Re: [PATCH] net: dccp: delete redundant ackvec record in dccp_insert_options()
Message-Id: <202302212209.2xKQbnhl-lkp@intel.com>
List-Id: <dccp.vger.kernel.org>
References: <20230221092206.39741-1-hbh25y@gmail.com>
In-Reply-To: <20230221092206.39741-1-hbh25y@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hi Hangyu,

Thank you for the patch! Perhaps something to improve:

[auto build test WARNING on net-next/master]
[also build test WARNING on net/master horms-ipvs/master linus/master v6.2 next-20230221]
[If your patch is applied to the wrong git tree, kindly drop us a note.
And when submitting patch, we suggest to use '--base' as documented in
https://git-scm.com/docs/git-format-patch#_base_tree_information]

url:    https://github.com/intel-lab-lkp/linux/commits/Hangyu-Hua/net-dccp-delete-redundant-ackvec-record-in-dccp_insert_options/20230221-172448
patch link:    https://lore.kernel.org/r/20230221092206.39741-1-hbh25y%40gmail.com
patch subject: [PATCH] net: dccp: delete redundant ackvec record in dccp_insert_options()
config: i386-randconfig-a013-20230220 (https://download.01.org/0day-ci/archive/20230221/202302212209.2xKQbnhl-lkp@intel.com/config)
compiler: clang version 14.0.6 (https://github.com/llvm/llvm-project f28c006a5895fc0e329fe15fead81e37457cb1d1)
reproduce (this is a W=1 build):
        wget https://raw.githubusercontent.com/intel/lkp-tests/master/sbin/make.cross -O ~/bin/make.cross
        chmod +x ~/bin/make.cross
        # https://github.com/intel-lab-lkp/linux/commit/ea44b55ba82bbe3f35b51212bf839f507a30b70b
        git remote add linux-review https://github.com/intel-lab-lkp/linux
        git fetch --no-tags linux-review Hangyu-Hua/net-dccp-delete-redundant-ackvec-record-in-dccp_insert_options/20230221-172448
        git checkout ea44b55ba82bbe3f35b51212bf839f507a30b70b
        # save the config file
        mkdir build_dir && cp config build_dir/.config
        COMPILER_INSTALL_PATH=$HOME/0day COMPILER=clang make.cross W=1 O=build_dir ARCH=i386 olddefconfig
        COMPILER_INSTALL_PATH=$HOME/0day COMPILER=clang make.cross W=1 O=build_dir ARCH=i386 SHELL=/bin/bash net/dccp/

If you fix the issue, kindly add following tag where applicable
| Reported-by: kernel test robot <lkp@intel.com>
| Link: https://lore.kernel.org/oe-kbuild-all/202302212209.2xKQbnhl-lkp@intel.com/

All warnings (new ones prefixed by >>):

   net/dccp/options.c:594:8: error: implicit declaration of function 'dccp_ackvec_lookup' is invalid in C99 [-Werror,-Wimplicit-function-declaration]
           avr = dccp_ackvec_lookup(&av->av_records, DCCP_SKB_CB(skb)->dccpd_seq);
                 ^
>> net/dccp/options.c:594:6: warning: incompatible integer to pointer conversion assigning to 'struct dccp_ackvec_record *' from 'int' [-Wint-conversion]
           avr = dccp_ackvec_lookup(&av->av_records, DCCP_SKB_CB(skb)->dccpd_seq);
               ^ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   net/dccp/options.c:596:18: error: use of undeclared identifier 'dccp_ackvec_record_slab'; did you mean 'dccp_ackvec_clear_state'?
           kmem_cache_free(dccp_ackvec_record_slab, avr);
                           ^~~~~~~~~~~~~~~~~~~~~~~
                           dccp_ackvec_clear_state
   net/dccp/ackvec.h:110:6: note: 'dccp_ackvec_clear_state' declared here
   void dccp_ackvec_clear_state(struct dccp_ackvec *av, const u64 ackno);
        ^
   1 warning and 2 errors generated.


vim +594 net/dccp/options.c

   548	
   549	int dccp_insert_options(struct sock *sk, struct sk_buff *skb)
   550	{
   551		struct dccp_sock *dp = dccp_sk(sk);
   552		struct dccp_ackvec *av = dp->dccps_hc_rx_ackvec;
   553		struct dccp_ackvec_record *avr;
   554	
   555		DCCP_SKB_CB(skb)->dccpd_opt_len = 0;
   556	
   557		if (dp->dccps_send_ndp_count && dccp_insert_option_ndp(sk, skb))
   558			return -1;
   559	
   560		if (DCCP_SKB_CB(skb)->dccpd_type != DCCP_PKT_DATA) {
   561	
   562			/* Feature Negotiation */
   563			if (dccp_feat_insert_opts(dp, NULL, skb))
   564				return -1;
   565	
   566			if (DCCP_SKB_CB(skb)->dccpd_type = DCCP_PKT_REQUEST) {
   567				/*
   568				 * Obtain RTT sample from Request/Response exchange.
   569				 * This is currently used for TFRC initialisation.
   570				 */
   571				if (dccp_insert_option_timestamp(skb))
   572					return -1;
   573	
   574			} else if (dccp_ackvec_pending(sk) &&
   575				   dccp_insert_option_ackvec(sk, skb)) {
   576					return -1;
   577			}
   578		}
   579	
   580		if (dp->dccps_hc_rx_insert_options) {
   581			if (ccid_hc_rx_insert_options(dp->dccps_hc_rx_ccid, sk, skb))
   582				goto delete_ackvec;
   583			dp->dccps_hc_rx_insert_options = 0;
   584		}
   585	
   586		if (dp->dccps_timestamp_echo != 0 &&
   587		    dccp_insert_option_timestamp_echo(dp, NULL, skb))
   588			goto delete_ackvec;
   589	
   590		dccp_insert_option_padding(skb);
   591		return 0;
   592	
   593	delete_ackvec:
 > 594		avr = dccp_ackvec_lookup(&av->av_records, DCCP_SKB_CB(skb)->dccpd_seq);
   595		list_del(&avr->avr_node);
   596		kmem_cache_free(dccp_ackvec_record_slab, avr);
   597		return -1;
   598	}
   599	

-- 
0-DAY CI Kernel Test Service
https://github.com/intel/lkp-tests
