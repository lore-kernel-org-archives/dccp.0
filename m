From: Chen Gang <gang.chen.5i5j@gmail.com>
Date: Fri, 23 May 2014 01:43:35 +0000
Subject: Re: =?UTF-8?B?5Zue5aSN77yaIFJlOiBbUEFUQ0ggbGludXgtbmV4dF0gbmV0L2Q=?= =?UTF-8?B?Y2NwL3RpbWVyLmM6IHVzZ
Message-Id: <537EA7C7.8040708@gmail.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: dccp@vger.kernel.org

On 05/23/2014 07:58 AM, 管雪涛 wrote:
> 
> ----- David Miller <davem@davemloft.net> 写道：
>> From: Chen Gang <gang.chen.5i5j@gmail.com>
>> Date: Wed, 21 May 2014 08:19:34 +0800
>>
>>> 'dccp_timestamp_seed' is initialized once by ktime_get_real() in
>>> dccp_timestamping_init(). It is always less than ktime_get_real()
>>> in dccp_timestamp().
>>>
>>> Then, ktime_us_delta() in dccp_timestamp() will always return positive
>>> number. So can use manual type cast to let compiler and do_div() know
>>> about it to avoid warning.
>>>
>>> The related warning (with allmodconfig under unicore32):
>>>
>>>     CC [M]  net/dccp/timer.o
>>>   net/dccp/timer.c: In function ‘dccp_timestamp’:
>>>   net/dccp/timer.c:285: warning: comparison of distinct pointer types lacks a cast
>>>
>>>
>>> Signed-off-by: Chen Gang <gang.chen.5i5j@gmail.com>
>>
>> Applied to net-next, thanks.
>>

Thank you for your work.

>> But that type check in include/asm-generic/div64.h is bogus, it should
>> be checking sizeof(X) = 8 rather than the type thing, it just wants to
>> make sure that the value is 64-bit regardless of it's signedness.
>>
>> The arch local implementations do not do this, and that's why very few
>> other people notice this warning.
> 
> Arch-dependent codes implement it with unsigned long long type.
> And, every warning should not be ignored.
> 

Yeah, we have to let do_div() no touch (especially for 32-bit machine,
which the highest bit is checked). The related code in
"include/asm-generic/div64.h":

 23 #if BITS_PER_LONG = 64
 24
 25 # define do_div(n,base) ({                                      \
 26         uint32_t __base = (base);                               \
 27         uint32_t __rem;                                         \
 28         __rem = ((uint64_t)(n)) % __base;                       \
 29         (n) = ((uint64_t)(n)) / __base;                         \
 30         __rem;                                                  \
 31  })
 32
 33 #elif BITS_PER_LONG = 32
 34
 35 extern uint32_t __div64_32(uint64_t *dividend, uint32_t divisor);
 36
 37 /* The unnecessary pointer compare is there
 38  * to check for type safety (n must be 64bit)
 39  */
 40 # define do_div(n,base) ({                              \
 41         uint32_t __base = (base);                       \
 42         uint32_t __rem;                                 \
 43         (void)(((typeof((n)) *)0) = ((uint64_t *)0));  \
 44         if (likely(((n) >> 32) = 0)) {                 \
 45                 __rem = (uint32_t)(n) % __base;         \
 46                 (n) = (uint32_t)(n) / __base;           \
 47         } else                                          \
 48                 __rem = __div64_32(&(n), __base);       \
 49         __rem;                                          \
 50  })


And for division operation, architectures are signed/unsigned
sensitive, e.g. div_u64() and div_s64(), they are different.


Thanks.
-- 
Chen Gang

Open, share, and attitude like air, water, and life which God blessed
