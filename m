From: YueHaibing <yuehaibing@huawei.com>
Date: Fri, 22 Mar 2019 13:39:31 +0000
Subject: Re: [PATCH] dccp: Fix memleak in __feat_register_sp
Message-Id: <a714b91a-fc8b-841b-6e9e-b4c18894fec7@huawei.com>
List-Id: <dccp.vger.kernel.org>
References: <20190321141058.14580-1-yuehaibing@huawei.com>
In-Reply-To: <20190321141058.14580-1-yuehaibing@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 2019/3/22 19:52, Mukesh Ojha wrote:
> 
> On 3/21/2019 7:40 PM, Yue Haibing wrote:
>> From: YueHaibing <yuehaibing@huawei.com>
>>
>> If dccp_feat_push_change fails, we forget free the mem
>> which is alloced by kmemdup in dccp_feat_clone_sp_val.
>>
>> Reported-by: Hulk Robot <hulkci@huawei.com>
>> Fixes: e8ef967a54f4 ("dccp: Registration routines for changing feature values")
>> Signed-off-by: YueHaibing <yuehaibing@huawei.com>
>> ---
>>   net/dccp/feat.c | 7 ++++++-
>>   1 file changed, 6 insertions(+), 1 deletion(-)
>>
>> diff --git a/net/dccp/feat.c b/net/dccp/feat.c
>> index f227f00..083e012 100644
>> --- a/net/dccp/feat.c
>> +++ b/net/dccp/feat.c
>> @@ -738,7 +738,12 @@ static int __feat_register_sp(struct list_head *fn, u8 feat, u8 is_local,
>>       if (dccp_feat_clone_sp_val(&fval, sp_val, sp_len))
>>           return -ENOMEM;
>>   -    return dccp_feat_push_change(fn, feat, is_local, mandatory, &fval);
>> +    if (dccp_feat_push_change(fn, feat, is_local, mandatory, &fval)) {
>> +        kfree(val->sp.vec);
> 
> Please atleast check the compilation first, don't  just rush into sending patch.
> 
> s/val/fval

A copy-paste typo, will fix it. Thanks!

> 
> 
> Thanks,
> Mukesh
> 
>> +        return -ENOMEM;
>> +    }
>> +
>> +    return 0;
>>   }
>>     /**
> 
> .
> 
