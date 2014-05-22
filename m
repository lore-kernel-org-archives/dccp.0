From: =?utf-8?B?566h6Zuq5rab?= <gxt@pku.edu.cn>
Date: Thu, 22 May 2014 01:06:46 +0000
Subject: =?utf-8?Q?=E5=9B=9E=E5=A4=8D=EF=BC=9A_Re:_=E5=9B=9E=E5=A4=8D=EF=BC=9A_?= =?utf-8?Q?[PATCH_linux-?= =
Message-Id: <579164883.46799.1400720806850.JavaMail.root@bj-mail03.pku.edu.cn>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: dccp@vger.kernel.org


----- Chen Gang <gang.chen.5i5j@gmail.com> 写道：
> On 05/22/2014 08:26 AM, 管雪涛 wrote:
> > 
> > ----- Chen Gang <gang.chen.5i5j@gmail.com> 写道：
> >> 'dccp_timestamp_seed' is initialized once by ktime_get_real() in
> >> dccp_timestamping_init(). It is always less than ktime_get_real()
> >> in dccp_timestamp().
> >>
> >> Then, ktime_us_delta() in dccp_timestamp() will always return positive
> >> number. So can use manual type cast to let compiler and do_div() know
> >> about it to avoid warning.
> >>
> >> The related warning (with allmodconfig under unicore32):
> >>
> >>     CC [M]  net/dccp/timer.o
> >>   net/dccp/timer.c: In function ‘dccp_timestamp’:
> >>   net/dccp/timer.c:285: warning: comparison of distinct pointer types lacks a cast
> >>
> >>
> >> Signed-off-by: Chen Gang <gang.chen.5i5j@gmail.com>
> >> ---
> >>  net/dccp/timer.c | 2 +-
> >>  1 file changed, 1 insertion(+), 1 deletion(-)
> >>
> >> diff --git a/net/dccp/timer.c b/net/dccp/timer.c
> >> index 16f0b22..1cd46a3 100644
> >> --- a/net/dccp/timer.c
> >> +++ b/net/dccp/timer.c
> >> @@ -280,7 +280,7 @@ static ktime_t dccp_timestamp_seed;
> >>   */
> >>  u32 dccp_timestamp(void)
> >>  {
> >> -	s64 delta = ktime_us_delta(ktime_get_real(), dccp_timestamp_seed);
> >> +	u64 delta = (u64)ktime_us_delta(ktime_get_real(), dccp_timestamp_seed);
> > 
> > Do you assume that delta should be very small?
> > Otherwise, return value will be different if data type is changed.
> > 
> 
> 'u64' is a very very large number. after calculation, if it is based on
> nano second (although I am not quite sure whether it is based on it).
> 
>         a hour,            3,600,000,000,000ns
>         a day,            90,000,000,000,000ns
>         a year,       50,000,000,000,000,000ns
>         10 years,    500,000,000,000,000,000ns
>         100 years, 5,000,000,000,000,000,000ns
>         4G * 4G = 16,000,000,000,000,000,000ns
> 
> So we can assume it will never overflow for 'u64'.

However, return value of dccp_timestamp function is u32.

> 
> 
> Thanks.
> -- 
> Chen Gang
> 
> Open, share, and attitude like air, water, and life which God blessed
