From: Wei Yongjun <yjwei@cn.fujitsu.com>
Date: Tue, 13 May 2008 10:52:21 +0000
Subject: Re: [PATCH] DCCP: Fix to reset the connection with Reset Code 5	Option
Message-Id: <482972E5.8060703@cn.fujitsu.com>
List-Id: <dccp.vger.kernel.org>
References: <48294E9C.4060209@cn.fujitsu.com>
In-Reply-To: <48294E9C.4060209@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hi Gerrit Renker:

I think your should update your patch to avoid compile error:

+#define dccp_feat_print_opt(opt, feat, val, len, mandatory)              \
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
+    dccp_pr_debug("%s(%s, ", dccp_feat_oname(opt), dccp_feat_fname(feat));\
+    dccp_feat_printvals(feat, val, len);                      \
+    dccp_pr_debug_cat(") %s\n", mandatory ? "!" : "");
...snip...
+#else    /* ! CONFIG_IP_DCCP_DEBUG */
+#define dccp_feat_print_opt(opt, feat, fval, mandatory)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The first dccp_feat_print_opt() take 5 parameters when 
CONFIG_IP_DCCP_DEBUG, but the second one just take 4.


Gerrit Renker wrote:
>> Sorry for my stupid patch since I can get the test git tree.
>>
>>     
> There is nothing at all wrong with the patch and I apologise for the
> remark, since it is not your fault not to be aware of the test tree.
>
> That was my fault - in at least one of the 4 cases David Miller copied the
> changeset over to dccp@vger. I am working with Arnaldo de Melo (the DCCP
> maintainer) on a solution for this, to avoid future overlap. It is not
> your issue, so sorry.
>
> For the moment the best is to apply this patch and fix the problem in
> the mainline variant of net/dccp.
>
>
>   
>> But, Is there any other way to get the git tree? I download a patch from 
>> following URL:
>>   
>> http://www.erg.abdn.ac.uk/users/gerrit/dccp/testing_dccp/test-tree/test-tree_2.6.25.diff.gz
>> I used this patch to my linux-2.6.25, there is error happend. and it has 
>> compile error too.
>>     
> This is possible since the snapshots are taken on the day a new release
> comes out. Thanks for the notice, the outdated snapshot will be replaced.
>
>   
>> Is this patch is based on linux-2.6.25? If I want to send a patch, I  
>> must create my patch base on what version of kernel?
>>
>>     
> The test tree tracks the netdev-2.6 kernel and only touches net/dccp. It
> can be pulled from
> 	git://eden-feed.erg.abdn.ac.uk/dccp_exp (subtree `dccp')
>
>
> Gerrit
>
>
>   


-- 
--------------------------------------------------
Wei Yongjun
Development Dept.I
Nanjing Fujitsu Nanda Software Tech. Co., Ltd.(FNST)
8/F., Civil Defense Building, No.189 Guangzhou Road,
Nanjing, 210029, China
TEL: +86+25-86630523-836
COINS: 79955-836
FAX: +86+25-83317685
MAIL: yjwei@cn.fujitsu.com
--------------------------------------------------
This communication is for use by the intended recipient(s) only and may contain information that is privileged, confidential and exempt from disclosure under applicable law. If you are not an intended recipient of this communication, you are hereby notified that any dissemination, distribution or copying hereof is strictly prohibited.  If you have received this communication in error, please notify me by reply e-mail, permanently delete this communication from your system, and destroy any hard copies you may have printed

