From: YueHaibing <yuehaibing@huawei.com>
Date: Mon, 01 Apr 2019 08:44:35 +0000
Subject: Re: [PATCH] dccp: Fix memleak in __feat_register_sp
Message-Id: <2022d726-4785-5d64-c8b5-37171d2dc220@huawei.com>
List-Id: <dccp.vger.kernel.org>
References: <20190321141058.14580-1-yuehaibing@huawei.com>
In-Reply-To: <20190321141058.14580-1-yuehaibing@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 2019/4/1 16:24, Mukesh Ojha wrote:
> 
> On 4/1/2019 7:05 AM, Yue Haibing wrote:
>> From: YueHaibing <yuehaibing@huawei.com>
>>
>> If dccp_feat_push_change fails, we forget free the mem
>> which is alloced by kmemdup in dccp_feat_clone_sp_val.
>>
>> Reported-by: Hulk Robot <hulkci@huawei.com>
>> Fixes: e8ef967a54f4 ("dccp: Registration routines for changing feature values")
>> Reviewed-by: Mukesh Ojha <mojha@codeaurora.org>
>> Signed-off-by: YueHaibing <yuehaibing@huawei.com>
>> ---
> 
> 
> I don't think it is the first version. Do keep in mind to put detail here .

Yes, this is the v3 resend.

> 
> -Mukesh
> 
>>   net/dccp/feat.c | 7 ++++++-
>>   1 file changed, 6 insertions(+), 1 deletion(-)
>>
>> diff --git a/net/dccp/feat.c b/net/dccp/feat.c
>> index f227f00..db87d9f 100644
>> --- a/net/dccp/feat.c
>> +++ b/net/dccp/feat.c
>> @@ -738,7 +738,12 @@ static int __feat_register_sp(struct list_head *fn, u8 feat, u8 is_local,
>>       if (dccp_feat_clone_sp_val(&fval, sp_val, sp_len))
>>           return -ENOMEM;
>>   -    return dccp_feat_push_change(fn, feat, is_local, mandatory, &fval);
>> +    if (dccp_feat_push_change(fn, feat, is_local, mandatory, &fval)) {
>> +        kfree(fval.sp.vec);
>> +        return -ENOMEM;
>> +    }
>> +
>> +    return 0;
>>   }
>>     /**
> 
> 
