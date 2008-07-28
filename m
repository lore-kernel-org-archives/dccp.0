From: Wei Yongjun <yjwei@cn.fujitsu.com>
Date: Mon, 28 Jul 2008 03:08:57 +0000
Subject: Re: DCCP Conformance Test Suite
Message-Id: <488D3849.4050809@cn.fujitsu.com>
List-Id: <dccp.vger.kernel.org>
References: <488D3270.1020704@cn.fujitsu.com>
In-Reply-To: <488D3270.1020704@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Leandro Sales wrote:
> Nice job, Wei! I have being at OLS and one person from IBM talked
> about LTP, are you using this project?
>   

Not LTP,  I used the TAHI's v6eval, which is used for IPv6 DCCP 
Conformance Test Suite.

> Regards,
> Leandro.
>
>
> On 7/27/08, Wei Yongjun <yjwei@cn.fujitsu.com> wrote:
>   
>> Hi Gerrit Renker:
>>
>> The DCCP Conformance Test Suite is available now with little test cases.
>> Can you have a look at it and tell me what functions of DCCP need to be
>> add test cases? I'll continue to add test cases for DCCP. Thanks.
>>
>> I have do test under IPv4, and there are still some BUGs(?) of DCCP
>> which need to do patch.
>>
>> If you or someone have something needed to be tested, you can tell me, I
>> can wrote test case for it if it is possible.
>>
>> Download:
>> It is available at:
>> http://dccpct.sourceforge.net/download.html
>>
>> - v6eval with DCCP support:
>> http://dccpct.sourceforge.net/v6eval-3.0.14-linux-dccp.tar.gz
>>
>> - Test Suite:
>> http://dccpct.sourceforge.net/dccp-1.0.0.tar.gz
>>
>> Usage:
>> http://dccpct.sourceforge.net/usage.html
>>
>> Test Report under IPv4:
>> http://dccpct.sourceforge.net/log/ipv4/index.html
>>
>>
>> Regards
>> Wei Yongjun
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe dccp" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
>>     

