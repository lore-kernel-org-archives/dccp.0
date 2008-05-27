From: Giuseppe Galeota <giuseppegaleota@libero.it>
Date: Tue, 27 May 2008 19:26:44 +0000
Subject: Re: Experimental_DCCP_source_tree: Snapshot patch for kernel 2.6.24
Message-Id: <483C6074.30504@libero.it>
List-Id: <dccp.vger.kernel.org>
References: <483AA49E.2000804@libero.it>
In-Reply-To: <483AA49E.2000804@libero.it>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Dear Gerrit, 

I made this:
 1: I have turned on DCCP Protocol-->Dccp CCIDs Configurations-->CCIS2/CCID3 debugging messages in the file .config(using make gconfig)
 2: I have changed the following hunk in net/dccp/feat.c, as you said
from:

	#else  /* ! CONFIG_IP_DCCP_DEBUG */
	#define dccp_feat_print_opt(opt, feat, fval, mandatory)
	#define dccp_feat_print_fnlist(fn_list)
	#endif

to:
	#else  /* ! CONFIG_IP_DCCP_DEBUG */
	#define dccp_feat_print_opt(opt, feat, val, len, mandatory)
	#define dccp_feat_print_fnlist(fn_list)
	#endif

Than, I have compiled the kernel, and regarded /net/dccp/feat.c I only read a warning:
  /net/dccp/feat.c: .........warning: dccp_feat_oname: defined but not used

So, I think that is all OK, isn't it?

Thanks
Giuseppe




Gerrit Renker ha scritto:
>> However, I tried to compile the new kernel (importing my old file .config), but I could see some errors about net/dccp/feat.
>> (I have enclosed a part of the result).
>> What do you think about this?
>>
>>     
> This is what I meant with not having the latest fixes. The problem is
> because you are compiling your kernel with the CONFIG_IP_DCCP_xxx_DEBUG
> turned off. The bug had been pointed out last week by Wei Yongjun and
> has been fixed since in the test tree, but not in the older patches.
>
> I will fix the 2.6.24/25 patches also, you can fix this by either
>  * compiling the kernel with debug options for DCCP turned on
>   (and then I am sure it works);
>  * change the following hunk in net/dccp/feat.c
>
> from:
>
> 	#else  /* ! CONFIG_IP_DCCP_DEBUG */
> 	#define dccp_feat_print_opt(opt, feat, fval, mandatory)
> 	#define dccp_feat_print_fnlist(fn_list)
> 	#endif
>
> to:
> 	#else  /* ! CONFIG_IP_DCCP_DEBUG */
> 	#define dccp_feat_print_opt(opt, feat, val, len, mandatory)
> 	#define dccp_feat_print_fnlist(fn_list)
> 	#endif
>
> Any name for the arguments will do - it is just an empty declaration.
>
> Thanks
> Gerrit
>
> | net/dccp/feat.c:546:54: error: macro "dccp_feat_print_opt" passed 5 arguments, but takes just 4
> | net/dccp/feat.c: In function ???dccp_feat_insert_opts???:
> | net/dccp/feat.c:546: error: ???dccp_feat_print_opt??? undeclared (first use in this function)
> | net/dccp/feat.c:546: error: (Each undeclared identifier is reported only once
> | net/dccp/feat.c:546: error: for each function it appears in.)
> | net/dccp/feat.c:962:55: error: macro "dccp_feat_print_opt" passed 5 arguments, but takes just 4
> | net/dccp/feat.c: In function ???dccp_feat_change_recv???:
> | net/dccp/feat.c:962: error: ???dccp_feat_print_opt??? undeclared (first use in this function)
> | net/dccp/feat.c:1071:55: error: macro "dccp_feat_print_opt" passed 5 arguments, but takes just 4
> | net/dccp/feat.c: In function ???dccp_feat_confirm_recv???:
> | net/dccp/feat.c:1071: error: ???dccp_feat_print_opt??? undeclared (first use in this function)
> | net/dccp/feat.c:1168:52: error: macro "dccp_feat_print_opt" passed 5 arguments, but takes just 4
> | net/dccp/feat.c: In function ???dccp_feat_handle_nn_established???:
> | net/dccp/feat.c:1168: error: ???dccp_feat_print_opt??? undeclared (first use in this function)
> | make[3]: *** [net/dccp/feat.o] Error 1
> | make[2]: *** [net/dccp] Error 2
> | make[1]: *** [net] Error 2
> | make[1]: Leaving directory `/usr/src/linux-source-2.6.24-org'
> | make: *** [debian/stamp-build-kernel] Error 2
> |
>
>
> --
> .
>
>   
