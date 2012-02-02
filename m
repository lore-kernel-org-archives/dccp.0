From: Jordi Salvador <salvador@wingsformedia.com>
Date: Thu, 02 Feb 2012 16:59:34 +0000
Subject: Re: Bug on CCID 3 of DCCP
Message-Id: <CAN3PNWcxkzubppaKt7C9_0GzJz9PicVMyv3HD5fqATdNxtVang@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <CAG_KctrYctZVKLbhNhWv00ZYLwn0RZRtb_-4aQQDtrsfHGMivQ@mail.gmail.com>
In-Reply-To: <CAG_KctrYctZVKLbhNhWv00ZYLwn0RZRtb_-4aQQDtrsfHGMivQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hello:

First of all, thank you for your quick answer. The kernel we are using
is 2.6.35.4 (and 2.6.35.14, since a few days ago). We haven't tried
Gerrit's development code, yet.

I tried to read the code and understand it, and I also read the
relevant RFCs (for example, 4342 and 5348, and also the draft
specified in the source code), and I haven't yet been able to
understand why that situation arises. We have not much experience with
the Linux kernel source code.

Thanks again for your answer.

On 2 February 2012 17:38, Ian McDonald <ian.mcdonald@jandi.co.uk> wrote:
> Hi Jordi
>
> I am not actively working on this code at present so sending to
> dccp@vger.kernel.org.
>
> You will get asked a few questions so will ask them to you now:
> - what version of kernel are you using?
> - have you tried Gerrit's development code?
>
> The other thing with an experimental area of the Linux kernel is that
> if you are lucky someone will respond, otherwise you might need to
> learn the code and try and fix yourself. If you do not wish to do this
> you might wish to engage a professional firm. I went and fixed much of
> the code because I had problems I needed to resolve, for example.
>
> If I do get time then I may look at it, but highly unlikely I am afraid.
>
> Regards
>
> Ian
>
> On 2 February 2012 15:48, Jordi Salvador <salvador@wingsformedia.com> wrote:
>>
>> Hello Mr. McDonald:
>>
>> We are developing an application on Linux which sends data using the
>> DCCP protocol with CCID 3. Sometimes, while sending data, we get a bug
>> message, originated in net/dccp/ccids/ccid3.c, line 240, and then the
>> system freezes. Looking at the kernel source code we find the
>> following:
>>
>> BUG_ON(hc->tx_p && !hc->tx_x_calc);
>>
>> We haven't been able to reproduce that bug (it just happens randomly),
>> and we don't exactly understand the meaning of the condition that
>> triggers the bug, nor how that condition may hold true. Could you
>> point out us some ideas which could help us to understand why we are
>> experiencing that bug and to understand its meaning?
>>
>> Thank you in advance.
>> --
>> Jordi Salvador
>> +34934980980
>> +34660842146
>> salvador@wingsformedia.com
>>
>> Warning: This e-mail is privileged, confidential and contains private
>> information. Any reading, retention, distribution or copying of this
>> communication by any person other than its intended recipient is
>> prohibited.



-- 
Jordi Salvador
+34934980980
+34660842146
salvador@wingsformedia.com

Warning: This e-mail is privileged, confidential and contains private
information. Any reading, retention, distribution or copying of this
communication by any person other than its intended recipient is
prohibited.
