From: Colin Perkins <csp@csperkins.org>
Date: Fri, 20 Apr 2007 10:56:43 +0000
Subject: Re: [dccp] Re: [PATCH 2/25]: Avoid accumulation of large send credit
Message-Id: <8EAB30A1-F627-43B1-A0E1-01DEBD85E09E@csperkins.org>
List-Id: <dccp.vger.kernel.org>
References: <200703211844.12007@strip-the-willow>
In-Reply-To: <200703211844.12007@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 20 Apr 2007, at 11:20, Ian McDonald wrote:
> On 4/20/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
>> Ian, I would appreciate if in future you would not copy patch
>> descriptions over from dccp@vger to dccp@ietf.
>>
>> Apart from the fact that I don't like it, this creates the wrong  
>> idea among
>> people who have little or nothing to do with actual protocol  
>> implementation
>> - it produces an impression of "let's talk about some  
>> implementation bugs".
>> (But competent implementation feedback is welcome and solicited on  
>> dccp@vger)
>>
>> Which is the more regrettable since you are right in raising this  
>> point
>> as a general one: it is indeed a limitation of [RFC 3448, 4.6]  
>> with regard
>> to non-realtime OSes. To clarify, the two main issues of this  
>> limitation
>> are summarised below.
>>
> Yes I was a bit lazy in replying without changing the subject etc.  
> My apologies.
>
> I'm refraining on replying further on these topics until I do some
> experimentation which may be a while off.

Likewise - we have experiments in progress, and while we do have  
stability problems with our TFRC implementation, I'm unconvinced the  
behaviour is due to the reasons suggested. I'll report back when we  
have more results.

Colin
