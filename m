From: Carl-Daniel Hailfinger <c-d.hailfinger.devel.2006@gmx.net>
Date: Mon, 20 Feb 2006 20:04:20 +0000
Subject: Re: 2.6.16-rc4-mm1
Message-Id: <43FA20C4.9090709@gmx.net>
List-Id: <dccp.vger.kernel.org>
References: <43F9CE18.10709@trash.net>
In-Reply-To: <43F9CE18.10709@trash.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Patrick McHardy schrieb:
> Reuben Farrelly wrote:
> 
>>Minor dependency issue:
>>
>>My compile failed with this..
>>
>>  CC [M]  net/netfilter/xt_dccp.o
>>In file included from net/netfilter/xt_dccp.c:15:
>>include/linux/dccp.h:341:2: error: #error "At least one CCID must be
>>built as the default"
>>make[2]: *** [net/netfilter/xt_dccp.o] Error 1
>>make[1]: *** [net/netfilter] Error 2
>>make: *** [net] Error 2
>>[root@tornado linux-2.6-mm]#
>>
>>[I have no idea what a CCID is]
>>
>>But it was caused by this:
>>
>>CONFIG_NETFILTER_XT_MATCH_DCCP=m
>>
>>and maybe this below had an impact:
>>
>>#
>># DCCP Configuration (EXPERIMENTAL)
>>#
>># CONFIG_IP_DCCP is not set
>>
>>After unsetting the option to build the DCCP Netfilter module, I was
>>able to compile through to completion.
> 
> 
> Ideally this dependency should be enforced by Kconfig. I'm not sure
> if it is possible to express something like "IP_DCCP_CCID2 and
> IP_DCCP_CCID3 depend on DCCP, DCCP requires at least one of both
> to be enabled". Can someone more familiar with Kconfig than me
> comment on this? Otherwise the #error should be moved to
> net/dccp/options.c to keep dccp.h usable without dccp enabled.

Suggestion (not tested):

config IP_DCCP_CCID2
        tristate "blah"
        select DCCP
        help
          Foo
config IP_DCCP_CCID3
        tristate "blah"
        select DCCP
        help
          Foo
config DCCP
        bool "blah"
        depends on IP_DCCP_CCID2 || IP_DCCP_CCID3
        help
          Foo


Regards,
Carl-Daniel
-- 
http://www.hailfinger.org/
