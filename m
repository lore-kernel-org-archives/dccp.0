From: "=?ISO-2022-JP?B?GyRCJUQbKEIgTGVhbmRybyBTYWxlcw==?="
Date: Sat, 18 Aug 2007 15:44:53 +0000
Subject: Backporting gerrit tree (from git) to 2.6.18. IT WAS: "Backport" latest (git) DCCP code to 2.6.18
Message-Id: <5bc4c4570708180844g3618c9a0v1f6cb69222c9c7f8@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Arnaldo,
  as you mentioned, I'm in trouble in the kernel skb, please see below:

[sbox-SDK_ARMEL: /usr/src/kernel-source-rx-34] > make zImage
  CHK     include/linux/version.h
make[1]: `include/asm-arm/mach-types.h' is up to date.
  CHK     include/linux/utsrelease.h
  CHK     include/linux/compile.h
  CC      net/dccp/minisocks.o
net/dccp/minisocks.c: In function `dccp_check_req':
net/dccp/minisocks.c:258: warning: passing arg 1 of pointer to
function from incompatible pointer type
net/dccp/minisocks.c:258: error: too many arguments to function
make[2]: *** [net/dccp/minisocks.o] Error 1
make[1]: *** [net/dccp] Error 2
make: *** [net] Error 2

-------

the code that it is generation this error is minisocks.c file:

drop:
        if (dccp_hdr(skb)->dccph_type != DCCP_PKT_RESET)
                req->rsk_ops->send_reset(sk, skb);

The problem is related to skb and I have no idea to do from here. I
had many other problems before this, particular with the linux
workqueue implementation (include/linux/workqueue.c/h) and with
kmen_create_cache (function ccid_kmem_cache_create) but I solved them.
So, what do you suggest me to do?

Thank you,
Leandro.

2007/8/6, Arnaldo Carvalho de Melo <acme@ghostprotocols.net>:
> Em Mon, Aug 06, 2007 at 09:55:49AM -0300, ?$B%D Leandro Sales escreveu:
> > Hi folks,
> >    due to wireless card restrictions (the wifi card driver is
> > proprietary) I can't use the latest linux-omap git kernel with nokia
> > n800. In this way, the unique kernel version available for this
> > plataform is 2.6.18. Then I'd like to know if will I have problem if I
> > get the latest DCCP codes (from the git kernel) and copy them to
> > kernel 2.6.18.
> >    Just in case of you don't know if I will get any problem, I will
> > try to do this and see what happen.
>
> Its technically possible. That is what companies such as Red Hat does
> for a living. The kernel in RHEL5, the current enterprise offering from
> Red Hat is based on 2.6.18, for instance :-)
>
> The infrastructure is also not changing that much, but pay attention to
> ktime, perhaps the skb offset patches, i.e. I think it will not be just
> copying the dccp files from the top of the tree into 2.6.18 and
> rebuilding :)
>
> - Arnaldo
>


-- 
Leandro Melo de Sales.
Pervasive and Embedded Computing Laboratory
BRisa and E-Phone Projects Manager & Network Administrator
http://embedded.ufcg.edu.br/
+55 083 3310-1404 (extension 208)

"There are 10 types of people in this world: those who understand
binary, those who don't"
