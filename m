From: "Leandro Sales" <leandroal@gmail.com>
Date: Thu, 06 Nov 2008 17:46:25 +0000
Subject: Re: Protocol not attached
Message-Id: <5bc4c4570811060946j4d5d8d1mf88f8b92c72b59c7@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <5bc4c4570809291133k3f5841b1qde962bd3b4882439@mail.gmail.com>
In-Reply-To: <5bc4c4570809291133k3f5841b1qde962bd3b4882439@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Thu, Nov 6, 2008 at 3:38 PM, Arnaldo Carvalho de Melo
<acme@redhat.com> wrote:
> Em Thu, Nov 06, 2008 at 04:20:48PM +0100, Gerrit Renker escreveu:
>> | > is there any news regarding the CCID/module loading problem on the 64
>> | > bit computer with 32 bit kernel?
>> | >
>> <snip>
>> | Hello Gerrit,
>> |     yes! I think that we found the commit that inserted the problem (probably).
>> |
>> |     This is the list of commits, the first time that the problem
>> | occurs is in "f76fd327a8b32d3ad5b51639faf6f54d18be0981". I'm sending
>> | to you the tree commits before the BAD that it is working properly.
>> |
>> |  - BAD - Gerrit Renker f76fd327a8b32d3ad5b51639faf6f54d18be0981 dccp
>> Ah that would explain it. Did you check the logs - if the not-loading
>> was due to low timer resolution, then there should be a message like
>> "Timer to coarse (xxx usec), need 10usec".
>>
>> If that is the case,
>>     1. does the problem disappear when commenting out
>>        'return -ESOCKTNOSUPPORT' in  ccid3_module_init() below or if
>>     2. the kernel is compiled with support for high-resolution timers?
>>
>>
>> +       if (tp.tv_sec || tp.tv_nsec > DCCP_TIME_RESOLUTION * NSEC_PER_USEC) {
>> +               printk(KERN_ERR "%s: Timer too coarse (%ld usec), need %u-usec"
>> +                      " resolution - check your clocksource.\n", __func__,
>> +                      tp.tv_nsec/NSEC_PER_USEC, DCCP_TIME_RESOLUTION);
>> +               return -ESOCKTNOSUPPORT;
>> +       }
>>
>> Thanks a lot for following this up, this now looks a much more likely cause.
>
> Makes complete sense, to finish this, Leandro, can you please tell us
> what is the value of CONFIG_HZ in your config?
>
> - Arnaldo
>

CONFIG_HZ_250=y
CONFIG_HZ%0
